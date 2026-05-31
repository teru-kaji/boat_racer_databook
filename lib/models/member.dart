// lib/models/member.dart
import 'package:objectbox/objectbox.dart';

@Entity()
class Member {
  @Id()
  int id = 0;

  // v + JSONキー名 で統一
  @Index()
  String? vdt;    // dt
  @Index()
  String? vno;    // no
  @Index()
  String? vname;  // name
  @Index()
  String? vkana;  // kana
  @Index()
  String? vkana2; // kana2
  @Index()
  String? vkana3; // kana3
  @Index()
  String? vbr;    // br
  @Index()
  String? vrank;  // rank
  @Index()
  int? vsex;      // sex
  @Index()
  int? vGene;     // Gene

  String? vwbday; // wbday
  String? vgbday; // gbday
  int? vage;      // age
  double? vht;    // ht
  double? vwt;    // wt
  String? vblood; // blood
  String? vbirth; // birth
  String? vphurl; // phurl

  double? vwinPt; // winPt
  double? vwr12;  // wr12
  int? vp1Cnt;    // p1Cnt
  int? vp2Cnt;    // p2Cnt
  int? vraceN;    // raceN
  int? vfinalN;   // finalN
  int? vwinN;     // vwinN
  double? vstAvg; // stAvg

  String? vrkP1, vrkP2, vrkP3; // rkP1, rkP2, rkP3
  int? vabPast, vabLast;       // abPast, abLast
  int? vyear;                  // year
  String? vseason, vsDate, veDate; // season, sDate, eDate

  // コース別 (vc1...vc6)
  int? vc1Ent, vc2Ent, vc3Ent, vc4Ent, vc5Ent, vc6Ent;
  double? vc1Wr, vc2Wr, vc3Wr, vc4Wr, vc5Wr, vc6Wr;
  double? vc1St, vc2St, vc3St, vc4St, vc5St, vc6St;
  double? vc1So, vc2So, vc3So, vc4So, vc5So, vc6So;
  int? vc1P1, vc2P1, vc3P1, vc4P1, vc5P1, vc6P1;
  int? vc1P2, vc2P2, vc3P2, vc4P2, vc5P2, vc6P2;
  int? vc1P3, vc2P3, vc3P3, vc4P3, vc5P3, vc6P3;
  int? vc1P4, vc2P4, vc3P4, vc4P4, vc5P4, vc6P4;
  int? vc1P5, vc2P5, vc3P5, vc4P5, vc5P5, vc6P5;
  int? vc1P6, vc2P6, vc3P6, vc4P6, vc5P6, vc6P6;
  int? vc1Fs, vc2Fs, vc3Fs, vc4Fs, vc5Fs, vc6Fs;
  int? vc1LsNr, vc2LsNr, vc3LsNr, vc4LsNr, vc5LsNr, vc6LsNr;
  int? vc1LsR, vc2LsR, vc3LsR, vc4LsR, vc5LsR, vc6LsR;
  int? vc1WdNr, vc2WdNr, vc3WdNr, vc4WdNr, vc5WdNr, vc6WdNr;
  int? vc1WdR, vc2WdR, vc3WdR, vc4WdR, vc5WdR, vc6WdR;
  int? vc1InvNr, vc2InvNr, vc3InvNr, vc4InvNr, vc5InvNr, vc6InvNr;
  int? vc1InvR, vc2InvR, vc3InvR, vc4InvR, vc5InvR, vc6InvR;
  int? vc1InvOb, vc2InvOb, vc3InvOb, vc4InvOb, vc5InvOb, vc6InvOb;

