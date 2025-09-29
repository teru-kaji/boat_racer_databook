// lib/member_detail_page.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'models/member.dart';
import 'member_history_page.dart';
import 'objectbox.dart';

class MemberDetailPage extends StatefulWidget {
  final Member member;
  const MemberDetailPage({super.key, required this.member});

  @override
  State<MemberDetailPage> createState() => _MemberDetailPageState();
}

class _MemberDetailPageState extends State<MemberDetailPage> {
  late List<Member> _history;
  late List<String> _dataTimeOptions;
  String? _selectedDataTime;
  late Member _selectedMember;

  @override
  void initState() {
    super.initState();
    // 同じ登録番号の履歴を取得
    _history = objectbox.memberBox
        .getAll()
        .where((m) => m.number == widget.member.number)
        .toList();

    // dataTime順にソート
    _history.sort((a, b) => (a.dataTime ?? '').compareTo(b.dataTime ?? ''));

    // プルダウン用の期リスト
    _dataTimeOptions = _history
        .map((m) => m.dataTime ?? '')
        .where((s) => s.isNotEmpty)
        .toList();

    // 初期値: 最新の期
    if (_dataTimeOptions.isNotEmpty) {
      _selectedDataTime = _dataTimeOptions.last;
      _selectedMember =
          _history.firstWhere((m) => m.dataTime == _selectedDataTime);
    } else {
      _selectedMember = widget.member;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rows = _buildCourseRows(_selectedMember);
    final totals = _calcTotals(rows);

    final List<double> winRates =
    rows.map((r) => r.winRate12 ?? 0.0).toList();
    final List<double> starts =
    rows.map((r) => r.startTime ?? 0.0).toList();
    final List<int> firsts =
    rows.map((r) => r.first ?? 0).toList();
    final List<int> seconds =
    rows.map((r) => r.second ?? 0).toList();
    final List<int> thirds =
    rows.map((r) => r.third ?? 0).toList();

    return Scaffold(
      appBar: AppBar(title: Text(_selectedMember.name ?? '詳細情報')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === 期選択プルダウン + ボタン ===
            if (_dataTimeOptions.isNotEmpty)
              Row(
                children: [
                  const Text("期を選択: "),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButton<String>(
                      value: _selectedDataTime,
                      isExpanded: true,
                      items: _dataTimeOptions
                          .map((dt) =>
                          DropdownMenuItem(value: dt, child: Text(dt)))
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _selectedDataTime = value;
                          _selectedMember = _history
                              .firstWhere((m) => m.dataTime == value);
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              MemberHistoryPage(member: _selectedMember),
                        ),
                      );
                    },
                    child: const Text('期ごとの成績を表示'),
                  ),
                ],
              ),

            const SizedBox(height: 12),

            if ((_selectedMember.photo ?? '').isNotEmpty)
              Center(
                child: Image.network(
                  _selectedMember.photo!,
                  height: 180,
                  errorBuilder: (_, __, ___) =>
                  const Icon(Icons.person, size: 96),
                ),
              ),

            const SizedBox(height: 16),

            const SizedBox(height: 16),

// === プロフィール（シンプル2列表示） ===
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 6.0, // 行の高さを少し余裕ありに
              crossAxisSpacing: 8,
              mainAxisSpacing: 4,
              children: [
                _infoText('登録番号', _selectedMember.number),
                _infoText(
                  '級',
                  '${_selectedMember.rank ?? "-"} / ${_selectedMember.rankPast1 ?? "-"} / ${_selectedMember.rankPast2 ?? "-"} / ${_selectedMember.rankPast3 ?? "-"}',
                ),
                _infoText('名前', _selectedMember.name),
                _infoText('かな', _selectedMember.kana3),
                _infoText('支部', _selectedMember.blanch),
                _infoText('出身地', _selectedMember.birthplace),
                _infoText('誕生日', _selectedMember.gBirthday),
                _infoText(
                  '性別',
                  _selectedMember.sex == "1"
                      ? "男性"
                      : _selectedMember.sex == "2"
                      ? "女性"
                      : _selectedMember.sex,
                ),
                _infoText('年齢', _selectedMember.age),
                _infoText('身長', _selectedMember.height),
                _infoText('体重', _selectedMember.weight),
                _infoText('血液', _selectedMember.blood),
                _infoText('勝率', _selectedMember.winPointRate),
                _infoText('複勝率', _selectedMember.winRate12),
                _infoText('1着回数', _selectedMember.firstPlaceCount),
                _infoText('2着回数', _selectedMember.secondPlaceCount),
                _infoText('出走回数', _selectedMember.numberOfRace),
                _infoText('優出回数', _selectedMember.numberOfFinals),
                _infoText('優勝回数', _selectedMember.numberOfWins),
                _infoText('平均ST', _selectedMember.startTiming),
                _infoText(
                  '能力指数',
                    '${_selectedMember.lastAbilityScore ?? "-"} / ${_selectedMember.pastAbilityScore ?? "-"}',
                )
        //        _infoText('前期能力指数', _selectedMember.pastAbilityScore),
        //        _infoText('今期能力指数', _selectedMember.lastAbilityScore),
              ],
            ),

