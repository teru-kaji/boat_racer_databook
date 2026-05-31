// lib/member_detail_page.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'models/member.dart';
import 'member_history_page.dart';
import 'objectbox.dart';
import 'objectbox.g.dart';
import 'utils.dart';
import 'package:url_launcher/url_launcher.dart';

class MemberDetailPage extends StatefulWidget {
  final int memberId;

  const MemberDetailPage({super.key, required this.memberId});

  @override
  State<MemberDetailPage> createState() => _MemberDetailPageState();
}

class _MemberDetailPageState extends State<MemberDetailPage> {
  // --- Font Size Constants ---
  static const double _kLinkFontSize = 16.0;
  static const double _kInfoFontSize = 15.0;
  static const double _kChartLabelFontSize = 14.0;
  static const double _kTooltipMainFontSize = 14.0;
  static const double _kTooltipSubFontSize = 14.0;
  static const double _kTableFontSize = 14.0;
  // ---

  Member? _selectedMember;
  List<Member> _history = [];
  List<String> _dataTimeOptions = [];
  String? _selectedDataTime;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMemberData();
  }

  // アイコン＋"公式プロフィールを見る" テキスト付き
  Widget buildMemberIcon(Member m) {
    final accent = genderAccentColor(m.vsex);

    return GestureDetector(
      onTap: () async {
        if (m.vno == null || m.vno!.isEmpty) return;

        final url = Uri.parse(
          "https://www.boatrace.jp/owsp/sp/data/racersearch/profile?toban=${m.vno}",
        );

        final ok = await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );

        if (!ok) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ブラウザを開けませんでした')),
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: accent.withValues(alpha: 0.2),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                size: 60,
                color: accent,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "公式プロフィールを見る",
            style: TextStyle(
              color: accent,
              fontSize: _kLinkFontSize,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }

  void _loadMemberData() {
    final member = objectbox.memberBox.get(widget.memberId);

    if (member == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    _selectedMember = member;
    _selectedDataTime = member.vdt;

    if (member.vno != null && member.vno!.isNotEmpty) {
      final query = objectbox.memberBox
          .query(Member_.vno.equals(member.vno!))
          .build();
      _history = query.find();
    } else {
      _history = [member];
    }

    _dataTimeOptions =
        _history
            .map((m) => m.vdt ?? '')
            .where((s) => s.isNotEmpty)
            .toList()
          ..sort((a, b) => b.compareTo(a));

    if (!_dataTimeOptions.contains(_selectedDataTime) &&
        _dataTimeOptions.isNotEmpty) {
      _selectedDataTime = _dataTimeOptions.first;
      _selectedMember = _history.firstWhere(
        (m) => m.vdt == _selectedDataTime,
        orElse: () => member,
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _selectDataTime(BuildContext context) async {
    if (_dataTimeOptions.isEmpty) return;

    final selected = await showSearch<String>(
      context: context,
      delegate: _DataTimeSearchDelegate(_dataTimeOptions),
    );

    if (selected != null && selected.isNotEmpty && selected != _selectedDataTime) {
      setState(() {
        _selectedDataTime = selected;
        _selectedMember = _history.firstWhere((m) => m.vdt == selected,
            orElse: () => _selectedMember!); 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_selectedMember == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('エラー')),
        body: const Center(child: Text('メンバーが見つかりませんでした。')),
      );
    }

    final m = _selectedMember!;
    final rows = _buildCourseRows(m);
    final totals = _calcTotals(rows);

    final List<double> winRates = rows.map((r) => r.winRate12 ?? 0.0).toList();
    final List<double> starts = rows.map((r) => r.startTime ?? 0.0).toList();
    final List<int> firsts = rows.map((r) => r.first ?? 0).toList();
    final List<int> seconds = rows.map((r) => r.second ?? 0).toList();
    final List<int> thirds = rows.map((r) => r.third ?? 0).toList();
    final List<int> entries = rows.map((r) => r.entries ?? 0).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${m.vname ?? '詳細情報'}（${formatDataTimePeriod(_selectedDataTime ?? '')}）',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_dataTimeOptions.isNotEmpty)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_month),
                      label: Text(
                        _selectedDataTime != null
                            ? formatDataTimePeriod(_selectedDataTime!)
                            : '期を選択',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: _kInfoFontSize),
                      ),
                      onPressed: () => _selectDataTime(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MemberHistoryPage(member: m),
                        ),
                      );
                    },
                    child: const Text(
                      '期ごとの成績を表示',
                      style: TextStyle(fontSize: _kInfoFontSize),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            Center(child: buildMemberIcon(m)),
            const SizedBox(height: 20),
            
            // --- 選手情報のテーブル表示 ---
            _buildMemberInfoTable(m),
            
            const SizedBox(height: 32),
            Text('コース別 複勝率（%）', style: Theme.of(context).textTheme.titleLarge),
            _barChartSingle(
              context: context,
              titleY: '複勝率(%)',
              values: winRates,
              entries: entries,
              maxY: _niceMax(winRates, base: 100, minMax: 20),
              formatY: (v) => v.toStringAsFixed(0),
            ),
            const SizedBox(height: 24),
            Text(
              'コース別 スタートタイミング',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            _lineChartPoints(context: context, values: starts, entries: entries),
            const SizedBox(height: 24),
            Text(
              'コース別 1着・2着・3着数',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            _barChartStacked(
              context: context,
              firsts: firsts,
              seconds: seconds,
              thirds: thirds,
              maxY: _niceMax(
                [...firsts, ...seconds, ...thirds],
                base: 10,
                minMax: 5,
              ),
            ),
            const SizedBox(height: 24),
            Text('コース別 成績（表）', style: Theme.of(context).textTheme.titleLarge),
            _courseTable(context, rows, totals),
            const SizedBox(height: 24),
            Text("コース別事故数", style: Theme.of(context).textTheme.titleLarge),
            _buildAccidentTable(m),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // 2列のテーブル形式で選手情報を表示する
  Widget _buildMemberInfoTable(Member m) {
    // ローカル変数にコピーすることで型プロモーションを有効にする
    final h = m.vht;
    final w = m.vwt;
    final wpr = m.vwinPt;
    final wr12 = m.vwr12;
    final st = m.vstAvg;
    final age = m.vage;
    final firstCount = m.vp1Cnt;
    final secondCount = m.vp2Cnt;
    final raceCount = m.vraceN;
    final winsCount = m.vwinN;
    final finalsCount = m.vfinalN;
    final las = m.vabLast;
    final pas = m.vabPast;

    return Table(
      columnWidths: const {
        0: FixedColumnWidth(150),
        1: FlexColumnWidth(),
      },
      border: TableBorder.all(color: Colors.grey.shade300, width: 1),
      children: [
        _tableRow('登録番号', m.vno),
        _tableRow('ランク', '${m.vrank ?? "-"} ⇐ ${m.vrkP1 ?? "-"} ← ${m.vrkP2 ?? "-"} ← ${m.vrkP3 ?? "-"}'),
        _tableRow('名前', '${m.vname ?? ""}  ${m.vkana3 ?? ""}' ),
        _tableRow('支部  出身地', '${m.vbr ?? ""}   ${m.vbirth?.replaceAll(RegExp(r'\s+'), '') ?? ""}'),
        _tableRow('年齢  誕生日','${age?.toString() ?? "-"} 才   ${m.vgbday ?? "-"}'),
        _tableRow('身長  体重  血液型', '${h?.toStringAsFixed(0) ?? "-"} cm  ${w?.toStringAsFixed(1) ?? "-"} kg  ${m.vblood ?? "-"}'),
        _tableRow('勝率  複勝率','${wpr?.toStringAsFixed(2) ?? "-"}  ${_fmtPercent(wr12)}'),
        _tableRow('1着 2着 出走数', '${firstCount?.toString() ?? "0"}  ${secondCount?.toString() ?? "0"}  ${raceCount?.toString() ?? "0"}'  ),
        _tableRow('優勝数 優出数', '${winsCount?.toString() ?? "0"}  ${finalsCount?.toString() ?? "0"}'),
        _tableRow('平均ST', st?.toStringAsFixed(2) ?? "-"),
        _tableRow('能力指数', '${las ?? "-"} ← ${pas ?? "-"}'),
      ],
    );
  }

  TableRow _tableRow(String label, String? value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: _kInfoFontSize),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            (value == null || value.isEmpty) ? '-' : value,
            style: const TextStyle(fontSize: _kInfoFontSize),
          ),
        ),
      ],
    );
  }

  Widget _courseTable(
    BuildContext context,
    List<_CourseRow> rows,
    _Totals totals,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: _kTableFontSize,
          color: Colors.black,
        ),
        dataTextStyle: const TextStyle(
          fontSize: _kTableFontSize,
          color: Colors.black87,
        ),
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
            DataRow(
              cells: [
                DataCell(Text('${r.lane}')),
                DataCell(Text(_fmtInt(r.entries))),
                DataCell(Text(_fmtDouble(r.startTime))),
                DataCell(Text(_fmtPercent(r.winRate12))),
                DataCell(Text(_fmtInt(r.first))),
                DataCell(Text(_fmtInt(r.second))),
                DataCell(Text(_fmtInt(r.third))),
                DataCell(
                  Text('${(r.first ?? 0) + (r.second ?? 0) + (r.third ?? 0)}'),
                ),
              ],
            ),
          DataRow(
            color: WidgetStateProperty.all(Colors.grey[200]),
            cells: [
              const DataCell(
                Text('合計', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              DataCell(
                Text(
                  _fmtInt(totals.entries),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const DataCell(Text('-')),
              const DataCell(Text('-')),
              DataCell(
                Text(
                  _fmtInt(totals.first),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataCell(
                Text(
                  _fmtInt(totals.second),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataCell(
                Text(
                  _fmtInt(totals.third),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataCell(
                Text(
                  '${totals.first + totals.second + totals.third}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccidentTable(Member member) {
    Widget _fixedCell(int? val, {bool bold = false}) {
      final txt = val?.toString() ?? "-";
      return SizedBox(
        width: 40,
        child: Text(
          txt,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: _kTableFontSize,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            color: (!bold && (val == 0 || val == null)) ? Colors.grey : Colors.black,
          ),
        ),
      );
    }

    final List<List<int?>> courseValues = [
      [
        member.vc1Fs, member.vc1LsNr, member.vc1LsR,
        member.vc1WdNr, member.vc1WdR,
        member.vc1InvNr, member.vc1InvR, member.vc1InvOb,
      ],
      [
        member.vc2Fs, member.vc2LsNr, member.vc2LsR,
        member.vc2WdNr, member.vc2WdR,
        member.vc2InvNr, member.vc2InvR, member.vc2InvOb,
      ],
      [
        member.vc3Fs, member.vc3LsNr, member.vc3LsR,
        member.vc3WdNr, member.vc3WdR,
        member.vc3InvNr, member.vc3InvR, member.vc3InvOb,
      ],
      [
        member.vc4Fs, member.vc4LsNr, member.vc4LsR,
        member.vc4WdNr, member.vc4WdR,
        member.vc4InvNr, member.vc4InvR, member.vc4InvOb,
      ],
      [
        member.vc5Fs, member.vc5LsNr, member.vc5LsR,
        member.vc5WdNr, member.vc5WdR,
        member.vc5InvNr, member.vc5InvR, member.vc5InvOb,
      ],
      [
        member.vc6Fs, member.vc6LsNr, member.vc6LsR,
        member.vc6WdNr, member.vc6WdR,
        member.vc6InvNr, member.vc6InvR, member.vc6InvOb,
      ],
    ];

    final totals = List.generate(8, (j) {
      return courseValues.fold<int>(0, (sum, lane) => sum + (lane[j] ?? 0));
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              columnSpacing: 0,
              headingTextStyle: const TextStyle(
                fontSize: _kTableFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              columns: const [
                DataColumn(label: Center(child: Text("コース"))),
                DataColumn(label: Padding(padding: EdgeInsets.only(left: 10), child: Text("F"))),
                DataColumn(label: Padding(padding: EdgeInsets.only(left: 10), child: Text("L0"))),
                DataColumn(label: Padding(padding: EdgeInsets.only(left: 10), child: Text("L1"))),
                DataColumn(label: Padding(padding: EdgeInsets.only(left: 10), child: Text("K0"))),
                DataColumn(label: Padding(padding: EdgeInsets.only(left: 10), child: Text("K1"))),
                DataColumn(label: Padding(padding: EdgeInsets.only(left: 10), child: Text("S0"))),
                DataColumn(label: Padding(padding: EdgeInsets.only(left: 10), child: Text("S1"))),
                DataColumn(label: Padding(padding: EdgeInsets.only(left: 10), child: Text("S2"))),
              ],
              rows: [
                for (int lane = 0; lane < 6; lane++)
                  DataRow(
                    cells: [
                      DataCell(Center(child: Text("${lane + 1}"))),
                      for (int j = 0; j < 8; j++)
                        DataCell(_fixedCell(courseValues[lane][j])),
                    ],
                  ),
                DataRow(
                  color: WidgetStateProperty.all(Colors.grey[200]),
                  cells: [
                    const DataCell(Center(child: Text("合計", style: TextStyle(fontWeight: FontWeight.bold)))),
                    for (final t in totals)
                      DataCell(_fixedCell(t, bold: true)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _barChartSingle({
    required BuildContext context,
    required String titleY,
    required List<double> values,
    required List<int> entries,
    required double maxY,
    required String Function(double) formatY,
  }) {
    return SizedBox(
      height: 260,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          minY: 0,
          gridData: const FlGridData(show: true),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 44,
                getTitlesWidget: (v, meta) =>
                    Text(formatY(v), style: const TextStyle(fontSize: _kChartLabelFontSize)),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (v, meta) {
                  if (v < 0 || v > values.length - 1) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '${v.toInt() + 1}',
                      style: const TextStyle(fontSize: _kChartLabelFontSize),
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final rate = values[group.x.toInt()];
                final entryCount = entries[group.x.toInt()];
                return BarTooltipItem(
                  '${rate.toStringAsFixed(1)}%\n',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: _kTooltipMainFontSize,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: '($entryCount走)',
                      style: const TextStyle(
                        color: Colors.yellow,
                        fontWeight: FontWeight.normal,
                        fontSize: _kTooltipSubFontSize,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          barGroups: List.generate(values.length, (i) {
            final y = values[i].isNaN ? 0.0 : values[i];
            return BarChartGroupData(
              x: i,
              barRods: [BarChartRodData(toY: y, width: 20, color: Colors.blue)],
            );
          }),
        ),
      ),
    );
  }

  Widget _lineChartPoints({
    required BuildContext context,
    required List<double> values,
    required List<int> entries,
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
          gridData: const FlGridData(show: true),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 44,
                interval: 0.1,
                getTitlesWidget: (v, meta) => Text(
                  v.toStringAsFixed(2),
                  style: const TextStyle(fontSize: _kChartLabelFontSize),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (v, meta) {
                  if (v < 0 || v > values.length - 1) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '${v.toInt() + 1}',
                      style: const TextStyle(fontSize: _kChartLabelFontSize),
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final st = values[spot.spotIndex];
                  final entryCount = entries[spot.spotIndex];
                  return LineTooltipItem(
                    '${st.toStringAsFixed(2)}\n',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: _kTooltipMainFontSize,
                    ),
                    children: [
                      TextSpan(
                        text: '($entryCount走)',
                        style: const TextStyle(
                          color: Colors.yellow,
                          fontWeight: FontWeight.normal,
                          fontSize: _kTooltipSubFontSize,
                        ),
                      ),
                    ],
                  );
                }).toList();
              },
            ),
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
              gridData: const FlGridData(show: true),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    getTitlesWidget: (v, meta) => Text(
                      v.toInt().toString(),
                      style: const TextStyle(fontSize: _kChartLabelFontSize),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (v, meta) {
                      if (v < 0 || v > 5) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          '${v.toInt() + 1}',
                          style: const TextStyle(fontSize: _kChartLabelFontSize),
                        ),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final index = group.x.toInt();
                    final f = firsts[index];
                    final s = seconds[index];
                    final t = thirds[index];

                    return BarTooltipItem(
                      '',
                      const TextStyle(color: Colors.white, fontSize: 0),
                      children: <TextSpan>[
                        TextSpan(
                          text: '1着: $f\n',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: _kTooltipMainFontSize,
                          ),
                        ),
                        TextSpan(
                          text: '2着: $s\n',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: _kTooltipMainFontSize,
                          ),
                        ),
                        TextSpan(
                          text: '3着: $t',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: _kTooltipMainFontSize,
                          ),
                        ),
                      ],
                    );
                  },
                ),
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

  List<_CourseRow> _buildCourseRows(Member m) {
    return [
      _CourseRow(
        lane: 1,
        entries: m.vc1Ent,
        startTime: m.vc1St,
        winRate12: m.vc1Wr,
        first: m.vc1P1,
        second: m.vc1P2,
        third: m.vc1P3,
      ),
      _CourseRow(
        lane: 2,
        entries: m.vc2Ent,
        startTime: m.vc2St,
        winRate12: m.vc2Wr,
        first: m.vc2P1,
        second: m.vc2P2,
        third: m.vc2P3,
      ),
      _CourseRow(
        lane: 3,
        entries: m.vc3Ent,
        startTime: m.vc3St,
        winRate12: m.vc3Wr,
        first: m.vc3P1,
        second: m.vc3P2,
        third: m.vc3P3,
      ),
      _CourseRow(
        lane: 4,
        entries: m.vc4Ent,
        startTime: m.vc4St,
        winRate12: m.vc4Wr,
        first: m.vc4P1,
        second: m.vc4P2,
        third: m.vc4P3,
      ),
      _CourseRow(
        lane: 5,
        entries: m.vc5Ent,
        startTime: m.vc5St,
        winRate12: m.vc5Wr,
        first: m.vc5P1,
        second: m.vc5P2,
        third: m.vc5P3,
      ),
      _CourseRow(
        lane: 6,
        entries: m.vc6Ent,
        startTime: m.vc6St,
        winRate12: m.vc6Wr,
        first: m.vc6P1,
        second: m.vc6P2,
        third: m.vc6P3,
      ),
    ];
  }

  _Totals _calcTotals(List<_CourseRow> rows) {
    var entries = 0, first = 0, second = 0, third = 0;
    for (final r in rows) {
      entries += (r.entries ?? 0);
      first += (r.first ?? 0);
      second += (r.second ?? 0);      
      third += (r.third ?? 0);
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
    final padded = (maxVal * 1.0);
    final step = base;
    final mul = (padded / step).ceil();
    return (mul * step).clamp(minMax, double.infinity);
  }

  Color genderAccentColor(int? sex) {
    if (sex == 2) return Colors.pinkAccent;
    if (sex == 1) return Colors.lightBlueAccent;
    return Colors.grey;
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