  Member({
    this.id = 0, this.vdt, this.vno, this.vname, this.vkana, this.vkana2, this.vkana3, this.vbr, this.vrank, this.vsex, this.vGene,
    this.vwbday, this.vgbday, this.vage, this.vht, this.vwt, this.vblood, this.vbirth, this.vphurl,
    this.vwinPt, this.vwr12, this.vp1Cnt, this.vp2Cnt, this.vraceN, this.vfinalN, this.vwinN, this.vstAvg,
    this.vrkP1, this.vrkP2, this.vrkP3, this.vabPast, this.vabLast, this.vyear, this.vseason, this.vsDate, this.veDate,
    this.vc1Ent, this.vc2Ent, this.vc3Ent, this.vc4Ent, this.vc5Ent, this.vc6Ent,
    this.vc1Wr, this.vc2Wr, this.vc3Wr, this.vc4Wr, this.vc5Wr, this.vc6Wr,
    this.vc1St, this.vc2St, this.vc3St, this.vc4St, this.vc5St, this.vc6St,
    this.vc1So, this.vc2So, this.vc3So, this.vc4So, this.vc5So, this.vc6So,
    this.vc1P1, this.vc2P1, this.vc3P1, this.vc4P1, this.vc5P1, this.vc6P1,
    this.vc1P2, this.vc2P2, this.vc3P2, this.vc4P2, this.vc5P2, this.vc6P2,
    this.vc1P3, this.vc2P3, this.vc3P3, this.vc4P3, this.vc5P3, this.vc6P3,
    this.vc1P4, this.vc2P4, this.vc3P4, this.vc4P4, this.vc5P4, this.vc6P4,
    this.vc1P5, this.vc2P5, this.vc3P5, this.vc4P5, this.vc5P5, this.vc6P5,
    this.vc1P6, this.vc2P6, this.vc3P6, this.vc4P6, this.vc5P6, this.vc6P6,
    this.vc1Fs, this.vc2Fs, this.vc3Fs, this.vc4Fs, this.vc5Fs, this.vc6Fs,
    this.vc1LsNr, this.vc2LsNr, this.vc3LsNr, this.vc4LsNr, this.vc5LsNr, this.vc6LsNr,
    this.vc1LsR, this.vc2LsR, this.vc3LsR, this.vc4LsR, this.vc5LsR, this.vc6LsR,
    this.vc1WdNr, this.vc2WdNr, this.vc3WdNr, this.vc4WdNr, this.vc5WdNr, this.vc6WdNr,
    this.vc1WdR, this.vc2WdR, this.vc3WdR, this.vc4WdR, this.vc5WdR, this.vc6WdR,
    this.vc1InvNr, this.vc2InvNr, this.vc3InvNr, this.vc4InvNr, this.vc5InvNr, this.vc6InvNr,
    this.vc1InvR, this.vc2InvR, this.vc3InvR, this.vc4InvR, this.vc5InvR, this.vc6InvR,
    this.vc1InvOb, this.vc2InvOb, this.vc3InvOb, this.vc4InvOb, this.vc5InvOb, this.vc6InvOb,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    String? s(String key) => json[key]?.toString().trim();
    int? pi(String key) {
      final val = s(key);
      if (val == null || val.isEmpty) return null;
      return double.tryParse(val.replaceAll(RegExp(r'[^0-9.-]'), ''))?.toInt();
    }
    double? pd(String key, {bool isPercent = false}) {
      final val = s(key);
      if (val == null || val.isEmpty) return null;
      double? d = double.tryParse(val.replaceAll('%', ''));
      if (isPercent && d != null && d >= 0 && d <= 1.0) d *= 100.0;
      return d;
    }

    return Member(
      id: pi('id') ?? 0,
      vdt: s('dt'), vno: s('no'), vname: s('name'), vkana: s('kana'), vkana2: s('kana2'), vkana3: s('kana3'), vbr: s('br'), vrank: s('rank'), vsex: pi('sex'), vGene: pi('Gene'),
      vwbday: s('wbday'), vgbday: s('gbday'), vage: pi('age'), vht: pd('ht'), vwt: pd('wt'), vblood: s('blood'), vbirth: s('birth'), vphurl: s('phurl'),
      vwinPt: pd('winPt'), vwr12: pd('wr12', isPercent: true), vp1Cnt: pi('p1Cnt'), vp2Cnt: pi('p2Cnt'), vraceN: pi('raceN'), vfinalN: pi('finalN'), vwinN: pi('winN'), vstAvg: pd('stAvg'),
      vrkP1: s('rkP1'), vrkP2: s('rkP2'), vrkP3: s('rkP3'), vabPast: pi('abPast'), vabLast: pi('abLast'), vyear: pi('year'), vseason: s('season'), vsDate: s('sDate'), veDate: s('eDate'),
      vc1Ent: pi('c1Ent'), vc2Ent: pi('c2Ent'), vc3Ent: pi('c3Ent'), vc4Ent: pi('c4Ent'), vc5Ent: pi('c5Ent'), vc6Ent: pi('c6Ent'),
      vc1Wr: pd('c1Wr', isPercent: true), vc2Wr: pd('c2Wr', isPercent: true), vc3Wr: pd('c3Wr', isPercent: true), vc4Wr: pd('c4Wr', isPercent: true), vc5Wr: pd('c5Wr', isPercent: true), vc6Wr: pd('c6Wr', isPercent: true),
      vc1St: pd('c1St'), vc2St: pd('c2St'), vc3St: pd('c3St'), vc4St: pd('c4St'), vc5St: pd('c5St'), vc6St: pd('c6St'),
      vc1So: pd('c1So'), vc2So: pd('c2So'), vc3So: pd('c3So'), vc4So: pd('c4So'), vc5So: pd('c5So'), vc6So: pd('c6So'),
      vc1P1: pi('c1P1'), vc2P1: pi('c2P1'), vc3P1: pi('c3P1'), vc4P1: pi('c4P1'), vc5P1: pi('c5P1'), vc6P1: pi('c6P1'),
      vc1P2: pi('c1P2'), vc2P2: pi('c2P2'), vc3P2: pi('c3P2'), vc4P2: pi('c4P2'), vc5P2: pi('c5P2'), vc6P2: pi('c6P2'),
      vc1P3: pi('c1P3'), vc2P3: pi('c2P3'), vc3P3: pi('c3P3'), vc4P3: pi('c4P3'), vc5P3: pi('c5P3'), vc6P3: pi('c6P3'),
      vc1P4: pi('c1P4'), vc2P4: pi('c2P4'), vc3P4: pi('c3P4'), vc4P4: pi('c4P4'), vc5P4: pi('c5P4'), vc6P4: pi('c6P4'),
      vc1P5: pi('c1P5'), vc2P5: pi('c2P5'), vc3P5: pi('c3P5'), vc4P5: pi('c4P5'), vc5P5: pi('c5P5'), vc6P5: pi('c6P5'),
      vc1P6: pi('c1P6'), vc2P6: pi('c2P6'), vc3P6: pi('c3P6'), vc4P6: pi('c4P6'), vc5P6: pi('c5P6'), vc6P6: pi('c6P6'),
      vc1Fs: pi('c1Fs'), vc2Fs: pi('c2Fs'), vc3Fs: pi('c3Fs'), vc4Fs: pi('c4Fs'), vc5Fs: pi('c5Fs'), vc6Fs: pi('c6Fs'),
      vc1LsNr: pi('c1LsNr'), vc2LsNr: pi('c2LsNr'), vc3LsNr: pi('c3LsNr'), vc4LsNr: pi('c4LsNr'), vc5LsNr: pi('c5LsNr'), vc6LsNr: pi('c6LsNr'),
      vc1LsR: pi('c1LsR'), vc2LsR: pi('c2LsR'), vc3LsR: pi('c3LsR'), vc4LsR: pi('c4LsR'), vc5LsR: pi('c5LsR'), vc6LsR: pi('c6LsR'),
      vc1WdNr: pi('c1WdNr'), vc2WdNr: pi('c2WdNr'), vc3WdNr: pi('c3WdNr'), vc4WdNr: pi('c4WdNr'), vc5WdNr: pi('c5WdNr'), vc6WdNr: pi('c6WdNr'),
      vc1WdR: pi('c1WdR'), vc2WdR: pi('c2WdR'), vc3WdR: pi('c3WdR'), vc4WdR: pi('c4WdR'), vc5WdR: pi('c5WdR'), vc6WdR: pi('c6WdR'),
      vc1InvNr: pi('c1InvNr'), vc2InvNr: pi('c2InvNr'), vc3InvNr: pi('c3InvNr'), vc4InvNr: pi('c4InvNr'), vc5InvNr: pi('c5InvNr'), vc6InvNr: pi('c6InvNr'),
      vc1InvR: pi('c1InvR'), vc2InvR: pi('c2InvR'), vc3InvR: pi('c3InvR'), vc4InvR: pi('c4InvR'), vc5InvR: pi('c5InvR'), vc6InvR: pi('c6InvR'),
      vc1InvOb: pi('c1InvOb'), vc2InvOb: pi('c2InvOb'), vc3InvOb: pi('c3InvOb'), vc4InvOb: pi('c4InvOb'), vc5InvOb: pi('c5InvOb'), vc6InvOb: pi('c6InvOb'),
    );
  }
}
