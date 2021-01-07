import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_wallet/util/ActiveBudgetService.dart';

//full fate format
String fullDateFormatted({@required DateTime date}) {
  var formatter = new DateFormat('yyyy-MM-dd');
  String formatDate = formatter.format(date);
  return formatDate;
}

//day and text_month format
String dayMonthFormatted({@required DateTime date}) {
  var formatter = new DateFormat().add_MMMd();
  String formatDate = formatter.format(date);
  return formatDate;
}

// text_month and year format
String monthYearFormatted({@required DateTime date}) {
  var formatter = new DateFormat().add_yMMM();
  String formatDate = formatter.format(date);
  return formatDate;
}

// allow date on current month
bool allowCurrentMonthDay(DateTime date) {
  //print('date => $date');
  var activeBudgetService = new ActiveBudgetService();
  String curDateStr = activeBudgetService.curDateStr;
  //print('curDateStrTwo => $curDateStr');
  if (date.month == DateTime.parse(curDateStr).month) {
    return true;
  } else {
    return false;
  }
}

String intDate({@required DateTime date}){
  var formatter = new DateFormat().add_ms();
  String formatDate = formatter.format(date);
  return formatDate;
}

String currencyFormat({@required double data}){
  var formatter = NumberFormat(',###');
  String formatNumber = formatter.format(data);
  return formatNumber;
}

String fullDateAndTime({@required DateTime date}) {
  var formatter = new DateFormat('yyyy-MM-dd HH:MM:ss');
  String formatDate = formatter.format(date);
  return formatDate;
}