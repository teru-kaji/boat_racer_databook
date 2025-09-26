//
// lib/member_detail_page.dart
//
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'models/member.dart';
import 'member_history_page.dart';

class MemberDetailPage extends StatelessWidget {
  final Member member;
  const MemberDetailPage({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    final rows = _buildCourseRows(member);
    final totals = _calcTotals(rows);

    // グラフ用データ
    final winRates = rows.map((r) => r.winRate12 ?? 0).toList();
    final starts   = rows.map((r) => r.startTime ?? 0).toList();
    final firsts   = rows.map((r) => r.first ?? 0).toList();
    final seconds  = rows.map((r) => r.second ?? 0).toList();
    final thirds   = rows.map((r) => r.third ?? 0).toList();

    return Scaffold(
      appBar: AppBar(title: Text(member.name ?? '詳細情報')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((member.photo ?? '').isNotEmpty)
              Center(
                child: Image.network(
                  member.photo!,
                  height: 180,
                  errorBuilder: (_, __, ___) =>
                  const Icon(Icons.person, size: 96),
                ),
              ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MemberHistoryPage(member: member),
                    ),
                  );
                },
                child: const Text('期ごとの成績を表示'),
              ),
            ),
            const SizedBox(height: 12),
            _field('登録番号', member.number),
            _field('名前', member.name),
            _field('カナ', member.nameKana ?? member.kana2 ?? member.kana),
            _field('期 (DataTime)', member.dataTime),
            _field(
              '性別',
              member.sex == "1"
                  ? "男性"
                  : member.sex == "2"
                  ? "女性"
                  : member.sex,
            ),
            _field('級別', member.rank),

            const SizedBox(height: 24),
            Text('コース別 成績（表）',
                style: Theme.of(context).textTheme.titleLarge),
            _courseTable(context, rows, totals),

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

  Widget _field(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _courseTable(BuildContext context, List<_CourseRow> rows, _Totals totals) {
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
              DataCell(Text('${(r.first ?? 0) + (r.second ?? 0) + (r.third ?? 0)}')),
            ]),
        ],
      ),
    );
  }

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
          //maxY: maxY,
          maxY: 100,
          minY: 0,
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 44,
                getTitlesWidget: (v, meta) => Text(formatY(v), style: const TextStyle(fontSize: 11)),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (v, meta) {
                  if (v < 0 || v > values.length - 1) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text('${v.toInt() + 1}', style: const TextStyle(fontSize: 11)),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          barGroups: List.generate(values.length, (i) {
            final y = values[i].isNaN ? 0.0 : values[i];
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: y,
                  width: 20,
                  color: Colors.blue, // ★ 棒の色を青に固定
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  /// -1倍プロット
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
                getTitlesWidget: (v, meta) => Text(v.toStringAsFixed(2), style: const TextStyle(fontSize: 11)),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (v, meta) {
                  if (v < 0 || v > values.length - 1) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text('${v.toInt() + 1}', style: const TextStyle(fontSize: 11)),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                    FlDotCirclePainter(                // ← 丸点
                      radius: 6,                        // ★ 半径を大きく
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
          //    maxY: maxY,
              maxY: 50,
              minY: 0,
              gridData: FlGridData(show: true),
              borderData: FlBorderData(
                show: false,
                border: Border.all(color: Colors.black, width: 1), // 外枠
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
                        BarChartRodStackItem(0, f, Colors.blue),       // 1着
                        BarChartRodStackItem(f, f + s, Colors.green),  // 2着
                        BarChartRodStackItem(f + s, f + s + t, Colors.orange), // 3着
                      ],
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // ==== 凡例 ====
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

  /// 凡例用ウィジェット
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
