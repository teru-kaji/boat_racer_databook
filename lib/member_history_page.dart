//
// lib/member_history_page.dart
//
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'models/member.dart';
import 'objectbox.dart'; // グローバル objectbox を利用

class MemberHistoryPage extends StatelessWidget {
  final Member member;

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
      return v ?? 0;
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
              '得点率 (winPointRate)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 220,
              child: _lineChart(terms, scoreRates, '得点率', Colors.blue),
            ),

            const SizedBox(height: 24),
            const Text(
              '複勝率 (winRate12)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 220,
              child: _lineChart(terms, winRates, '複勝率', Colors.green),
            ),

            const SizedBox(height: 24),
            const Text(
              '級別の推移',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 220,
              child: _rankChart(terms, ranks),
            ),
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

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: terms.length * 50, // データ数に応じて横幅を確保
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: (values.length - 1).toDouble(),
            minY: 0,
            maxY: values.map((e) => e.toDouble()).reduce((a, b) => a > b ? a : b) * 1.2,
            gridData: FlGridData(show: true),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: Colors.black, width: 1),
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1, // ★ X軸間隔を固定
                  getTitlesWidget: (v, meta) {
                    if (v < 0 || v > terms.length - 1) {
                      return const SizedBox.shrink();
                    }
                    // ★ 降順で表示
                    final reversedIndex = terms.length - 1 - v.toInt();
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        terms[reversedIndex],
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (v, meta) {
                    return Text(
                      isInt ? v.toInt().toString() : v.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: [
                  for (int i = 0; i < values.length; i++)
                    FlSpot(i.toDouble(), values[terms.length - 1 - i].toDouble()),
                ],
                isCurved: false,
                barWidth: 2,
                dotData: FlDotData(show: true),
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// rank 用折れ線グラフ
  Widget _rankChart(List<String> terms, List<int> ranks) {
    if (ranks.isEmpty) {
      return const Center(child: Text('データがありません'));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: terms.length * 50,
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: (terms.length - 1).toDouble(),
            minY: 1,
            maxY: 4,
            gridData: FlGridData(show: true),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: Colors.black, width: 1),
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (v, meta) {
                    if (v < 0 || v > terms.length - 1) {
                      return const SizedBox.shrink();
                    }
                    // ★ 降順で表示
                    final reversedIndex = terms.length - 1 - v.toInt();
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        terms[reversedIndex],
                        style: const TextStyle(fontSize: 10),
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
                        return const Text('B2', style: TextStyle(fontSize: 10));
                      case 2:
                        return const Text('B1', style: TextStyle(fontSize: 10));
                      case 3:
                        return const Text('A2', style: TextStyle(fontSize: 10));
                      case 4:
                        return const Text('A1', style: TextStyle(fontSize: 10));
                      default:
                        return const Text('');
                    }
                  },
                ),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: [
                  for (int i = 0; i < ranks.length; i++)
                    FlSpot(i.toDouble(), ranks[terms.length - 1 - i].toDouble()),
                ],
                isCurved: false,
                barWidth: 2,
                dotData: FlDotData(show: true),
                color: Colors.orange,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
