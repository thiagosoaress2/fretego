import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';

//needs to add date_format: ^1.0.8 to pubspec.yaml

class DateServices {

  String convertToStringFromDate(DateTime strDate) {
    final newDate = formatDate(strDate, [dd, '/', mm, '/', yyyy]);
    return newDate;
  }

  DateTime convertToDateFromString(String strDate){
    DateTime todayDate = DateTime.parse(strDate.split('/').reversed.join());
    return todayDate;
  }


  String returnThisMonthAndYear() {
    var monthYear = DateTime.now();
    final formatted = formatDate(monthYear, [mm, '/', yyyy]);
    return formatted;
  }

  String _returnMeXDaysInFutureFromThisDate(String strDate, int daysToAdd){
    DateTime theDate = convertToDateFromString(strDate);
    var thirtyDaysFromNow = theDate.add(new Duration(days: daysToAdd));
    String formattedDate = convertToStringFromDate(thirtyDaysFromNow);
    return formattedDate;
  }

  bool doesThisDateIsBigger (String date1, String date2){
    var date1Formatted = convertToDateFromString(date1);
    var date2Formatted = convertToDateFromString(date2);

    final difference = date2Formatted.difference(date1Formatted).inDays;

    if (difference>=0){
      return false; //data 1 é maior
    } else {
      return true; //data2 é maior
    }
  }

  bool doesThisDateIsBiggerThanToday (String date){

    var dateFormatted = convertToDateFromString(date);
    var today = DateTime.now();

    final difference = today.difference(dateFormatted).inDays;
    print (date);
    print("Difference é "+difference.toString());

    if(difference>=0){
      return false;  //data informada é maior do que hoje
    } else {
      return true; //data informada é menor do que hoje
    }


  }

  String giveMeTheYear(DateTime date){

    return date.year.toString();
  }

  String giveMeTheMonth(DateTime date){

    return date.month.toString();
  }

  String giveMeTheDateToday(){
    var today = DateTime.now();
    return convertToStringFromDate(today);
  }

  TimeOfDay convertStringToTimeOfDay(String s){
    TimeOfDay _startTime = TimeOfDay(hour:int.parse(s.split(":")[0]),minute: int.parse(s.split(":")[1]));
    return _startTime;
  }

}
