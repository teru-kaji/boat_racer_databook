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
  String? sex;

  // 基本情報
  //String? dataTime;
  //String? number;
  //String? name;
  //String? nameKana;
  //String? kana;
  String? kana2;
  //String? kana3;
  String? blanch;
  //String? rank;
  String? wBirthday;
  String? gBirthday;
  //String? sex;
  String? age;
  String? height;
  String? weight;
  String? blood;
  String? birthplace;
  String? photo;

  // 成績関連
  String? winPointRate;
  String? winRate12;
  String? firstPlaceCount;
  String? secondPlaceCount;
  String? numberOfRace;
  String? numberOfFinals;
  String? numberOfWins;
  String? startTiming;

  // 過去ランク・能力値
  String? rankPast1;
  String? rankPast2;
  String? rankPast3;
  String? pastAbilityScore;
  String? lastAbilityScore;

  // データ年度・期
  String? dataYear;
  String? dataSeason;
  String? startDate;
  String? endDate;
  String? generation;

  // ===== コース別 =====
  String? numberOfEntries1;
  String? numberOfEntries2;
  String? numberOfEntries3;
  String? numberOfEntries4;
  String? numberOfEntries5;
  String? numberOfEntries6;

  String? winRate121;
  String? winRate122;
  String? winRate123;
  String? winRate124;
  String? winRate125;
  String? winRate126;

  String? startTime1;
  String? startTime2;
  String? startTime3;
  String? startTime4;
  String? startTime5;
  String? startTime6;

  String? startOrder1;
  String? startOrder2;
  String? startOrder3;
  String? startOrder4;
  String? startOrder5;
  String? startOrder6;

  String? firstPlace1;
  String? firstPlace2;
  String? firstPlace3;
  String? firstPlace4;
  String? firstPlace5;
  String? firstPlace6;

  String? secondPlace1;
  String? secondPlace2;
  String? secondPlace3;
  String? secondPlace4;
  String? secondPlace5;
  String? secondPlace6;

  String? thirdPlace1;
  String? thirdPlace2;
  String? thirdPlace3;
  String? thirdPlace4;
  String? thirdPlace5;
  String? thirdPlace6;

  String? fourthPlace1;
  String? fourthPlace2;
  String? fourthPlace3;
  String? fourthPlace4;
  String? fourthPlace5;
  String? fourthPlace6;

  String? fifthPlace1;
  String? fifthPlace2;
  String? fifthPlace3;
  String? fifthPlace4;
  String? fifthPlace5;
  String? fifthPlace6;

  String? sixthPlace1;
  String? sixthPlace2;
  String? sixthPlace3;
  String? sixthPlace4;
  String? sixthPlace5;
  String? sixthPlace6;

  String? falseStart1;
  String? falseStart2;
  String? falseStart3;
  String? falseStart4;
  String? falseStart5;
  String? falseStart6;

  String? lateStartNoResponsibility1;
  String? lateStartNoResponsibility2;
  String? lateStartNoResponsibility3;
  String? lateStartNoResponsibility4;
  String? lateStartNoResponsibility5;
  String? lateStartNoResponsibility6;

  String? lateStartOnResponsibility1;
  String? lateStartOnResponsibility2;
  String? lateStartOnResponsibility3;
  String? lateStartOnResponsibility4;
  String? lateStartOnResponsibility5;
  String? lateStartOnResponsibility6;

  String? withdrawNoResponsibility1;
  String? withdrawNoResponsibility2;
  String? withdrawNoResponsibility3;
  String? withdrawNoResponsibility4;
  String? withdrawNoResponsibility5;
  String? withdrawNoResponsibility6;

  String? withdrawOnResponsibility1;
  String? withdrawOnResponsibility2;
  String? withdrawOnResponsibility3;
  String? withdrawOnResponsibility4;
  String? withdrawOnResponsibility5;
  String? withdrawOnResponsibility6;

  String? invalidNoResponsibility1;
  String? invalidNoResponsibility2;
  String? invalidNoResponsibility3;
  String? invalidNoResponsibility4;
  String? invalidNoResponsibility5;
  String? invalidNoResponsibility6;

  String? invalidOnResponsibility1;
  String? invalidOnResponsibility2;
  String? invalidOnResponsibility3;
  String? invalidOnResponsibility4;
  String? invalidOnResponsibility5;
  String? invalidOnResponsibility6;

  String? invalidOnObstruction1;
  String? invalidOnObstruction2;
  String? invalidOnObstruction3;
  String? invalidOnObstruction4;
  String? invalidOnObstruction5;
  String? invalidOnObstruction6;

  // ---- ここが修正点：全フィールドをコンストラクタに追加 ----
  Member({
    this.id = 0,
    this.dataTime,
    this.number,
    this.name,
    this.nameKana,
    this.kana,
    this.kana2,
    this.kana3,
    this.blanch,
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
    this.numberOfEntries1,
    this.numberOfEntries2,
    this.numberOfEntries3,
    this.numberOfEntries4,
    this.numberOfEntries5,
    this.numberOfEntries6,
    this.winRate121,
    this.winRate122,
    this.winRate123,
    this.winRate124,
    this.winRate125,
    this.winRate126,
    this.startTime1,
    this.startTime2,
    this.startTime3,
    this.startTime4,
    this.startTime5,
    this.startTime6,
    this.startOrder1,
    this.startOrder2,
    this.startOrder3,
    this.startOrder4,
    this.startOrder5,
    this.startOrder6,
    this.firstPlace1,
    this.firstPlace2,
    this.firstPlace3,
    this.firstPlace4,
    this.firstPlace5,
    this.firstPlace6,
    this.secondPlace1,
    this.secondPlace2,
    this.secondPlace3,
    this.secondPlace4,
    this.secondPlace5,
    this.secondPlace6,
    this.thirdPlace1,
    this.thirdPlace2,
    this.thirdPlace3,
    this.thirdPlace4,
    this.thirdPlace5,
    this.thirdPlace6,
    this.fourthPlace1,
    this.fourthPlace2,
    this.fourthPlace3,
    this.fourthPlace4,
    this.fourthPlace5,
    this.fourthPlace6,
    this.fifthPlace1,
    this.fifthPlace2,
    this.fifthPlace3,
    this.fifthPlace4,
    this.fifthPlace5,
    this.fifthPlace6,
    this.sixthPlace1,
    this.sixthPlace2,
    this.sixthPlace3,
    this.sixthPlace4,
    this.sixthPlace5,
    this.sixthPlace6,
    this.falseStart1,
    this.falseStart2,
    this.falseStart3,
    this.falseStart4,
    this.falseStart5,
    this.falseStart6,
    this.lateStartNoResponsibility1,
    this.lateStartNoResponsibility2,
    this.lateStartNoResponsibility3,
    this.lateStartNoResponsibility4,
    this.lateStartNoResponsibility5,
    this.lateStartNoResponsibility6,
    this.lateStartOnResponsibility1,
    this.lateStartOnResponsibility2,
    this.lateStartOnResponsibility3,
    this.lateStartOnResponsibility4,
    this.lateStartOnResponsibility5,
    this.lateStartOnResponsibility6,
    this.withdrawNoResponsibility1,
    this.withdrawNoResponsibility2,
    this.withdrawNoResponsibility3,
    this.withdrawNoResponsibility4,
    this.withdrawNoResponsibility5,
    this.withdrawNoResponsibility6,
    this.withdrawOnResponsibility1,
    this.withdrawOnResponsibility2,
    this.withdrawOnResponsibility3,
    this.withdrawOnResponsibility4,
    this.withdrawOnResponsibility5,
    this.withdrawOnResponsibility6,
    this.invalidNoResponsibility1,
    this.invalidNoResponsibility2,
    this.invalidNoResponsibility3,
    this.invalidNoResponsibility4,
    this.invalidNoResponsibility5,
    this.invalidNoResponsibility6,
    this.invalidOnResponsibility1,
    this.invalidOnResponsibility2,
    this.invalidOnResponsibility3,
    this.invalidOnResponsibility4,
    this.invalidOnResponsibility5,
    this.invalidOnResponsibility6,
    this.invalidOnObstruction1,
    this.invalidOnObstruction2,
    this.invalidOnObstruction3,
    this.invalidOnObstruction4,
    this.invalidOnObstruction5,
    this.invalidOnObstruction6,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    String? s(String key) => json[key]?.toString();
    return Member(
      id: int.tryParse(s('Id') ?? '') ?? 0,
      dataTime: s('DataTime'),
      number: s('Number'),
      name: s('Name'),
      nameKana: s('NameKana'),
      kana: s('Kana'),
      kana2: s('Kana2'),
      kana3: s('Kana3'),
      blanch: s('Blanch'),
      rank: s('Rank'),
      wBirthday: s('WBirthday'),
      gBirthday: s('GBirthday'),
      sex: s('Sex'),
      age: s('Age'),
      height: s('Height'),
      weight: s('Weight'),
      blood: s('Blood'),
      birthplace: s('Birthplace'),
      photo: s('Photo'),
      winPointRate: s('WinPointRate'),
      winRate12: s('WinRate12'),
      firstPlaceCount: s('1stPlaceCount'),
      secondPlaceCount: s('2ndPlaceCount'),
      numberOfRace: s('NumberOfRace'),
      numberOfFinals: s('NumberOfFinals'),
      numberOfWins: s('NumberOfWins'),
      startTiming: s('StartTiming'),
      rankPast1: s('RankPast1'),
      rankPast2: s('RankPast2'),
      rankPast3: s('RankPast3'),
      pastAbilityScore: s('PastAbilityScore'),
      lastAbilityScore: s('LastAbilityScore'),
      dataYear: s('DataYear'),
      dataSeason: s('DataSeason'),
      startDate: s('StartDate'),
      endDate: s('EndDate'),
      generation: s('Genetation'),

      numberOfEntries1: s('NumberOfEntries#1'),
      numberOfEntries2: s('NumberOfEntries#2'),
      numberOfEntries3: s('NumberOfEntries#3'),
      numberOfEntries4: s('NumberOfEntries#4'),
      numberOfEntries5: s('NumberOfEntries#5'),
      numberOfEntries6: s('NumberOfEntries#6'),

      winRate121: s('WinRate12#1'),
      winRate122: s('WinRate12#2'),
      winRate123: s('WinRate12#3'),
      winRate124: s('WinRate12#4'),
      winRate125: s('WinRate12#5'),
      winRate126: s('WinRate12#6'),

      startTime1: s('StartTime#1'),
      startTime2: s('StartTime#2'),
      startTime3: s('StartTime#3'),
      startTime4: s('StartTime#4'),
      startTime5: s('StartTime#5'),
      startTime6: s('StartTime#6'),

      startOrder1: s('StartOrder#1'),
      startOrder2: s('StartOrder#2'),
      startOrder3: s('StartOrder#3'),
      startOrder4: s('StartOrder#4'),
      startOrder5: s('StartOrder#5'),
      startOrder6: s('StartOrder#6'),

      firstPlace1: s('1stPlace#1'),
      firstPlace2: s('1stPlace#2'),
      firstPlace3: s('1stPlace#3'),
      firstPlace4: s('1stPlace#4'),
      firstPlace5: s('1stPlace#5'),
      firstPlace6: s('1stPlace#6'),

      secondPlace1: s('2ndPlace#1'),
      secondPlace2: s('2ndPlace#2'),
      secondPlace3: s('2ndPlace#3'),
      secondPlace4: s('2ndPlace#4'),
      secondPlace5: s('2ndPlace#5'),
      secondPlace6: s('2ndPlace#6'),

      thirdPlace1: s('3rdPlace#1'),
      thirdPlace2: s('3rdPlace#2'),
      thirdPlace3: s('3rdPlace#3'),
      thirdPlace4: s('3rdPlace#4'),
      thirdPlace5: s('3rdPlace#5'),
      thirdPlace6: s('3rdPlace#6'),

      fourthPlace1: s('4thPlace#1'),
      fourthPlace2: s('4thPlace#2'),
      fourthPlace3: s('4thPlace#3'),
      fourthPlace4: s('4thPlace#4'),
      fourthPlace5: s('4thPlace#5'),
      fourthPlace6: s('4thPlace#6'),

      fifthPlace1: s('5thPlace#1'),
      fifthPlace2: s('5thPlace#2'),
      fifthPlace3: s('5thPlace#3'),
      fifthPlace4: s('5thPlace#4'),
      fifthPlace5: s('5thPlace#5'),
      fifthPlace6: s('5thPlace#6'),

      sixthPlace1: s('6thPlace#1'),
      sixthPlace2: s('6thPlace#2'),
      sixthPlace3: s('6thPlace#3'),
      sixthPlace4: s('6thPlace#4'),
      sixthPlace5: s('6thPlace#5'),
      sixthPlace6: s('6thPlace#6'),

      falseStart1: s('FalseStart#1'),
      falseStart2: s('FalseStart#2'),
      falseStart3: s('FalseStart#3'),
      falseStart4: s('FalseStart#4'),
      falseStart5: s('FalseStart#5'),
      falseStart6: s('FalseStart#6'),

      lateStartNoResponsibility1: s('LateStartNoResponsibility#1'),
      lateStartNoResponsibility2: s('LateStartNoResponsibility#2'),
      lateStartNoResponsibility3: s('LateStartNoResponsibility#3'),
      lateStartNoResponsibility4: s('LateStartNoResponsibility#4'),
      lateStartNoResponsibility5: s('LateStartNoResponsibility#5'),
      lateStartNoResponsibility6: s('LateStartNoResponsibility#6'),

      lateStartOnResponsibility1: s('LateStartOnResponsibility#1'),
      lateStartOnResponsibility2: s('LateStartOnResponsibility#2'),
      lateStartOnResponsibility3: s('LateStartOnResponsibility#3'),
      lateStartOnResponsibility4: s('LateStartOnResponsibility#4'),
      lateStartOnResponsibility5: s('LateStartOnResponsibility#5'),
      lateStartOnResponsibility6: s('LateStartOnResponsibility#6'),

      withdrawNoResponsibility1: s('WithdrawNoResponsibility#1'),
      withdrawNoResponsibility2: s('WithdrawNoResponsibility#2'),
      withdrawNoResponsibility3: s('WithdrawNoResponsibility#3'),
      withdrawNoResponsibility4: s('WithdrawNoResponsibility#4'),
      withdrawNoResponsibility5: s('WithdrawNoResponsibility#5'),
      withdrawNoResponsibility6: s('WithdrawNoResponsibility#6'),

      withdrawOnResponsibility1: s('WithdrawOnResponsibility#1'),
      withdrawOnResponsibility2: s('WithdrawOnResponsibility#2'),
      withdrawOnResponsibility3: s('WithdrawOnResponsibility#3'),
      withdrawOnResponsibility4: s('WithdrawOnResponsibility#4'),
      withdrawOnResponsibility5: s('WithdrawOnResponsibility#5'),
      withdrawOnResponsibility6: s('WithdrawOnResponsibility#6'),

      invalidNoResponsibility1: s('InvalidNoResponsibility#1'),
      invalidNoResponsibility2: s('InvalidNoResponsibility#2'),
      invalidNoResponsibility3: s('InvalidNoResponsibility#3'),
      invalidNoResponsibility4: s('InvalidNoResponsibility#4'),
      invalidNoResponsibility5: s('InvalidNoResponsibility#5'),
      invalidNoResponsibility6: s('InvalidNoResponsibility#6'),

      invalidOnResponsibility1: s('InvalidOnResponsibility#1'),
      invalidOnResponsibility2: s('InvalidOnResponsibility#2'),
      invalidOnResponsibility3: s('InvalidOnResponsibility#3'),
      invalidOnResponsibility4: s('InvalidOnResponsibility#4'),
      invalidOnResponsibility5: s('InvalidOnResponsibility#5'),
      invalidOnResponsibility6: s('InvalidOnResponsibility#6'),

      invalidOnObstruction1: s('InvalidOnObstruction#1'),
      invalidOnObstruction2: s('InvalidOnObstruction#2'),
      invalidOnObstruction3: s('InvalidOnObstruction#3'),
      invalidOnObstruction4: s('InvalidOnObstruction#4'),
      invalidOnObstruction5: s('InvalidOnObstruction#5'),
      invalidOnObstruction6: s('InvalidOnObstruction#6'),
    );
  }
}
