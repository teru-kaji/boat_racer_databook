// lib/main.dart
//
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart'; // 追加
import 'objectbox.dart';
import 'models/member.dart';
import 'member_detail_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ObjectBox の保存先ディレクトリを取得
  final dir = await getApplicationDocumentsDirectory();

  // ★ runApp の前に初期化する
  objectbox = await ObjectBox.create(directory: dir.path);

  // JSON を読み込んで初期データ投入（空の場合のみ）
  await _importJsonIfEmpty();

  runApp(const MyApp());
}

Future<void> _importJsonIfEmpty() async {
  if (objectbox.memberBox.isEmpty()) {
    final jsonString = await rootBundle.loadString('assets/members.json');
    final List<dynamic> jsonData = jsonDecode(jsonString);
    final members = jsonData.map((e) => Member.fromJson(e)).toList();
    objectbox.memberBox.putMany(members);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Member Search',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
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
  String? _selectedDataTime;
  List<String> _dataTimeOptions = [];
  String? _selectedRank;
  String? _selectedSex;
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  List<Member> _results = [];

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  void _loadInitial() {
    final all = objectbox.memberBox.getAll();
    _dataTimeOptions = _distinctNonEmpty(all.map((m) => m.dataTime));
    if (_dataTimeOptions.isNotEmpty) {
      _selectedDataTime =
          _dataTimeOptions.reduce((a, b) => a.compareTo(b) > 0 ? a : b);
    }
    _applyFilters();
  }

  List<String> _distinctNonEmpty(Iterable<String?> source) {
    final set = <String>{};
    for (final v in source) {
      final s = (v ?? '').trim();
      if (s.isNotEmpty) set.add(s);
    }
    final list = set.toList()..sort();
    return list;
  }

  void _applyFilters() {
    var results = objectbox.memberBox.getAll();

    if (_selectedDataTime != null && _selectedDataTime!.isNotEmpty) {
      results =
          results.where((m) => m.dataTime == _selectedDataTime).toList();
    }
    if (_numberController.text.isNotEmpty) {
      results = results
          .where((m) =>
          (m.number ?? '').contains(_numberController.text.trim()))
          .toList();
    }
    if (_nameController.text.isNotEmpty) {
      final q = _nameController.text.trim();
      results = results.where((m) {
        return (m.name ?? '').contains(q) ||
            (m.nameKana ?? '').contains(q) ||
            (m.kana3 ?? '').contains(q) ||   // ★ kana3 追加
            (m.kana ?? '').contains(q);      // ★ kana 追加
      }).toList();
    }
    if (_selectedRank != null && _selectedRank!.isNotEmpty) {
      results = results.where((m) => m.rank == _selectedRank).toList();
    }
    if (_selectedSex != null && _selectedSex!.isNotEmpty) {
      results = results.where((m) => m.sex == _selectedSex).toList();
    }

    setState(() {
      _results = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('メンバー検索')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedDataTime,
                    hint: const Text('期を選択'),
                    isExpanded: true,
                    items: _dataTimeOptions
                        .map((dt) =>
                        DropdownMenuItem(value: dt, child: Text(dt)))
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedDataTime = value);
                      _applyFilters();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedRank,
                    hint: const Text('級別を選択'),
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: '', child: Text('')), // ★ 空文字追加
                      DropdownMenuItem(value: 'A1', child: Text('A1')),
                      DropdownMenuItem(value: 'A2', child: Text('A2')),
                      DropdownMenuItem(value: 'B1', child: Text('B1')),
                      DropdownMenuItem(value: 'B2', child: Text('B2')),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedRank = value);
                      _applyFilters();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedSex,
                    hint: const Text('性別を選択'),
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: '', child: Text('')), // ★ 空文字追加
                      DropdownMenuItem(value: '1', child: Text('男性')),
                      DropdownMenuItem(value: '2', child: Text('女性')),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedSex = value);
                      _applyFilters();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _numberController,
                    decoration: const InputDecoration(labelText: '登録番号'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: false,
                      signed: false,
                    ), // ★ テンキーを表示
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly, // ★ 数字のみ許可
                    ],
                    onChanged: (v) => _applyFilters(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: '名前/かな'),
                    onChanged: (v) => _applyFilters(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: _results.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final m = _results[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: (m.sex == "1")
                          ? Colors.blue
                          : (m.sex == "2")
                          ? Colors.pink
                          : Colors.grey,
                      child: Text(
                        ((m.name ?? m.number ?? '?').isNotEmpty)
                            ? (m.name ?? m.number ?? '?')
                            .characters
                            .first
                            : '?',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(m.name ?? '(no name)'),
                    subtitle: Text([
                      if ((m.number ?? '').isNotEmpty) '${m.number}',
                      // if ((m.dataTime ?? '').isNotEmpty)
                      //   '期:${m.dataTime}',
                      // if ((m.sex ?? '').isNotEmpty)
                      //   '性別:${m.sex == "1" ? "男性" : m.sex == "2" ? "女性" : m.sex}',
                      if ((m.rank ?? '').isNotEmpty) '　${m.rank}',
                      if ((m.rankPast1 ?? '').isNotEmpty) '/${m.rankPast1}',
                      if ((m.rankPast2 ?? '').isNotEmpty) '/${m.rankPast2}',
                      if ((m.winPointRate ?? '').isNotEmpty) ' ${m.winPointRate}',
                      if ((m.age ?? '').isNotEmpty) ' ${m.age}',
                      if ((m.blanch ?? '').isNotEmpty) ' ${m.blanch}',
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
      ),
    );
  }
}
