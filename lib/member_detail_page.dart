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

        if (!ok && mounted) {
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
            Text("事故数", style: Theme.of(context).textTheme.titleLarge),
            _buildAccidentTable(m),
            const SizedBox(height: 24),

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
        _tableRow('支部/出身地', '${m.vbr ?? ""} / ${m.vbirth?.replaceAll(RegExp(r'\s+'), '') ?? ""}'),
        _tableRow('年齢  (誕生日)','${age?.toString() ?? "-"}才  (${m.vgbday ?? "-"})'),
        _tableRow('身長/体重/血液型', '${h?.toStringAsFixed(0) ?? "-"}cm / ${w?.toStringAsFixed(1) ?? "-"}kg / ${m.vblood ?? "-"}'),
        _tableRow('勝率/複勝率','${wpr?.toStringAsFixed(2) ?? "-"} / ${_fmtPercent(wr12)}'),
        _tableRow('1着/2着/出走数', '${firstCount?.toString() ?? "0"} / ${secondCount?.toString() ?? "0"} / ${raceCount?.toString() ?? "0"}'  ),
        _tableRow('優勝数/優出数', '${winsCount?.toString() ?? "0"} / ${finalsCount?.toString() ?? "0"}'),
        _tableRow('平均ST/能力指数', '${st?.toStringAsFixed(2) ?? "-"}秒 / ${las ?? "-"} ← ${pas ?? "-"}'),
//        _tableRow('能力指数', '${las ?? "-"} ← ${pas ?? "-"}'),
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

    final List<List<int?>> courseValues = [
      [member.vc1Fs, member.vc1LsNr, member.vc1LsR, member.vc1WdNr, member.vc1WdR, member.vc1InvNr, member.vc1InvR, member.vc1InvOb],
      [member.vc2Fs, member.vc2LsNr, member.vc2LsR, member.vc2WdNr, member.vc2WdR, member.vc2InvNr, member.vc2InvR, member.vc2InvOb],
      [member.vc3Fs, member.vc3LsNr, member.vc3LsR, member.vc3WdNr, member.vc3WdR, member.vc3InvNr, member.vc3InvR, member.vc3InvOb],
      [member.vc4Fs, member.vc4LsNr, member.vc4LsR, member.vc4WdNr, member.vc4WdR, member.vc4InvNr, member.vc4InvR, member.vc4InvOb],
      [member.vc5Fs, member.vc5LsNr, member.vc5LsR, member.vc5WdNr, member.vc5WdR, member.vc5InvNr, member.vc5InvR, member.vc5InvOb],
      [member.vc6Fs, member.vc6LsNr, member.vc6LsR, member.vc6WdNr, member.vc6WdR, member.vc6InvNr, member.vc6InvR, member.vc6InvOb],
    ];

    final totals = List.generate(8, (j) {
      return courseValues.fold<int>(0, (sum, lane) => sum + (lane[j] ?? 0));
    });

    const colNames = ['F', 'L0', 'L1', 'K0', 'K1', 'S0', 'S1', 'S2'];

    const tableColumns = [
      DataColumn(label: Padding(padding: EdgeInsets.only(left: 10), child: Text("F"))),
      DataColumn(label: Padding(padding: EdgeInsets.only(left: 10), child: Text("L0"))),
      DataColumn(label: Padding(padding: EdgeInsets.only(left: 10), child: Text("L1"))),
      DataColumn(label: Padding(padding: EdgeInsets.only(left: 10), child: Text("K0"))),
      DataColumn(label: Padding(padding: EdgeInsets.only(left: 10), child: Text("K1"))),
      DataColumn(label: Padding(padding: EdgeInsets.only(left: 10), child: Text("S0"))),
      DataColumn(label: Padding(padding: EdgeInsets.only(left: 10), child: Text("S1"))),
      DataColumn(label: Padding(padding: EdgeInsets.only(left: 10), child: Text("S2"))),
    ];

    const codeDescriptions = <String, String>{
      'F':
          'F（フライング）：早期スタート\n\n'
          '競艇特有の「フライングスタート方式」において、大時計の針が0秒を指す前に'
          'スタートラインを通過してしまった場合に適用されます。\n\n'
          '・0秒ジャストより「0.01秒」でも早ければフライング（F）\n'
          '・0秒より0.05秒以上早い場合は「非常識なフライング」と呼ばれ、'
          '即日帰郷などさらに厳しい処置がとられます\n\n'
          '■ 選手へのペナルティ\n'
          '・フライング休み（出場停止）\n'
          '　F1（1回目）：30日間の出場停止\n'
          '　F2（2回目）：さらに60日間（合計90日間）\n'
          '　F3（3回目）：さらに90日間（合計180日間）\n'
          '　※F3は事実上の引退勧告に近い扱い\n'
          '・事故点：1回につき20点が加算\n'
          '・即日帰郷（節間の予選などでFを起こした場合）\n'
          '・SG・G1の準優勝戦・優勝戦でFを起こすと、半年〜1年間ビッグレース出場不可\n\n'
          '■ 舟券への影響：全額返還\n'
          '・フライング艇が絡む舟券（単勝・複勝・2連単・3連単などすべて）は全額返還\n'
          '・フライング艇を除いた5艇以下でレースが続行されます\n'
          '・人気艇がFを起こすと、その艇への賭け金が一斉に返還されるため、'
          '残った艇のオッズがガクンと下がることがあります\n\n'
          'ファンの視点では「お金が戻ってくる」ので損はありませんが、選手にとっては'
          '「1ヶ月〜数ヶ月間、完全に無収入になる」という生活に直結するペナルティです。\n\n'
          'F持ちの選手はスタートを攻めにくくなるため、予想の際は「スタートが慎重になる'
          '（遅れる）かもしれない」という重要なヒントになります。',
      'L0':
          'L0（エルゼロ）：選手責任外の出遅れ\n\n'
          '大時計が0秒を指してから1秒以内にスタートラインを通過できなかったものの、'
          'その原因が選手のミスではなく、突発的な機材トラブルや他艇からの妨害など、'
          '不可抗力によるものと審判員に判定された場合に適用されます。\n\n'
          '主な原因：スタート直前の予期せぬエンスト、他艇にぶつかられた・引き波にはめられた、'
          'プロペラの突発的な破損など。\n\n'
          '■ 選手へのペナルティ：なし\n'
          '・フライング休み（出場停止）：課されません\n'
          '・事故点：加算されません\n'
          '・賞金：欠場扱いのため、そのレース分はもらえません\n\n'
          '■ 舟券への影響\n'
          '・その艇が絡む舟券（単勝・複勝・2連単・3連単など）はすべて全額返還\n'
          '・残った5艇以下でレースが続行され、確定オッズは該当艇の売上を除外して再計算\n\n'
          '⚠ L0は「選手にペナルティがない」だけであり、そのレース自体は走れていない（不成立）'
          'ため、舟券を買っていた場合は全額返還（プラスマイナスゼロ）となります。',
      'L1':
          'L1（エルワン）：選手責任による出遅れ\n\n'
          'L0（選手責任外）とは対照的に、選手自身のミスによってスタートできなかった場合に'
          '適用される非常に厳しい判定です。\n\n'
          '大時計が0秒を指してから1秒以内にスタートラインを通過できなかった原因が、'
          '選手の操縦ミスや整備不良、あるいは準備不足にあると判断された場合に適用されます。\n\n'
          '主な原因：レバー操作のミスによるエンスト、待機行動中の過度な深イン（助走距離不足）'
          'で立ち上がれなかった、整備ミスによる出力不足など。\n\n'
          '■ 選手への影響：F（フライング）と同等の重罰\n'
          '・フライング休み（出場停止）\n'
          '　1回目：30日間の出場停止\n'
          '　すでにFを1回持っている状態でL1を起こすと計90日間（F2扱い）\n'
          '・事故点：1回につき20点という非常に高い事故点が加算\n'
          '　（勝率が良くてもB2級へ一気に転落するリスクあり）\n'
          '・即日帰郷：節間の予選などで起こした場合、その日のうちに強制帰宅\n\n'
          '■ 舟券への影響\n'
          '・その艇に関連する舟券はすべて全額返還\n'
          '・該当艇が人気だった場合、残った艇のオッズが大きく下がることがあります\n\n'
          '【L0 vs L1】\n'
          '・L0（選手責任外）：出場停止なし・事故点0点・舟券全額返還\n'
          '・L1（選手責任）　：出場停止あり・事故点20点・舟券全額返還\n\n'
          'L1はFを切ったのと同様の致命的なミスであり、その後の選手生命や階級に大きく響きます。',
      'K0':
          'K0（ケイゼロ）：選手責任外の事前欠場\n\n'
          'スタート時のトラブル（L0・L1）とは異なり、レースが始まるもっと手前の段階で'
          '発生するコードです。\n\n'
          'レース（番組）が確定した後に、選手自身の責任（ミスや自己都合）ではない'
          '不可抗力の理由によって、レースに出場できなくなった（欠場した）場合に適用されます。\n\n'
          '主な原因：\n'
          '・前のレースで他艇に衝突され、ボートやモーターが大破して修復が間に合わない場合\n'
          '・急激な悪天候や水面状況の悪化などにより、物理的に出走が不可能と判断された場合\n\n'
          '■ 選手へのペナルティ：なし\n'
          '・フライング休み（出場停止）：課されません\n'
          '・事故点：加算されません（0点）\n'
          '・級別審査（A1級などのクラス分け）への悪影響もありません\n'
          '・機材の破損が理由であれば、翌日以降のレースには問題なく出場できます\n\n'
          '■ 舟券への影響\n'
          '・K0となった艇が絡む舟券はすべて全額返還\n'
          '・該当艇を除いた5艇以下でレースが実施されます\n'
          '・基本的に「事前」欠場のため、締め切り前に対象艇が発表され、'
          'ファンも5艇立てと分かった状態で舟券を買い直すなどの対応が可能\n\n'
          '【K0 vs K1】\n'
          '・K0（選手責任外）：出場停止なし・事故点0点・舟券全額返還\n'
          '・K1（選手責任）　：出場停止なし・事故点10点・舟券全額返還\n\n'
          'K0は「道具の故障やアクシデントのせいでレース前に出られなくなった状態（選手はお咎めなし）」'
          'と覚えておくと分かりやすいです。',
      'K1':
          'K1（ケイワン）：選手責任による事前欠場\n\n'
          'K0（選手責任外）とは異なり、選手自身の体調管理や手続きのミスなど、'
          '「選手本人に原因があるレース前の欠場」に対して適用されるコードです。\n\n'
          'レース（番組）が確定した後に、選手自身の落ち度や自己都合によって、'
          'レースに出走できなくなった（欠場した）場合に適用されます。\n\n'
          '主な原因：\n'
          '・体重管理の失敗：規定の最低体重（男子52kg・女子47kg）を維持できず測定で失格\n'
          '・管理不足・不注意：宿舎でのケガ（私傷病）、体調不良、私用による急な帰郷など\n'
          '・手続きの遅れ：競技への遅刻や必要な手続きの不備\n\n'
          '■ 選手へのペナルティ\n'
          '・事故点：1回につき10点が加算（B級転落の要因になります）\n'
          '・即日帰郷：その時点でレース出場権を失い、開催地から強制帰宅\n'
          '・重大な規律違反の場合は、さらに出場停止などの処分が追加されるケースもあり\n\n'
          '■ 舟券への影響\n'
          '・K1となった艇が絡む舟券はすべて全額返還\n'
          '・該当艇を除いた5艇以下でレースが実施されます\n'
          '・前日や当日の展示航走前に確定することが多く、締め切り前に欠場が告知されるため、'
          '除外後のオッズを見て買い直すことができます\n\n'
          '【K0 vs K1】\n'
          '・K0（選手責任外）：事故点0点・機材が直れば翌日以降も出走可・舟券全額返還\n'
          '・K1（選手責任）　：事故点10点・即日帰郷（その節は終了）・舟券全額返還\n\n'
          'K1はプロとしての体調管理や準備の甘さに対して下されるペナルティです。'
          '事故点10点＋即日帰郷という、選手にとって非常に痛い処分となります。',
      'S0':
          'S0（エスゼロ）：選手責任外のレース中失格\n\n'
          'スタートトラブル（F/L）や事前欠場（K）とは異なり、「レース中（スタート後）」に'
          '発生するアクシデントに関するコードです。\n\n'
          '正常にスタートしてレース中に、選手自身のミスではなく、他艇のダンプ（体当たり）や'
          '衝突に巻き込まれたり、不可抗力の機材トラブルによってレースを継続できなくなった'
          '場合に適用されます。\n\n'
          '主な原因：\n'
          '・他艇に激しく衝突され、転覆または沈没した場合\n'
          '・前を走る艇の事故を避けるため操縦し、やむを得ずエンスト・落水した場合\n'
          '・走行中に突発的なエンジントラブルで動かなくなった場合\n\n'
          '■ 選手へのペナルティ：なし\n'
          '・事故点：0点（級別審査への悪影響なし）\n'
          '・S1（選手責任）なら事故点15点がつくが、S0ならお咎めなし\n'
          '・ケガがなければ翌日以降も通常通り出走可能\n\n'
          '■ 舟券への影響：返還なし（ハズレ扱い）\n'
          'ここがF・L・Kのシリーズと最も大きく異なる最大の注意点です。\n\n'
          '・舟券は返還されません（不的中・ハズレ扱い）\n'
          '・理由：競艇のルール上、「正常にスタートラインを通過した後のアクシデント」は'
          'すべてファン側の運の要素となります\n'
          '・たとえ1番人気の艇が他艇にぶつけられて転覆（S0）しても、'
          'その艇が絡んだ舟券はお金が戻らずハズレになります\n\n'
          '選手にとっては「自分は悪くないからペナルティなし」という救いのあるコードですが、'
          'ファンにとっては「スタート後の事故だから返還されない」という、'
          '一番泣き寝入りするしかない痛いアクシデントです。',
      'S1':
          'S1（エスワン）：選手責任によるレース中失格\n\n'
          'S0（選手責任外）とは真逆で、「レース中、選手自身のミスや強引な操縦によって'
          '失格になった場合」に適用されるコードです。\n\n'
          '正常にスタートした後のレース中に、選手の操縦ミス・整備不良・強引な旋回などが'
          '原因でレースを継続できなくなった、あるいは他艇を巻き込むアクシデントを起こして'
          '失格になった場合に適用されます。\n\n'
          '主な原因：\n'
          '・ターンマークでの旋回ミスによる自沈・転覆・落水\n'
          '・無理なツケマイやダンプを仕掛けた結果、自分が転覆・エンストした場合\n'
          '・他艇と接触し相手を転覆させた上で、自分もレース継続不能になった場合\n\n'
          '■ 選手へのペナルティ\n'
          '・事故点：1回につき15点という非常に高い事故点が加算\n'
          '　（事故率が0.70を超えると強制的にB2級降格のため、15点は大打撃）\n'
          '・即日帰郷：その日のレース終了後に強制帰宅、残りのレースで稼ぐ機会を失う\n'
          '・賞金：失格のため、そのレースの賞金・手当は一切支給されません\n\n'
          '■ 舟券への影響：返還なし（ハズレ扱い）\n'
          'S0と同様に、スタート後の事故のためファンへの救済措置はありません。\n\n'
          '・舟券は返還されません（不的中・ハズレ扱い）\n'
          '・選手がどれだけひどい操縦ミスで転覆（S1）しても、「正常にスタートを切った後の'
          '出来事」はすべてレース成立とみなされます\n'
          '・軸にしていた大本命が自分のミスでコケて失格（S1）になっても、'
          'その舟券はお金が戻らずハズレ確定です\n\n'
          '【S0 vs S1】\n'
          '・S0（選手責任外）：事故点0点・翌日以降も出走可・舟券返還なし（ハズレ）\n'
          '・S1（選手責任）　：事故点15点・即日帰郷・舟券返還なし（ハズレ）\n\n'
          'ファンの視点ではS0もS1も「お金が戻ってこない」点に変わりはありませんが、'
          '選手にとっては事故点15点＋即日帰郷というA1級キープを脅かすレベルのペナルティです。',
      'S2':
          'S2（エスツー）：選手責任による妨害失格\n\n'
          'S1（選手責任の失格）のさらに上をいく、競艇の中で最も重い違反失格のひとつです。\n\n'
          'レース中に、自分の強引な操縦や危険な航法によって他艇を巻き込み、'
          '転覆・落水・沈没・破損などをさせてレース継続不能に追い込んでしまった場合に'
          '適用されます。\n\n'
          '主な原因：\n'
          '・ターンマークでの強引な割り込み（不良航法）により他艇を玉突き状態にして転覆させた\n'
          '・無理なダンプ（体当たり）を仕掛け、相手艇を乗り越えたり沈没させたりした\n'
          '・自分の操縦ミスで転覆し、後続艇が避けきれずに激突して大破・転覆した\n\n'
          '■ 選手へのペナルティ\n'
          '・事故点：1回につき15点という最大級の事故点が加算\n'
          '　（一発で事故率オーバーによる強制B2級降格危機になるレベルの致命傷）\n'
          '・即日帰郷：容赦なくその日のうちに強制帰宅\n'
          '・賞金・手当：失格のためゼロ\n'
          '・今後の斡旋辞退やグレードレースへの出場制限が追加されることもあり\n\n'
          '■ 舟券への影響：返還なし（ハズレ扱い）\n'
          'S0・S1と同様に、スタート後の事故のためファンへの金銭的な救済はありません。\n\n'
          '・舟券は返還されません（不的中・ハズレ扱い）\n'
          '・被害者側の艇（巻き込まれて転覆した艇＝S0）の舟券を買っていても、'
          'スタート後の事故のためお金は戻りません\n'
          '・加害者（S2）のせいで、被害者（S0）を買っていたファンの舟券まで'
          '一瞬で紙屑になります\n\n'
          '【S1 vs S2】\n'
          '・S1（選手責任失格）：自分だけがコケて失格・事故点15点・即日帰郷・舟券返還なし\n'
          '・S2（妨害失格）　　：他艇を巻き込んで潰した・事故点15点・即日帰郷＋出場制限リスク・舟券返還なし\n\n'
          'S2は単なる操縦ミス（S1）ではなく、「他人のレースまで巻き添えにしてブチ壊した」'
          'ことに対する厳罰コードです。選手にとっては選手生命に関わる大ペナルティであり、'
          'ファンにとっては最も巻き込まれたくない最悪のアクシデントと言えます。',
    };

    void showDetail(BuildContext ctx, int colIndex) {
      final code = colNames[colIndex];
      final description = codeDescriptions[code];
      showDialog(
        context: ctx,
        builder: (dialogContext) => AlertDialog(
          title: Text('コース別事故数（$code）'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Table(
                  border: TableBorder.all(color: Colors.grey.shade300),
                  defaultColumnWidth: const IntrinsicColumnWidth(),
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Colors.grey[200]),
                      children: [
                        for (int lane = 1; lane <= 6; lane++)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: Text(
                              '$lane',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
                    TableRow(
                      children: [
                        for (int lane = 0; lane < 6; lane++)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: Text(
                              courseValues[lane][colIndex]?.toString() ?? '-',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: (courseValues[lane][colIndex] == null ||
                                        courseValues[lane][colIndex] == 0)
                                    ? Colors.grey
                                    : Colors.black,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                if (description != null) ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 4),
                  Text(description, style: const TextStyle(fontSize: 16)),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('閉じる'),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Table(
              border: TableBorder.all(color: Colors.grey.shade300),
              defaultColumnWidth: const FlexColumnWidth(),
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey[300]),
                  children: [
                    for (final col in tableColumns)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: DefaultTextStyle(
                          style: const TextStyle(
                            fontSize: _kTableFontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          child: col.label,
                        ),
                      ),
                  ],
                ),
                TableRow(
                  children: [
                    for (int j = 0; j < 8; j++)
                      GestureDetector(
                        onTap: () => showDetail(context, j),
                        child: Container(
                          color: totals[j] != 0 ? Colors.red[100] : Colors.grey[200],
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            '${totals[j]}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: _kTableFontSize,
                              fontWeight: FontWeight.bold,
                              color: totals[j] != 0 ? Colors.red[800] : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(top: 4, left: 4),
              child: Text(
                '数字をタップするとコース別を表示',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
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
