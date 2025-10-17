/// DataTime（例: 20251, 20252）を「yyyyMM-yyyyMM」形式に変換
String formatDataTimePeriod(String dataTime) {
  if (dataTime.length < 5) return dataTime;

  final int year = int.tryParse(dataTime.substring(0, 4)) ?? 0;
  final int term = int.tryParse(dataTime.substring(4)) ?? 0;

  if (year == 0 || term == 0) return dataTime;

  if (term == 1) {
    final Year1 = year - 1;
    // return '${Year1}/05-${Year1}/10';
    return '${Year1}/10';
  } else if (term == 2) {
    //final Year2 = year - 1;
    // return '${Year2}/11-${year}/04';
    return '${year}/04';
  } else {
    return dataTime;
  }
}

