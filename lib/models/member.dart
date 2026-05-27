// lib/models/member.dart
//
import 'package:objectbox/objectbox.dart';

@Entity()
class Member {
  @Id()
  int id = 0;

  @Index()
  String? dataTime;

  @Index()
  String? number;

  @Index()
  String? name;

  @Index()
  String? nameKana;

  @Index()
  String? kana3;

  @Index()
  String? kana;

  @Index()
  String? rank;

  @Index()
  int? sex; // String -> int

  // 基本情報
  String? kana2;
  String? branch;
  String? wBirthday;
  String? gBirthday;
  int? age;       // String -> int
  double? height; // String -> double
  double? weight; // String -> double
  String? blood;
  String? birthplace;
  String? photo;

  // 成績関連
  double? winPointRate;    // String -> double
  double? winRate12;       // String -> double
  int? firstPlaceCount;    // String -> int
  int? secondPlaceCount;   // String -> int
  int? numberOfRace;       // String -> int
  int? numberOfFinals;     // String -> int
  int? numberOfWins;       // String -> int
  double? startTiming;     // String -> double

  // 過去ランク・能力値
  String? rankPast1;
  String? rankPast2;
  String? rankPast3;
  int? pastAbilityScore;   // String -> int
  int? lastAbilityScore;   // String -> int

  // データ年度・期
  int? dataYear;           // String -> int
  String? dataSeason;
  String? startDate;
  String? endDate;
  int? generation;         // String -> int

  // ===== コース別 (String -> int/double) =====
  int? numberOfEntries1, numberOfEntries2, numberOfEntries3, numberOfEntries4, numberOfEntries5, numberOfEntries6;
  double? winRate121, winRate122, winRate123, winRate124, winRate125, winRate126;
  double? startTime1, startTime2, startTime3, startTime4, startTime5, startTime6;
  double? startOrder1, startOrder2, startOrder3, startOrder4, startOrder5, startOrder6;

  int? firstPlace1, firstPlace2, firstPlace3, firstPlace4, firstPlace5, firstPlace6;
  int? secondPlace1, secondPlace2, secondPlace3, secondPlace4, secondPlace5, secondPlace6;
  int? thirdPlace1, thirdPlace2, thirdPlace3, thirdPlace4, thirdPlace5, thirdPlace6;
  int? fourthPlace1, fourthPlace2, fourthPlace3, fourthPlace4, fourthPlace5, fourthPlace6;
  int? fifthPlace1, fifthPlace2, fifthPlace3, fifthPlace4, fifthPlace5, fifthPlace6;
  int? sixthPlace1, sixthPlace2, sixthPlace3, sixthPlace4, sixthPlace5, sixthPlace6;

  int? falseStart1, falseStart2, falseStart3, falseStart4, falseStart5, falseStart6;
  int? lateStartNoResponsibility1, lateStartNoResponsibility2, lateStartNoResponsibility3, lateStartNoResponsibility4, lateStartNoResponsibility5, lateStartNoResponsibility6;
  int? lateStartOnResponsibility1, lateStartOnResponsibility2, lateStartOnResponsibility3, lateStartOnResponsibility4, lateStartOnResponsibility5, lateStartOnResponsibility6;
  int? withdrawNoResponsibility1, withdrawNoResponsibility2, withdrawNoResponsibility3, withdrawNoResponsibility4, withdrawNoResponsibility5, withdrawNoResponsibility6;
  int? withdrawOnResponsibility1, withdrawOnResponsibility2, withdrawOnResponsibility3, withdrawOnResponsibility4, withdrawOnResponsibility5, withdrawOnResponsibility6;
  int? invalidNoResponsibility1, invalidNoResponsibility2, invalidNoResponsibility3, invalidNoResponsibility4, invalidNoResponsibility5, invalidNoResponsibility6;
  int? invalidOnResponsibility1, invalidOnResponsibility2, invalidOnResponsibility3, invalidOnResponsibility4, invalidOnResponsibility5, invalidOnResponsibility6;
  int? invalidOnObstruction1, invalidOnObstruction2, invalidOnObstruction3, invalidOnObstruction4, invalidOnObstruction5, invalidOnObstruction6;

