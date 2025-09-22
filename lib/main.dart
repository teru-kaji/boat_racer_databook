// lib/main.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'objectbox.dart';
import 'objectbox.g.dart';  // ← これが必須
import 'models/member.dart';

late ObjectBox objectbox;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 書き込み可能なアプリ専用ディレクトリを取得
  final docDir = await getApplicationDocumentsDirectory();
  final obxDir = p.join(docDir.path, 'objectbox');

  // ★ ストアは1回だけ、明示ディレクトリで開く
  objectbox = await ObjectBox.create(directory: obxDir);

  // 初期投入: members.json（assets）→ DB（空のときだけ）
  await _seedIfEmpty();

  runApp(const MyApp());
}

Future<void> _seedIfEmpty() async {
  if (objectbox.memberBox.isEmpty()) {
    final raw = await rootBundle.loadString('assets/members.json');
    final List list = json.decode(raw) as List;
    final members = list
        .map((e) => Member.fromJson(e as Map<String, dynamic>))
        .toList();

    // id が 0 の場合は自動採番。number 等でユニーク性があるなら簡易重複除去してもOK
    objectbox.memberBox.putMany(members);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Member Search (ObjectBox)',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const MemberListPage(),
    );
  }
}

class MemberListPage extends StatefulWidget {
  const MemberListPage({super.key});

  @override
  State<MemberListPage> createState() => _MemberListPageState();
}

class _MemberListPageState extends State<MemberListPage> {
  final _controller = TextEditingController();
  List<Member> _items = [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    // 全件（必要に応じてソート）
    final all = objectbox.memberBox.getAll();
    all.sort((a, b) {
      final an = (a.number ?? '');
      final bn = (b.number ?? '');
      return an.compareTo(bn);
    });
    setState(() => _items = all);
  }

  void _search(String q) {
    final keyword = q.trim();
    if (keyword.isEmpty) {
      _refresh();
      return;
    }

    // 簡易全文検索（必要ならクエリビルダで最適化）
    final res = objectbox.memberBox
        .query(
      Member_.name.contains(keyword, caseSensitive: false) |
      Member_.nameKana.contains(keyword, caseSensitive: false) |
      Member_.number.contains(keyword, caseSensitive: false) |
      Member_.kana3.contains(keyword, caseSensitive: false),
    )
        .build()
        .find();

    setState(() => _items = res);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Members'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: '番号・名前・カナで検索',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: (_controller.text.isNotEmpty)
                    ? IconButton(
                  onPressed: () {
                    _controller.clear();
                    _search('');
                  },
                  icon: const Icon(Icons.clear),
                )
                    : null,
              ),
              onChanged: _search,
            ),
          ),
          Expanded(
            child: _items.isEmpty
                ? const Center(child: Text('データがありません'))
                : ListView.separated(
              itemCount: _items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final m = _items[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text((m.kana3 ?? (m.nameKana ?? ' ')).isNotEmpty
                        ? (m.kana3 ?? m.nameKana!)!.characters.first
                        : '?'),
                  ),
                  title: Text(m.name ?? m.number ?? '(no name)'),
                  subtitle: Text([
                    if ((m.number ?? '').isNotEmpty) 'No.${m.number}',
                    if ((m.rank ?? '').isNotEmpty) 'Rank:${m.rank}',
                    if (m.scoreRate != null) 'Score:${m.scoreRate}',
                  ].join('  ')),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // 簡易的に DB を空にして再投入（デモ用）
          objectbox.memberBox.removeAll();
          await _seedIfEmpty();
          _refresh();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('members.json を再投入しました')),
            );
          }
        },
        label: const Text('Reset & Seed'),
        icon: const Icon(Icons.replay),
      ),
    );
  }
}
