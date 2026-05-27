// lib/member_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'objectbox.dart';
import 'models/member.dart';
import 'member_detail_page.dart';
import 'utils.dart';
import 'objectbox.g.dart';

class MemberListPage extends StatefulWidget {
  const MemberListPage({super.key});

  @override
  State<MemberListPage> createState() => _MemberListPageState();
}

class _MemberListPageState extends State<MemberListPage> {
  // --- Font Size Constants ---
  static const double _kListItemTitleSize = 16.0;
  static const double _kListItemSubtitleSize = 14.0;
  // ---

  String? _selectedDataTime;
  List<String> _dataTimeOptions = [];
  String? _selectedRank;
  String? _selectedSex;
  String? _selectedGeneration;
  List<String> _generationOptions = [];
  String? _selectedBranch;
  List<String> _branchOptions = [];

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
    _dataTimeOptions.sort((a, b) => b.compareTo(a));
    if (_dataTimeOptions.isNotEmpty) {
      _selectedDataTime = _dataTimeOptions.first;
    }

    _generationOptions = _distinctNonEmpty(all.map((m) => m.generation?.toString()));
    _generationOptions.sort((a, b) => (int.tryParse(a) ?? 0).compareTo(int.tryParse(b) ?? 0));

    _branchOptions = _distinctNonEmpty(all.map((m) => m.branch));

    _applyFilters();
  }

  List<String> _distinctNonEmpty(Iterable<String?> source) {
    final set = <String>{};
    for (final v in source) {
      final s = (v ?? '').trim();
      if (s.isNotEmpty) set.add(s);
    }
    return set.toList()..sort();
  }

  void _applyFilters() {
    final conditions = <Condition<Member>>[];

    if (_selectedDataTime != null && _selectedDataTime!.isNotEmpty) {
      conditions.add(Member_.dataTime.equals(_selectedDataTime!));
    }
    if (_selectedRank != null && _selectedRank!.isNotEmpty) {
      conditions.add(Member_.rank.equals(_selectedRank!));
    }
    if (_selectedSex != null && _selectedSex!.isNotEmpty) {
      final sexInt = int.tryParse(_selectedSex!);
      if (sexInt != null) conditions.add(Member_.sex.equals(sexInt));
    }
    if (_selectedGeneration != null && _selectedGeneration!.isNotEmpty) {
      final genInt = int.tryParse(_selectedGeneration!);
      if (genInt != null) conditions.add(Member_.generation.equals(genInt));
    }
    if (_selectedBranch != null && _selectedBranch!.isNotEmpty) {
      conditions.add(Member_.branch.equals(_selectedBranch!));
    }

    if (_numberController.text.isNotEmpty) {
      conditions.add(Member_.number.contains(_numberController.text.trim()));
    }

    if (_nameController.text.isNotEmpty) {
      final q = _nameController.text.trim();
      conditions.add(Member_.name.contains(q)
          .or(Member_.nameKana.contains(q))
          .or(Member_.kana3.contains(q))
          .or(Member_.kana.contains(q)));
    }

    final finalCondition = conditions.isEmpty ? null : conditions.reduce((a, b) => a.and(b));

    final query = objectbox.memberBox.query(finalCondition).build();
    final results = query.find();

    setState(() {
      _results = results;
    });
  }

  Future<void> _selectDataTime(BuildContext context) async {
    if (_dataTimeOptions.isEmpty) return;
    final selected = await showSearch<String>(
      context: context,
      delegate: _DataTimeSearchDelegate(_dataTimeOptions),
    );
    if (selected != null && selected.isNotEmpty) {
      setState(() => _selectedDataTime = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('レーサー検索')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1行目: 期選択
            SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.calendar_month),
                label: Text(
                  _selectedDataTime != null
                      ? formatDataTimePeriod(_selectedDataTime!)
                      : '期を選択',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: _kListItemTitleSize),
                ),
                onPressed: () => _selectDataTime(context),
              ),
            ),
            const SizedBox(height: 8),
            // 2行目: 級別, 性別, 育成期, 支部
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedRank == '' ? null : _selectedRank,
                    hint: const Text('級別'),
                    isExpanded: true,
                    items: ['', 'A1', 'A2', 'B1', 'B2']
                        .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedRank = value),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedSex == '' ? null : _selectedSex,
                    hint: const Text('性別'),
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: '', child: Text('')),
                      DropdownMenuItem(value: '1', child: Text('男子')),
                      DropdownMenuItem(value: '2', child: Text('女子')),
                    ],
                    onChanged: (value) => setState(() => _selectedSex = value),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedGeneration == '' ? null : _selectedGeneration,
                    hint: const Text('育成期'),
                    isExpanded: true,
                    items: ['', ..._generationOptions]
                        .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedGeneration = value),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedBranch == '' ? null : _selectedBranch,
                    hint: const Text('支部'),
                    isExpanded: true,
                    items: ['', ..._branchOptions]
                        .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedBranch = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 3行目: 登録番号, 名前
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _numberController,
                    decoration: const InputDecoration(labelText: '登録番号'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: '名前(漢字/かな)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.search),
                  label: const Text('検索'),
                  onPressed: _applyFilters,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('該当数: ${_results.length}名'),
            const SizedBox(height: 8),
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
                            backgroundColor: (m.sex == 1)
                                ? Colors.blue
                                : (m.sex == 2)
                                    ? Colors.pink
                                    : Colors.grey,
                            child: Text(
                              m.name?.isNotEmpty == true ? m.name![0] : '?',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(m.name ?? '(no name)', style: const TextStyle(fontSize: _kListItemTitleSize)),
                          subtitle: Text(
                            [
                              if (m.number?.isNotEmpty == true) m.number,
                              if (m.rank?.isNotEmpty == true) ' ${m.rank}',
                              if (m.winPointRate != null)
                                ' ${m.winPointRate!.toStringAsFixed(2)}',
                              if (m.weight != null) ' ${m.weight}Kg',
                              if (m.age != null) ' ${m.age}才',
                              if (m.branch?.isNotEmpty == true) ' ${m.branch}',
                            ].join('  '),
                            style: const TextStyle(fontSize: _kListItemSubtitleSize, color: Colors.black54),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MemberDetailPage(memberId: m.id),
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

class _DataTimeSearchDelegate extends SearchDelegate<String> {
  final List<String> items;

  _DataTimeSearchDelegate(this.items);

  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
      ];

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
        final label = formatDataTimePeriod(dt);
        return ListTile(
          title: Text(label),
          subtitle: Text('$dt (${dataTimeToTerm(dt).join(' 〜 ')})'),
          onTap: () => close(context, dt),
        );
      },
    );
  }
}