            const SizedBox(height: 24),

            Text('コース別 成績（表）',
                style: Theme.of(context).textTheme.titleLarge),
            _courseTable(context, rows, totals),

            SizedBox(height: 20),
            Text(
              "コース別事故件数",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _buildAccidentTable(_selectedMember), // ← 修正
            ),


            const SizedBox(height: 24),
            Text('コース別 複勝率（%）',
                style: Theme.of(context).textTheme.titleLarge),
            _barChartSingle(
              context: context,
              titleY: '複勝率(%)',
              values: winRates,
              maxY: _niceMax(winRates, base: 100, minMax: 20),
              formatY: (v) => v.toStringAsFixed(0),
            ),

            const SizedBox(height: 24),
            Text('コース別 スタートタイミング',
                style: Theme.of(context).textTheme.titleLarge),
            _lineChartPoints(
              context: context,
              values: starts,
            ),

            const SizedBox(height: 24),
            Text('コース別 1着・2着・3着数',
                style: Theme.of(context).textTheme.titleLarge),
            _barChartStacked(
              context: context,
              firsts: firsts,
              seconds: seconds,
              thirds: thirds,
              maxY: _niceMax([...firsts, ...seconds, ...thirds],
                  base: 10, minMax: 5),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// === プロフィール表示ヘルパー（2列タイル） ===
  Widget _infoText(String label, String? value) {
    return Text(
      "$label : ${(value == null || value.isEmpty) ? '-' : value}",
      style: const TextStyle(fontSize: 15),
    );
  }

  // === 以下は従来のメソッド（_courseTable, グラフ系, _buildCourseRows, _calcTotals, etc.） ===
  // （前回提示したものと同じですので省略せずそのまま残してください）

  Widget _courseTable(BuildContext context, List<_CourseRow> rows, _Totals totals) {
    // ...（従来通り）
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('コース')),
          DataColumn(label: Text('出走')),
          DataColumn(label: Text('ST平均')),
          DataColumn(label: Text('複勝率')),
          DataColumn(label: Text('1着')),
          DataColumn(label: Text('2着')),
          DataColumn(label: Text('3着')),
          DataColumn(label: Text('1-3合計')),
        ],
        rows: [
          for (final r in rows)
            DataRow(cells: [
              DataCell(Text('${r.lane}')),
              DataCell(Text(_fmtInt(r.entries))),
              DataCell(Text(_fmtDouble(r.startTime))),
              DataCell(Text(_fmtPercent(r.winRate12))),
              DataCell(Text(_fmtInt(r.first))),
              DataCell(Text(_fmtInt(r.second))),
              DataCell(Text(_fmtInt(r.third))),
              DataCell(Text(
                  '${(r.first ?? 0) + (r.second ?? 0) + (r.third ?? 0)}')),
            ]),
        ],
      ),
    );
  }

