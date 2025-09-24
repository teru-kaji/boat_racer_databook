// lib/main.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'objectbox.dart';
import 'models/member.dart';
import 'objectbox.g.dart'; // ← Member_ を使うのに必須
import 'member_detail_page.dart';

late ObjectBox objectbox;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final docDir = await getApplicationDocumentsDirectory();
  final obxDir = p.join(docDir.path, 'objectbox');

  objectbox = await ObjectBox.create(directory: obxDir);

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
  // 入力コントロール
  final _numberCtrl = TextEditingController(); // 登録番号
  final _nameCtrl = TextEditingController();   // 名前
  String? _selectedDataTime; // 期 (DataTime)
  String? _selectedSex;      // 性別
  String? _selectedRank;     // 級別

  // 一覧表示
  List<Member> _items = [];

  // ドロップダウン候補
  List<String> _dataTimeOptions = [];
  List<String> _sexOptions = [];
  List<String> _rankOptions = [];

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  void _loadInitial() {
    final all = objectbox.memberBox.getAll();

    _dataTimeOptions = _distinctNonEmpty(all.map((m) => m.dataTime));
    _sexOptions = _distinctNonEmpty(all.map((m) => m.sex));
    _rankOptions = _distinctNonEmpty(all.map((m) => m.rank));

    // ★ dataTime の最大値を初期値にセット
    if (_dataTimeOptions.isNotEmpty) {
      _selectedDataTime =
          _dataTimeOptions.reduce((a, b) => a.compareTo(b) > 0 ? a : b);
    }

    _applyFilters();
  }

  /// null や空文字を除去して、重複しないソート済みリストを返す
  List<String> _distinctNonEmpty(Iterable<String?> source) {
    final set = <String>{};
    for (final v in source) {
      final s = (v ?? '').trim();
      if (s.isNotEmpty) set.add(s);
    }
    final list = set.toList()..sort();
    return list;
  }

  void _resetFilters() {
    _numberCtrl.clear();
    _nameCtrl.clear();
    setState(() {
      // DataTime はリセットしても最新期を残す
      if (_dataTimeOptions.isNotEmpty) {
        _selectedDataTime =
            _dataTimeOptions.reduce((a, b) => a.compareTo(b) > 0 ? a : b);
      }
      _selectedSex = null;
      _selectedRank = null;
    });
    _applyFilters();
  }

  void _applyFilters() {
    final number = _numberCtrl.text.trim();
    final name = _nameCtrl.text.trim();
    final dataTime = _selectedDataTime?.trim() ?? '';
    final sex = _selectedSex?.trim() ?? '';
    final rank = _selectedRank?.trim() ?? '';

    Condition<Member>? cond;

    if (dataTime.isNotEmpty) {
      final c = Member_.dataTime.equals(dataTime);
      cond = (cond == null) ? c : (cond & c);
    }

    if (number.isNotEmpty) {
      final c = Member_.number.equals(number);
      cond = (cond == null) ? c : (cond & c);
    }

    if (name.isNotEmpty) {
      final c = Member_.name.contains(name, caseSensitive: false);
      cond = (cond == null) ? c : (cond & c);
    }

    if (sex.isNotEmpty) {
      final c = Member_.sex.equals(sex);
      cond = (cond == null) ? c : (cond & c);
    }

    if (rank.isNotEmpty) {
      final c = Member_.rank.equals(rank);
      cond = (cond == null) ? c : (cond & c);
    }

    final qb = objectbox.memberBox.query(cond).build();
    final res = qb.find();
    qb.close();

    res.sort((a, b) => (a.number ?? '').compareTo(b.number ?? ''));
    setState(() => _items = res);
  }

  @override
  void dispose() {
    _numberCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Members'),
        actions: [
          IconButton(
            onPressed: () {
              _loadInitial();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('一覧を再読み込みしました')),
              );
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: 160,
                      child: TextField(
                        controller: _numberCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: '登録番号',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onChanged: (_) => _applyFilters(),
                      ),
                    ),
                    SizedBox(
                      width: 240,
                      child: TextField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(
                          labelText: '名前（部分一致）',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onChanged: (_) => _applyFilters(),
                      ),
                    ),
                    SizedBox(
                      width: 160,
                      child: _buildDropdown(
                        label: '期 (DataTime)',
                        value: _selectedDataTime,
                        items: _dataTimeOptions,
                        onChanged: (v) {
                          setState(() => _selectedDataTime = v);
                          _applyFilters();
                        },
                      ),
                    ),
                    SizedBox(
                      width: 160,
                      child: _buildDropdown(
                        label: '性別',
                        value: _selectedSex,
                        items: _sexOptions,
                        onChanged: (v) {
                          setState(() => _selectedSex = v);
                          _applyFilters();
                        },
                      ),
                    ),
                    SizedBox(
                      width: 160,
                      child: _buildDropdown(
                        label: '級別',
                        value: _selectedRank,
                        items: _rankOptions,
                        onChanged: (v) {
                          setState(() => _selectedRank = v);
                          _applyFilters();
                        },
                      ),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: _resetFilters,
                      icon: const Icon(Icons.clear_all),
                      label: const Text('条件クリア'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _items.isEmpty
                ? const Center(child: Text('該当データがありません'))
                : ListView.separated(
              itemCount: _items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final m = _items[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      ((m.name ?? m.number ?? '?').isNotEmpty)
                          ? (m.name ?? m.number ?? '?')
                          .characters
                          .first
                          : '?',
                    ),
                  ),
                  title: Text(m.name ?? '(no name)'),
                  subtitle: Text([
                    if ((m.number ?? '').isNotEmpty) 'No.${m.number}',
                    if ((m.dataTime ?? '').isNotEmpty) '期:${m.dataTime}',
                    if ((m.sex ?? '').isNotEmpty) '性別:${m.sex}',
                    if ((m.rank ?? '').isNotEmpty) '級別:${m.rank}',
                  ].join('  ')),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MemberDetailPage(member: m),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          objectbox.memberBox.removeAll();
          await _seedIfEmpty();
          _loadInitial();
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

  // 共通ドロップダウン
  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isDense: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('（すべて）'),
        ),
        ...items.map((e) => DropdownMenuItem<String>(
          value: e,
          child: Text(e),
        )),
      ],
      onChanged: onChanged,
    );
  }
}
