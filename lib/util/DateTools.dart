import 'package:intl/intl.dart';

//full fate format
String fullDateFormatted({required DateTime date}) {
  var formatter = new DateFormat('yyyy-MM-dd');
  String formatDate = formatter.format(date);
  return formatDate;
}

//day and text_month format
String dayMonthFormatted({required DateTime date}) {
  var formatter = new DateFormat().add_MMMd();
  String formatDate = formatter.format(date);
  return formatDate;
}

// text_month and year format
String monthYearFormatted({required DateTime date}) {
  var formatter = new DateFormat().add_yMMM();
  String formatDate = formatter.format(date);
  return formatDate;
}

String intDate({required DateTime date}) {
  var formatter = new DateFormat().add_ms();
  String formatDate = formatter.format(date);
  return formatDate;
}

String currencyFormat({required double data}) {
  var formatter = NumberFormat(',###');
  String formatNumber = formatter.format(data);
  return formatNumber;
}

String fullDateAndTime({required DateTime date}) {
  var formatter = new DateFormat('yyyy-MM-dd HH:MM:ss');
  String formatDate = formatter.format(date);
  return formatDate;
}

int strDateToMilliseconds(String date) {
  return DateTime.parse(date).millisecondsSinceEpoch;
}