// グラフ描画メソッド (_barChartSingle, _lineChartPoints, _barChartStacked, _legendItem)
// _buildCourseRows, _calcTotals, _fmtInt/_fmtDouble/_fmtPercent/_niceMax
// は前回提示した完全版と同じです。
}

/// === グラフ描画メソッド ===
  Widget _barChartSingle({
    required BuildContext context,
    required String titleY,
    required List<double> values,
    required double maxY,
    required String Function(double) formatY,
  }) {
    return SizedBox(
      height: 260,
      child: BarChart(
        BarChartData(
          maxY: 100,
          minY: 0,
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 44,
                getTitlesWidget: (v, meta) =>
                    Text(formatY(v), style: const TextStyle(fontSize: 11)),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (v, meta) {
                  if (v < 0 || v > values.length - 1) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text('${v.toInt() + 1}',
                        style: const TextStyle(fontSize: 11)),
                  );
                },
              ),
            ),
            topTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          barGroups: List.generate(values.length, (i) {
            final y = values[i].isNaN ? 0.0 : values[i];
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: y,
                  width: 20,
                  color: Colors.blue,
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _lineChartPoints({
    required BuildContext context,
    required List<double> values,
  }) {
    final negSpots = <FlSpot>[];
    for (int i = 0; i < values.length; i++) {
      final v = values[i];
      if (v != 0) {
        negSpots.add(FlSpot(i.toDouble(), -v));
      }
    }

    return SizedBox(
      height: 260,
      child: LineChart(
        LineChartData(
          minX: -0.5,
          maxX: values.length - 0.5,
          minY: -0.4,
          maxY: 0,
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 44,
                interval: 0.1,
                getTitlesWidget: (v, meta) =>
                    Text(v.toStringAsFixed(2),
                        style: const TextStyle(fontSize: 11)),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (v, meta) {
                  if (v < 0 || v > values.length - 1) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text('${v.toInt() + 1}',
                        style: const TextStyle(fontSize: 11)),
                  );
                },
              ),
            ),
            topTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: negSpots,
              isCurved: false,
              barWidth: 0,
              color: Colors.red,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(
                      radius: 6,
                      color: Colors.red,
                      strokeWidth: 0,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _barChartStacked({
    required BuildContext context,
    required List<int> firsts,
    required List<int> seconds,
    required List<int> thirds,
    required double maxY,
  }) {
    return Column(
      children: [
        SizedBox(
          height: 260,
          child: BarChart(
            BarChartData(
              maxY: 50,
              minY: 0,
              gridData: FlGridData(show: true),
              borderData: FlBorderData(
                show: false,
                border: Border.all(color: Colors.black, width: 1),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    getTitlesWidget: (v, meta) => Text(
                      v.toInt().toString(),
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (v, meta) {
                      if (v < 0 || v > 5) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text('${v.toInt() + 1}',
                            style: const TextStyle(fontSize: 11)),
                      );
                    },
                  ),
                ),
                topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              barGroups: List.generate(6, (i) {
                final f = (firsts.length > i ? firsts[i] : 0).toDouble();
                final s = (seconds.length > i ? seconds[i] : 0).toDouble();
                final t = (thirds.length > i ? thirds[i] : 0).toDouble();
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: f + s + t,
                      width: 20,
                      rodStackItems: [
                        BarChartRodStackItem(0, f, Colors.blue),
                        BarChartRodStackItem(f, f + s, Colors.green),
                        BarChartRodStackItem(f + s, f + s + t, Colors.orange),
                      ],
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          children: [
            _legendItem(color: Colors.blue, label: '1着'),
            _legendItem(color: Colors.green, label: '2着'),
            _legendItem(color: Colors.orange, label: '3着'),
          ],
        ),
      ],
    );
  }

  Widget _legendItem({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }

  /// === 補助メソッド ===

  List<_CourseRow> _buildCourseRows(Member m) {
    int? toInt(String? s) => int.tryParse((s ?? '').trim());
    double? toDoubleRaw(String? s) {
      final raw = (s ?? '').trim().replaceAll('%', '');
      if (raw.isEmpty) return null;
      return double.tryParse(raw);
    }

    double? toPercent(String? s) {
      final v = toDoubleRaw(s);
      if (v == null) return null;
      return v <= 1.0 ? v * 100.0 : v;
    }

    return [
      _CourseRow(lane: 1, entries: toInt(m.numberOfEntries1), startTime: toDoubleRaw(m.startTime1), winRate12: toPercent(m.winRate121), first: toInt(m.firstPlace1), second: toInt(m.secondPlace1), third: toInt(m.thirdPlace1)),
      _CourseRow(lane: 2, entries: toInt(m.numberOfEntries2), startTime: toDoubleRaw(m.startTime2), winRate12: toPercent(m.winRate122), first: toInt(m.firstPlace2), second: toInt(m.secondPlace2), third: toInt(m.thirdPlace2)),
      _CourseRow(lane: 3, entries: toInt(m.numberOfEntries3), startTime: toDoubleRaw(m.startTime3), winRate12: toPercent(m.winRate123), first: toInt(m.firstPlace3), second: toInt(m.secondPlace3), third: toInt(m.thirdPlace3)),
      _CourseRow(lane: 4, entries: toInt(m.numberOfEntries4), startTime: toDoubleRaw(m.startTime4), winRate12: toPercent(m.winRate124), first: toInt(m.firstPlace4), second: toInt(m.secondPlace4), third: toInt(m.thirdPlace4)),
      _CourseRow(lane: 5, entries: toInt(m.numberOfEntries5), startTime: toDoubleRaw(m.startTime5), winRate12: toPercent(m.winRate125), first: toInt(m.firstPlace5), second: toInt(m.secondPlace5), third: toInt(m.thirdPlace5)),
      _CourseRow(lane: 6, entries: toInt(m.numberOfEntries6), startTime: toDoubleRaw(m.startTime6), winRate12: toPercent(m.winRate126), first: toInt(m.firstPlace6), second: toInt(m.secondPlace6), third: toInt(m.thirdPlace6)),
    ];
  }

  _Totals _calcTotals(List<_CourseRow> rows) {
    int add(int acc, int? v) => acc + (v ?? 0);
    var entries = 0, first = 0, second = 0, third = 0;
    for (final r in rows) {
      entries = add(entries, r.entries);
      first = add(first, r.first);
      second = add(second, r.second);
      third = add(third, r.third);
    }
    return _Totals(entries: entries, first: first, second: second, third: third);
  }

  String _fmtInt(int? v) => v?.toString() ?? '-';
  String _fmtDouble(double? v) => (v == null) ? '-' : v.toStringAsFixed(2);
  String _fmtPercent(double? v) => v == null ? '-' : '${v.toStringAsFixed(1)}%';

  double _niceMax(List<num> values, {required double base, required double minMax}) {
    if (values.isEmpty) return minMax;
    final doubles = values.map((e) => e.toDouble()).toList();
    final maxVal = doubles.reduce((a, b) => a > b ? a : b);
    final padded = (maxVal * 1.2);
    final step = base;
    final mul = (padded / step).ceil();
    return (mul * step).clamp(minMax, double.infinity);
  }


class _CourseRow {
  final int lane;
  final int? entries, first, second, third;
  final double? startTime, winRate12;
  _CourseRow({required this.lane, this.entries, this.startTime, this.winRate12, this.first, this.second, this.third});
}

class _Totals {
  final int entries, first, second, third;
  _Totals({required this.entries, required this.first, required this.second, required this.third});
}

// コース別事故件数テーブルを作成するWidget
Widget _buildAccidentTable(Member member) {
  return DataTable(
    columnSpacing: 12,
    columns: const [
      DataColumn(label: Text("コース")),
      DataColumn(label: Text("F")),
      DataColumn(label: Text("L0")),
      DataColumn(label: Text("L1")),
      DataColumn(label: Text("K0")),
      DataColumn(label: Text("K1")),
      DataColumn(label: Text("S0")),
      DataColumn(label: Text("S1")),
      DataColumn(label: Text("S2")),
    ],
    rows: [
      DataRow(cells: [
        const DataCell(Text("1")),
        DataCell(Text(member.falseStart1.toString())),
        DataCell(Text(member.lateStartNoResponsibility1.toString())),
        DataCell(Text(member.lateStartOnResponsibility1.toString())),
        DataCell(Text(member.withdrawNoResponsibility1.toString())),
        DataCell(Text(member.withdrawOnResponsibility1.toString())),
        DataCell(Text(member.invalidNoResponsibility1.toString())),
        DataCell(Text(member.invalidOnResponsibility1.toString())),
        DataCell(Text(member.invalidOnObstruction1.toString())),
      ]),
      DataRow(cells: [
        const DataCell(Text("2")),
        DataCell(Text(member.falseStart2.toString())),
        DataCell(Text(member.lateStartNoResponsibility2.toString())),
        DataCell(Text(member.lateStartOnResponsibility2.toString())),
        DataCell(Text(member.withdrawNoResponsibility2.toString())),
        DataCell(Text(member.withdrawOnResponsibility2.toString())),
        DataCell(Text(member.invalidNoResponsibility2.toString())),
        DataCell(Text(member.invalidOnResponsibility2.toString())),
        DataCell(Text(member.invalidOnObstruction2.toString())),
      ]),
      DataRow(cells: [
        const DataCell(Text("3")),
        DataCell(Text(member.falseStart3.toString())),
        DataCell(Text(member.lateStartNoResponsibility3.toString())),
        DataCell(Text(member.lateStartOnResponsibility3.toString())),
        DataCell(Text(member.withdrawNoResponsibility3.toString())),
        DataCell(Text(member.withdrawOnResponsibility3.toString())),
        DataCell(Text(member.invalidNoResponsibility3.toString())),
        DataCell(Text(member.invalidOnResponsibility3.toString())),
        DataCell(Text(member.invalidOnObstruction3.toString())),
      ]),
      DataRow(cells: [
        const DataCell(Text("4")),
        DataCell(Text(member.falseStart4.toString())),
        DataCell(Text(member.lateStartNoResponsibility4.toString())),
        DataCell(Text(member.lateStartOnResponsibility4.toString())),
        DataCell(Text(member.withdrawNoResponsibility4.toString())),
        DataCell(Text(member.withdrawOnResponsibility4.toString())),
        DataCell(Text(member.invalidNoResponsibility4.toString())),
        DataCell(Text(member.invalidOnResponsibility4.toString())),
        DataCell(Text(member.invalidOnObstruction4.toString())),
      ]),
      DataRow(cells: [
        const DataCell(Text("5")),
        DataCell(Text(member.falseStart5.toString())),
        DataCell(Text(member.lateStartNoResponsibility5.toString())),
        DataCell(Text(member.lateStartOnResponsibility5.toString())),
        DataCell(Text(member.withdrawNoResponsibility5.toString())),
        DataCell(Text(member.withdrawOnResponsibility5.toString())),
        DataCell(Text(member.invalidNoResponsibility5.toString())),
        DataCell(Text(member.invalidOnResponsibility5.toString())),
        DataCell(Text(member.invalidOnObstruction5.toString())),
      ]),
      DataRow(cells: [
        const DataCell(Text("6")),
        DataCell(Text(member.falseStart6.toString())),
        DataCell(Text(member.lateStartNoResponsibility6.toString())),
        DataCell(Text(member.lateStartOnResponsibility6.toString())),
        DataCell(Text(member.withdrawNoResponsibility6.toString())),
        DataCell(Text(member.withdrawOnResponsibility6.toString())),
        DataCell(Text(member.invalidNoResponsibility6.toString())),
        DataCell(Text(member.invalidOnResponsibility6.toString())),
        DataCell(Text(member.invalidOnObstruction6.toString())),
      ]),
    ],
  );
}
