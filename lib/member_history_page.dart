//
// lib/member_history_page.dart
//
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'models/member.dart';
import 'objectbox.dart'; // グローバル objectbox を利用
import 'utils.dart';

class MemberHistoryPage extends StatelessWidget {
  final Member member;

  // --- Font Size Constants ---
  static const double _kTitleFontSize = 16.0;
  static const double _kChartLabelFontSize = 14.0;
  // ---

  const MemberHistoryPage({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    // 同じ登録番号の履歴を取得
    final all = objectbox.memberBox
        .getAll()
        .where((m) => m.number == member.number)
        .toList();

    // dataTime 順にソート（昇順）
    all.sort((a, b) => (a.dataTime ?? '').compareTo(b.dataTime ?? ''));

    // X軸ラベル（期）
    final terms = all.map((m) => m.dataTime ?? '').toList();

    // 得点率
    final scoreRates = all.map((m) {
      final v = double.tryParse((m.winPointRate ?? '').replaceAll('%', ''));
      return v ?? 0;
    }).toList();

    // 複勝率
    final winRates = all.map((m) {
      final v = double.tryParse((m.winRate12 ?? '').replaceAll('%', ''));
      return v ?? 0.0;
    }).toList();

    // 級別を数値化（例：A1=4, A2=3, B1=2, B2=1）
    int rankToNum(String? r) {
      switch (r) {
        case 'A1':
          return 4;
        case 'A2':
          return 3;
        case 'B1':
          return 2;
        case 'B2':
          return 1;
        default:
          return 0;
      }
    }

    final ranks = all.map((m) => rankToNum(m.rank)).toList();

    return Scaffold(
      appBar: AppBar(title: Text('${member.name ?? ''} の期ごとの成績')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '得点率',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: _kTitleFontSize),
            ),
            SizedBox(
              height: 260, // Increased height
              child: _lineChart(terms, scoreRates, '得点率', Colors.blue),
            ),

            const SizedBox(height: 24),
            const Text(
              '複勝率',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: _kTitleFontSize),
            ),
            SizedBox(
              height: 260, // Increased height
              child: _lineChart(terms, winRates, '複勝率', Colors.green),
            ),

            const SizedBox(height: 24),
            const Text(
              '級別の推移',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: _kTitleFontSize),
            ),
            SizedBox(
              height: 260, // Increased height
              child: _rankChart(terms, ranks),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// 一般的な折れ線グラフ
  Widget _lineChart(
      List<String> terms,
      List<num> values,
      String label,
      Color color, {
        bool isInt = false,
      }) {
    if (values.isEmpty) {
      return const Center(child: Text('データがありません'));
    }

    final chart = LineChart(
      LineChartData(
        minX: 0,
        maxX: (values.length - 1).toDouble(),
        minY: 0,
        maxY: values.map((e) => e.toDouble()).reduce((a, b) => a > b ? a : b) * 1.2,
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),     // ★ 外枠を非表示
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final flSpot = barSpot;
                final textStyle = TextStyle(
                  color: flSpot.bar.gradient?.colors.first ??
                      flSpot.bar.color ??
                      Colors.blueGrey,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                );
                String text;
                if (label == '複勝率') {
                  text = '${(flSpot.y * 100).toStringAsFixed(1)}%';
                } else {
                  text = flSpot.y.toStringAsFixed(1);
                }
                return LineTooltipItem(
                  text,
                  textStyle,
                );
              }).toList();
            },
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 60, // Adjusted for 45 degree rotation
              getTitlesWidget: (v, meta) {
                if (v < 0 || v > terms.length - 1) {
                  return const SizedBox.shrink();
                }
                final index = v.toInt();
                var labelText = formatDataTimePeriod(terms[index]);
                if (labelText.length > 2) {
                  labelText = labelText.substring(2);
                }
                // Changed from RotatedBox to Transform.rotate for 45 degree angle
                return Transform.rotate(
                  angle: -math.pi / 4, // -45 degrees
                  alignment: Alignment.centerRight,
                  child: Text(
                    labelText,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: _kChartLabelFontSize),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50, // Increased reserved size for longer labels
              getTitlesWidget: (v, meta) {
                final String text;
                if (label == '複勝率') {
                  text = '${(v * 100).toStringAsFixed(1)}%';
                } else {
                  text = isInt ? v.toInt().toString() : v.toStringAsFixed(1);
                }
                return Text(
                  text,
                  style: const TextStyle(fontSize: _kChartLabelFontSize),
                );
              },
            ),
          ),
          topTitles:
          const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50, // Increased reserved size for longer labels
              getTitlesWidget: (v, meta) {
                final String text;
                if (label == '複勝率') {
                  text = '${(v * 100).toStringAsFixed(1)}%';
                } else {
                  text = isInt ? v.toInt().toString() : v.toStringAsFixed(1);
                }
                return Text(
                  text,
                  style: const TextStyle(fontSize: _kChartLabelFontSize),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (int i = 0; i < values.length; i++)
                FlSpot(i.toDouble(), values[i].toDouble()),
            ],
            isCurved: false,
            barWidth: 2,
            dotData: FlDotData(show: true),
            color: color,
          ),
        ],
      ),
    );

    return _AutoScrolledHorizontalChart(
      chart: chart,
      width: terms.length * 60.0, // Adjusted width for rotated labels
    );
  }

  /// rank 用折れ線グラフ
  Widget _rankChart(List<String> terms, List<int> ranks) {
    if (ranks.isEmpty) {
      return const Center(child: Text('データがありません'));
    }

    final chart = LineChart(
      LineChartData(
        minX: 0,
        maxX: (terms.length - 1).toDouble(),
        minY: 0,
        maxY: 5,
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false), // ★ 外枠を非表示
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final flSpot = barSpot;
                final textStyle = TextStyle(
                  color: flSpot.bar.gradient?.colors.first ??
                      flSpot.bar.color ??
                      Colors.blueGrey,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                );

                String text;
                switch (flSpot.y.toInt()) {
                  case 1:
                    text = 'B2';
                    break;
                  case 2:
                    text = 'B1';
                    break;
                  case 3:
                    text = 'A2';
                    break;
                  case 4:
                    text = 'A1';
                    break;
                  default:
                    text = '';
                    break;
                }

                return LineTooltipItem(
                  text,
                  textStyle,
                );
              }).toList();
            },
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 60, // Adjusted for 45 degree rotation
              getTitlesWidget: (v, meta) {
                if (v < 0 || v > terms.length - 1) {
                  return const SizedBox.shrink();
                }
                final index = v.toInt();
                var label = formatDataTimePeriod(terms[index]);
                if (label.length > 2) {
                  label = label.substring(2);
                }
                // Changed from RotatedBox to Transform.rotate for 45 degree angle
                return Transform.rotate(
                  angle: -math.pi / 4, // -45 degrees
                  alignment: Alignment.centerRight,
                  child: Text(
                    label,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: _kChartLabelFontSize),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 40,
              getTitlesWidget: (v, meta) {
                switch (v.toInt()) {
                  case 1:
                    return const Text('B2', style: TextStyle(fontSize: _kChartLabelFontSize));
                  case 2:
                    return const Text('B1', style: TextStyle(fontSize: _kChartLabelFontSize));
                  case 3:
                    return const Text('A2', style: TextStyle(fontSize: _kChartLabelFontSize));
                  case 4:
                    return const Text('A1', style: TextStyle(fontSize: _kChartLabelFontSize));
                  default:
                    return const Text('');
                }
              },
            ),
          ),
          topTitles:
          const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 40,
              getTitlesWidget: (v, meta) {
                switch (v.toInt()) {
                  case 1:
                    return const Text('B2', style: TextStyle(fontSize: _kChartLabelFontSize));
                  case 2:
                    return const Text('B1', style: TextStyle(fontSize: _kChartLabelFontSize));
                  case 3:
                    return const Text('A2', style: TextStyle(fontSize: _kChartLabelFontSize));
                  case 4:
                    return const Text('A1', style: TextStyle(fontSize: _kChartLabelFontSize));
                  default:
                    return const Text('');
                }
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (int i = 0; i < ranks.length; i++)
                FlSpot(i.toDouble(), ranks[i].toDouble()),
            ],
            isCurved: false,
            barWidth: 2,
            dotData: FlDotData(show: true),
            color: Colors.orange,
          ),
        ],
      ),
    );

    return _AutoScrolledHorizontalChart(
      chart: chart,
      width: terms.length * 60.0, // Adjusted width for rotated labels
    );
  }
}

/// A widget that wraps a chart in a horizontally scrolling view
/// and automatically scrolls to the end on initial display.
class _AutoScrolledHorizontalChart extends StatefulWidget {
  final Widget chart;
  final double width;

  const _AutoScrolledHorizontalChart({required this.chart, required this.width});

  @override
  State<_AutoScrolledHorizontalChart> createState() => _AutoScrolledHorizontalChartState();
}

class _AutoScrolledHorizontalChartState extends State<_AutoScrolledHorizontalChart> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    // Initialize the scroll controller.
    _scrollController = ScrollController();

    // After the widget is built, scroll to the end.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: widget.width,
        child: widget.chart,
      ),
    );
  }
}
