//
// lib/main.dart
//
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'objectbox.dart';
import 'models/member.dart';
import 'member_detail_page.dart';
import 'utils.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  objectbox = await ObjectBox.create(directory: dir.path);
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

    // nullを除いた期リスト作成
    _dataTimeOptions = _distinctNonEmpty(all.map((m) => m.dataTime));

    // ★ 降順にソート（新しい期が先頭）
    _dataTimeOptions.sort((a, b) => b.compareTo(a));

    // ★ 最大値（最新期）を初期選択に
    if (_dataTimeOptions.isNotEmpty) {
      _selectedDataTime = _dataTimeOptions.first;
    }

    // debugPrint('🟦 検索画面 初期選択された期 = $_selectedDataTime');

    _applyFilters();
  }

  List<String> _distinctNonEmpty(Iterable<String?> source) {
    final set = <String>{};
    for (final v in source) {
      final s = (v ?? '').trim();
      if (s.isNotEmpty) set.add(s);
    }
    final list = set.toList()
      ..sort((a, b) => b.compareTo(a)); // ★ 降順に変更！
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
            (m.kana3 ?? '').contains(q) ||
            (m.kana ?? '').contains(q);
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

  /// ★ showSearch() を使った期選択
  Future<void> _selectDataTime(BuildContext context) async {
    if (_dataTimeOptions.isEmpty) return;

    // 現在の値を退避
    final previousValue = _selectedDataTime;

    final selected = await showSearch<String>(
      context: context,
      delegate: _DataTimeSearchDelegate(_dataTimeOptions),
    );

    // ★ null や空文字のときは、元の値を維持
    if (selected == null || selected.isEmpty) {
      setState(() {
        _selectedDataTime = previousValue; // 元に戻す
      });
      return;
    }

    // ★ 有効な値が選ばれた場合のみ上書き
    setState(() {
      _selectedDataTime = selected;
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
            // === 期選択行 ===
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_month),
                    label: Text(
                      _selectedDataTime != null
                          ? formatDataTimePeriod(_selectedDataTime!)
                          : '期を選択',
                      overflow: TextOverflow.ellipsis,
                    ),
                    onPressed: () => _selectDataTime(context),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    value: (_selectedRank == '' ? null : _selectedRank),
                    hint: const Text('級別'),
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: '', child: Text('')),
                      DropdownMenuItem(value: 'A1', child: Text('A1')),
                      DropdownMenuItem(value: 'A2', child: Text('A2')),
                      DropdownMenuItem(value: 'B1', child: Text('B1')),
                      DropdownMenuItem(value: 'B2', child: Text('B2')),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedRank = value);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    value: (_selectedSex == '' ? null : _selectedSex),
                    hint: const Text('性別'),
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: '', child: Text('')),
                      DropdownMenuItem(value: '1', child: Text('男性')),
                      DropdownMenuItem(value: '2', child: Text('女性')),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedSex = value);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // === 入力欄 ===
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _numberController,
                    decoration: const InputDecoration(labelText: '登録番号'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: false,
                      signed: false,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: '名前/かな'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // === 検索ボタン ===
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.search),
                label: const Text('検索'),
                onPressed: _applyFilters,
              ),
            ),

            const SizedBox(height: 12),

            // === 検索結果 ===
            Expanded(
              child: _results.isEmpty
                  ? const Center(child: Text('該当データがありません'))
                  : ListView.separated(
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
                      if ((m.rank ?? '').isNotEmpty) '　${m.rank}',
                      if ((m.rankPast1 ?? '').isNotEmpty)
                        '/${m.rankPast1}',
                      if ((m.rankPast2 ?? '').isNotEmpty)
                        '/${m.rankPast2}',
                      if ((m.winPointRate ?? '').isNotEmpty)
                        ' ${m.winPointRate}',
                      if ((m.age ?? '').isNotEmpty) ' ${m.age}',
                      if ((m.blanch ?? '').isNotEmpty) ' ${m.blanch}',
                    ].join('  ')),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MemberDetailPage(
                            member: m,
                            selectedDataTime: _selectedDataTime, // ★ ここで期を渡す
                          ),
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

/// showSearch() 用の検索デリゲート
class _DataTimeSearchDelegate extends SearchDelegate<String> {
  final List<String> items;
  _DataTimeSearchDelegate(this.items);

  @override
  List<Widget>? buildActions(BuildContext context) =>
      [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, ''),
  );

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    final filtered = items.where((e) => e.contains(query)).toList();
    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (_, i) {
        final dt = filtered[i];
        final label = formatDataTimePeriod(dt);  // ← ★ 変換して表示
        return ListTile(
          title: Text(label),
          subtitle: Text(dt),  // ← 元のデータも小さく表示しておくと便利
          onTap: () => close(context, dt),
        );
      },
    );
  }
}