  Member({
    this.id = 0,
    this.dataTime,
    this.number,
    this.name,
    this.nameKana,
    this.kana,
    this.kana2,
    this.kana3,
    this.branch,
    this.rank,
    this.wBirthday,
    this.gBirthday,
    this.sex,
    this.age,
    this.height,
    this.weight,
    this.blood,
    this.birthplace,
    this.photo,
    this.winPointRate,
    this.winRate12,
    this.firstPlaceCount,
    this.secondPlaceCount,
    this.numberOfRace,
    this.numberOfFinals,
    this.numberOfWins,
    this.startTiming,
    this.rankPast1,
    this.rankPast2,
    this.rankPast3,
    this.pastAbilityScore,
    this.lastAbilityScore,
    this.dataYear,
    this.dataSeason,
    this.startDate,
    this.endDate,
    this.generation,
    this.numberOfEntries1, this.numberOfEntries2, this.numberOfEntries3, this.numberOfEntries4, this.numberOfEntries5, this.numberOfEntries6,
    this.winRate121, this.winRate122, this.winRate123, this.winRate124, this.winRate125, this.winRate126,
    this.startTime1, this.startTime2, this.startTime3, this.startTime4, this.startTime5, this.startTime6,
    this.startOrder1, this.startOrder2, this.startOrder3, this.startOrder4, this.startOrder5, this.startOrder6,
    this.firstPlace1, this.firstPlace2, this.firstPlace3, this.firstPlace4, this.firstPlace5, this.firstPlace6,
    this.secondPlace1, this.secondPlace2, this.secondPlace3, this.secondPlace4, this.secondPlace5, this.secondPlace6,
    this.thirdPlace1, this.thirdPlace2, this.thirdPlace3, this.thirdPlace4, this.thirdPlace5, this.thirdPlace6,
    this.fourthPlace1, this.fourthPlace2, this.fourthPlace3, this.fourthPlace4, this.fourthPlace5, this.fourthPlace6,
    this.fifthPlace1, this.fifthPlace2, this.fifthPlace3, this.fifthPlace4, this.fifthPlace5, this.fifthPlace6,
    this.sixthPlace1, this.sixthPlace2, this.sixthPlace3, this.sixthPlace4, this.sixthPlace5, this.sixthPlace6,
    this.falseStart1, this.falseStart2, this.falseStart3, this.falseStart4, this.falseStart5, this.falseStart6,
    this.lateStartNoResponsibility1, this.lateStartNoResponsibility2, this.lateStartNoResponsibility3, this.lateStartNoResponsibility4, this.lateStartNoResponsibility5, this.lateStartNoResponsibility6,
    this.lateStartOnResponsibility1, this.lateStartOnResponsibility2, this.lateStartOnResponsibility3, this.lateStartOnResponsibility4, this.lateStartOnResponsibility5, this.lateStartOnResponsibility6,
    this.withdrawNoResponsibility1, this.withdrawNoResponsibility2, this.withdrawNoResponsibility3, this.withdrawNoResponsibility4, this.withdrawNoResponsibility5, this.withdrawNoResponsibility6,
    this.withdrawOnResponsibility1, this.withdrawOnResponsibility2, this.withdrawOnResponsibility3, this.withdrawOnResponsibility4, this.withdrawOnResponsibility5, this.withdrawOnResponsibility6,
    this.invalidNoResponsibility1, this.invalidNoResponsibility2, this.invalidNoResponsibility3, this.invalidNoResponsibility4, this.invalidNoResponsibility5, this.invalidNoResponsibility6,
    this.invalidOnResponsibility1, this.invalidOnResponsibility2, this.invalidOnResponsibility3, this.invalidOnResponsibility4, this.invalidOnResponsibility5, this.invalidOnResponsibility6,
    this.invalidOnObstruction1, this.invalidOnObstruction2, this.invalidOnObstruction3, this.invalidOnObstruction4, this.invalidOnObstruction5, this.invalidOnObstruction6,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    String? s(String key) => json[key]?.toString();
    
    int? pi(String key) {
      final val = s(key);
      if (val == null || val.isEmpty) return null;
      return int.tryParse(val.replaceAll(RegExp(r'[^0-9-]'), ''));
    }
    
    double? pd(String key) {
      final val = s(key);
      if (val == null || val.isEmpty) return null;
      return double.tryParse(val.replaceAll('%', ''));
    }

    return Member(
      id: pi('Id') ?? 0,
      dataTime: s('DataTime'),
      number: s('Number'),
      name: s('Name'),
      nameKana: s('NameKana'),
      kana: s('Kana'),
      kana2: s('Kana2'),
      kana3: s('Kana3'),
      branch: s('Branch'),
      rank: s('Rank'),
      wBirthday: s('WBirthday'),
      gBirthday: s('GBirthday'),
      sex: pi('Sex'),
      age: pi('Age'),
      height: pd('Height'),
      weight: pd('Weight'),
      blood: s('Blood'),
      birthplace: s('Birthplace'),
      photo: s('Photo'),
      winPointRate: pd('WinPointRate'),
      winRate12: pd('WinRate12'),
      firstPlaceCount: pi('1stPlaceCount'),
      secondPlaceCount: pi('2ndPlaceCount'),
      numberOfRace: pi('NumberOfRace'),
      numberOfFinals: pi('NumberOfFinals'),
      numberOfWins: pi('NumberOfWins'),
      startTiming: pd('StartTiming'),
      rankPast1: s('RankPast1'),
      rankPast2: s('RankPast2'),
      rankPast3: s('RankPast3'),
      pastAbilityScore: pi('PastAbilityScore'),
      lastAbilityScore: pi('LastAbilityScore'),
      dataYear: pi('DataYear'),
      dataSeason: s('DataSeason'),
      startDate: s('StartDate'),
      endDate: s('EndDate'),
      generation: pi('Genetation'),

      numberOfEntries1: pi('NumberOfEntries#1'),
      numberOfEntries2: pi('NumberOfEntries#2'),
      numberOfEntries3: pi('NumberOfEntries#3'),
      numberOfEntries4: pi('NumberOfEntries#4'),
      numberOfEntries5: pi('NumberOfEntries#5'),
      numberOfEntries6: pi('NumberOfEntries#6'),

      winRate121: pd('WinRate12#1'),
      winRate122: pd('WinRate12#2'),
      winRate123: pd('WinRate12#3'),
      winRate124: pd('WinRate12#4'),
      winRate125: pd('WinRate12#5'),
      winRate126: pd('WinRate12#6'),

      startTime1: pd('StartTime#1'),
      startTime2: pd('StartTime#2'),
      startTime3: pd('StartTime#3'),
      startTime4: pd('StartTime#4'),
      startTime5: pd('StartTime#5'),
      startTime6: pd('StartTime#6'),

      startOrder1: pd('StartOrder#1'),
      startOrder2: pd('StartOrder#2'),
      startOrder3: pd('StartOrder#3'),
      startOrder4: pd('StartOrder#4'),
      startOrder5: pd('StartOrder#5'),
      startOrder6: pd('StartOrder#6'),

      firstPlace1: pi('1stPlace#1'),
      firstPlace2: pi('1stPlace#2'),
      firstPlace3: pi('1stPlace#3'),
      firstPlace4: pi('1stPlace#4'),
      firstPlace5: pi('1stPlace#5'),
      firstPlace6: pi('1stPlace#6'),

      secondPlace1: pi('2ndPlace#1'),
      secondPlace2: pi('2ndPlace#2'),
      secondPlace3: pi('2ndPlace#3'),
      secondPlace4: pi('2ndPlace#4'),
      secondPlace5: pi('2ndPlace#5'),
      secondPlace6: pi('2ndPlace#6'),

      thirdPlace1: pi('3rdPlace#1'),
      thirdPlace2: pi('3rdPlace#2'),
      thirdPlace3: pi('3rdPlace#3'),
      thirdPlace4: pi('3rdPlace#4'),
      thirdPlace5: pi('3rdPlace#5'),
      thirdPlace6: pi('3rdPlace#6'),

      fourthPlace1: pi('4thPlace#1'),
      fourthPlace2: pi('4thPlace#2'),
      fourthPlace3: pi('4thPlace#3'),
      fourthPlace4: pi('4thPlace#4'),
      fourthPlace5: pi('4thPlace#5'),
      fourthPlace6: pi('4thPlace#6'),

      fifthPlace1: pi('5thPlace#1'),
      fifthPlace2: pi('5thPlace#2'),
      fifthPlace3: pi('5thPlace#3'),
      fifthPlace4: pi('5thPlace#4'),
      fifthPlace5: pi('5thPlace#5'),
      fifthPlace6: pi('5thPlace#6'),

      sixthPlace1: pi('6thPlace#1'),
      sixthPlace2: pi('6thPlace#2'),
      sixthPlace3: pi('6thPlace#3'),
      sixthPlace4: pi('6thPlace#4'),
      sixthPlace5: pi('6thPlace#5'),
      sixthPlace6: pi('6thPlace#6'),

      falseStart1: pi('FalseStart#1'),
      falseStart2: pi('FalseStart#2'),
      falseStart3: pi('FalseStart#3'),
      falseStart4: pi('FalseStart#4'),
      falseStart5: pi('FalseStart#5'),
      falseStart6: pi('FalseStart#6'),

      lateStartNoResponsibility1: pi('LateStartNoResponsibility#1'),
      lateStartNoResponsibility2: pi('LateStartNoResponsibility#2'),
      lateStartNoResponsibility3: pi('LateStartNoResponsibility#3'),
      lateStartNoResponsibility4: pi('LateStartNoResponsibility#4'),
      lateStartNoResponsibility5: pi('LateStartNoResponsibility#5'),
      lateStartNoResponsibility6: pi('LateStartNoResponsibility#6'),

      lateStartOnResponsibility1: pi('LateStartOnResponsibility#1'),
      lateStartOnResponsibility2: pi('LateStartOnResponsibility#2'),
      lateStartOnResponsibility3: pi('LateStartOnResponsibility#3'),
      lateStartOnResponsibility4: pi('LateStartOnResponsibility#4'),
      lateStartOnResponsibility5: pi('LateStartOnResponsibility#5'),
      lateStartOnResponsibility6: pi('LateStartOnResponsibility#6'),

      withdrawNoResponsibility1: pi('WithdrawNoResponsibility#1'),
      withdrawNoResponsibility2: pi('WithdrawNoResponsibility#2'),
      withdrawNoResponsibility3: pi('WithdrawNoResponsibility#3'),
      withdrawNoResponsibility4: pi('WithdrawNoResponsibility#4'),
      withdrawNoResponsibility5: pi('WithdrawNoResponsibility#5'),
      withdrawNoResponsibility6: pi('WithdrawNoResponsibility#6'),

      withdrawOnResponsibility1: pi('WithdrawOnResponsibility#1'),
      withdrawOnResponsibility2: pi('WithdrawOnResponsibility#2'),
      withdrawOnResponsibility3: pi('WithdrawOnResponsibility#3'),
      withdrawOnResponsibility4: pi('WithdrawOnResponsibility#4'),
      withdrawOnResponsibility5: pi('WithdrawOnResponsibility#5'),
      withdrawOnResponsibility6: pi('WithdrawOnResponsibility#6'),

      invalidNoResponsibility1: pi('InvalidNoResponsibility#1'),
      invalidNoResponsibility2: pi('InvalidNoResponsibility#2'),
      invalidNoResponsibility3: pi('InvalidNoResponsibility#3'),
      invalidNoResponsibility4: pi('InvalidNoResponsibility#4'),
      invalidNoResponsibility5: pi('InvalidNoResponsibility#5'),
      invalidNoResponsibility6: pi('InvalidNoResponsibility#6'),

      invalidOnResponsibility1: pi('InvalidOnResponsibility#1'),
      invalidOnResponsibility2: pi('InvalidOnResponsibility#2'),
      invalidOnResponsibility3: pi('InvalidOnResponsibility#3'),
      invalidOnResponsibility4: pi('InvalidOnResponsibility#4'),
      invalidOnResponsibility5: pi('InvalidOnResponsibility#5'),
      invalidOnResponsibility6: pi('InvalidOnResponsibility#6'),

      invalidOnObstruction1: pi('InvalidOnObstruction#1'),
      invalidOnObstruction2: pi('InvalidOnObstruction#2'),
      invalidOnObstruction3: pi('InvalidOnObstruction#3'),
      invalidOnObstruction4: pi('InvalidOnObstruction#4'),
      invalidOnObstruction5: pi('InvalidOnObstruction#5'),
      invalidOnObstruction6: pi('InvalidOnObstruction#6'),
    );
  }
}
