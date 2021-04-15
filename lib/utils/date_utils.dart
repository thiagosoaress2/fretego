import 'package:date_format/date_format.dart';
import 'package:intl/intl.dart';

//needs to add date_format: ^1.0.8 to pubspec.yaml

class DateServices {

  String convertStringFromDate(DateTime strDate) {
    final newDate = formatDate(strDate, [dd, '/', mm, '/', yyyy]);
    return newDate;
  }

  DateTime convertDateFromString(String strDate){
    DateTime todayDate = DateTime.parse(strDate.split('/').reversed.join());
    return todayDate;
  }

  String returnThisMonthAndYear() {
    var monthYear = DateTime.now();
    final formatted = formatDate(monthYear, [mm, '/', yyyy]);
    return formatted;
  }

  String _returnMeXDaysInFutureFromThisDate(String strDate, int daysToAdd){
    DateTime theDate = convertDateFromString(strDate);
    var thirtyDaysFromNow = theDate.add(new Duration(days: daysToAdd));
    String formattedDate = convertStringFromDate(thirtyDaysFromNow);
    return formattedDate;
  }

  bool doesThisDateIsBigger (String date1, String date2){
    var date1Formatted = convertDateFromString(date1);
    var date2Formatted = convertDateFromString(date2);

    final difference = date2Formatted.difference(date1Formatted).inDays;

    if (difference>=0){
      return false; //data 1 é maior
    } else {
      return true; //data2 é maior
    }
  }

  bool doesThisDateIsBiggerThanToday (String date){

    var dateFormatted = convertDateFromString(date);
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
    return convertStringFromDate(today);
  }

  String giveMeTheTimeNow(){
    var now = DateTime.now();
    String formattedTime = DateFormat.Hm().format(now);
    return formattedTime;
  }

  String giveMeJustTheTimeOfThisDateTime(DateTime date){

    int hour = date.hour;
    int minute = date.minute;
    if(minute==0){
      minute=00;
    } else if(minute==1){
      minute=01;
    } else if(minute==2){
      minute=02;
    }
    else if(minute==3){
      minute=03;
    } else if(minute==4){
      minute=04;
    } else if(minute==5){
      minute=05;
    } else if(minute==6){
      minute=06;
    } else if(minute==7){
      minute=07;
    } else if(minute==8){
      minute=08;
    } else if(minute==9){
      minute=09;
    }

    return hour.toString()+':'+minute.toString();

  }

  DateTime addDaysToDate(DateTime originalDate, int daysToAdd){
    //use este de baixo para trabalhar com horas e minutos se precisar
    //DateTime newDate = DateTime(originalDate.year, originalDate.month, originalDate.day, originalDate.hour, originalDate.minute);
    DateTime newDate = DateTime(originalDate.year, originalDate.month, originalDate.day+daysToAdd);
    return newDate;
  }

  DateTime subDaysFromDate(DateTime originalDate, int daysToSub){
    //use este de baixo para trabalhar com horas e minutos se precisar
    //DateTime newDate = DateTime(originalDate.year, originalDate.month, originalDate.day, originalDate.hour, originalDate.minute);
    DateTime newDate = DateTime(originalDate.year, originalDate.month, originalDate.day-daysToSub);
    return newDate;
  }

  DateTime addMonthsToDate(DateTime originalDate, int monthToAdd){
    //use este de baixo para trabalhar com horas e minutos se precisar
    //DateTime newDate = DateTime(originalDate.year, originalDate.month, originalDate.day, originalDate.hour, originalDate.minute);
    DateTime newDate = DateTime(originalDate.year, originalDate.month+monthToAdd, originalDate.day);
    return newDate;
  }

  DateTime subMonthsFromDate(DateTime originalDate, int monthsToSub){
    //use este de baixo para trabalhar com horas e minutos se precisar
    //DateTime newDate = DateTime(originalDate.year, originalDate.month, originalDate.day, originalDate.hour, originalDate.minute);
    DateTime newDate = DateTime(originalDate.year, originalDate.month-monthsToSub, originalDate.day);
    return newDate;
  }

  DateTime addYeasToDate(DateTime originalDate, int yearsToAdd){
    //use este de baixo para trabalhar com horas e minutos se precisar
    //DateTime newDate = DateTime(originalDate.year, originalDate.month, originalDate.day, originalDate.hour, originalDate.minute);
    DateTime newDate = DateTime(originalDate.year+yearsToAdd, originalDate.month, originalDate.day);
    return newDate;
  }

  DateTime subYearsFromDate(DateTime originalDate, int yearsToSub){
    //use este de baixo para trabalhar com horas e minutos se precisar
    //DateTime newDate = DateTime(originalDate.year, originalDate.month, originalDate.day, originalDate.hour, originalDate.minute);
    DateTime newDate = DateTime(originalDate.year-yearsToSub, originalDate.month, originalDate.day);
    return newDate;
  }

  DateTime addHourToDate(DateTime originalDate, int hoursToAdd){
    //use este de baixo para trabalhar com horas e minutos se precisar
    //DateTime newDate = DateTime(originalDate.year, originalDate.month, originalDate.day, originalDate.hour, originalDate.minute);
    DateTime newDate = DateTime(originalDate.year, originalDate.month, originalDate.day, originalDate.hour+hoursToAdd, originalDate.minute);
    return newDate;
  }

  DateTime subHoursFromDate(DateTime originalDate, int hoursToSub){
    //use este de baixo para trabalhar com horas e minutos se precisar
    //DateTime newDate = DateTime(originalDate.year, originalDate.month, originalDate.day, originalDate.hour, originalDate.minute);
    DateTime newDate = DateTime(originalDate.year, originalDate.month, originalDate.day, originalDate.hour-hoursToSub, originalDate.minute);
    return newDate;
  }

  DateTime addMinutesToDate(DateTime originalDate, int minutesToAdd){
    //use este de baixo para trabalhar com horas e minutos se precisar
    //DateTime newDate = DateTime(originalDate.year, originalDate.month, originalDate.day, originalDate.hour, originalDate.minute);
    DateTime newDate = DateTime(originalDate.year, originalDate.month, originalDate.day, originalDate.hour, originalDate.minute+minutesToAdd);
    return newDate;
  }

  DateTime subMinutesFromDate(DateTime originalDate, int minutesToSub){
    //use este de baixo para trabalhar com horas e minutos se precisar
    //DateTime newDate = DateTime(originalDate.year, originalDate.month, originalDate.day, originalDate.hour, originalDate.minute);
    DateTime newDate = DateTime(originalDate.year, originalDate.month, originalDate.day, originalDate.hour, originalDate.minute-minutesToSub);
    return newDate;
  }

  DateTime addMinutesAndHoursFromStringToAdate(DateTime originalDate, String time){

    //time needs to be in hh:mm format
    DateTime newDate;
    var ar = time.split(":"); //cria um array
    int hourNew = int.parse(ar.first); //hora
    int minuteNew = int.parse(ar.last); //minuto
    newDate = DateTime(originalDate.year, originalDate.month, originalDate.day, hourNew, minuteNew);
    return newDate;

  }

  int compareTwoDatesInMinutes(DateTime date1, DateTime date2){

    //String result;
    final int difference = date2.difference(date1).inMinutes;
    return difference;

    /*
    OBS
    se der resultado negativo é porque a date1 é maior (ou seja, já passou da hora. Ex: date1=10/11/2020 06:50  date2=10/11/2020 14:20 deu -440)

     */

    /*
    if(difference==0){
      result = 'equal';
    } else if(difference.isNegative){
      result = 'date2bigger';
    } else {
      result = 'date1bigger';
    }

     */

  }

  String iHaveStringWithTimeAndHeveToMinusItFromADateMinusMinutes(String date, String time, int minutesToSub){

    DateTime dateInDateTime = DateServices().convertDateFromString(date);
    DateTime timeInDateTime = DateServices().addMinutesAndHoursFromStringToAdate(dateInDateTime, time);
    DateTime newDateWithNewTime = DateServices().subMinutesFromDate(timeInDateTime, minutesToSub);
    String timeFinal = DateServices().giveMeJustTheTimeOfThisDateTime(newDateWithNewTime);
    return timeFinal;

  }

  String iHaveStringWithTimeAndHaveToMinusItFromADateMinusHours(String date, String time, int hourToSub){

    DateTime dateInDateTime = DateServices().convertDateFromString(date);
    DateTime timeInDateTime = DateServices().addMinutesAndHoursFromStringToAdate(dateInDateTime, time);
    DateTime newDateWithNewTime = DateServices().subHoursFromDate(timeInDateTime, hourToSub);
    String timeFinal = DateServices().giveMeJustTheTimeOfThisDateTime(newDateWithNewTime);
    return timeFinal;

  }

}
