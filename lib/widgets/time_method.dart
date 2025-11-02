String monthFun(String mon) {
  String? temp;
  if (mon == "1") {
    temp = "Jaunary";
  } else if (mon == "2") {
    temp = "Feb";
  } else if (mon == "3") {
    temp = "March";
  } else if (mon == "4") {
    temp = "Aprail";
  } else if (mon == "5") {
    temp = "May";
  } else if (mon == "6") {
    temp = "June";
  } else if (mon == "7") {
    temp = "July";
  } else if (mon == "8") {
    temp = "Aug";
  } else if (mon == "9") {
    temp = "Sep";
  } else if (mon == "10") {
    temp = "Oct";
  } else if (mon == "11") {
    temp = "Nov";
  } else if (mon == "12") {
    temp = "Dec";
  }
  return temp!;
}

String ampmFun(String hour) {
  String? ampm;
  if (int.parse(hour) >= 0 && int.parse(hour) <= 11) {
    ampm = "am";
  } else if (int.parse(hour) >= 12 && int.parse(hour) <= 23) {
    ampm = "pm";
  }
  return ampm!;
}

String timeFun(String hour) {
  String? tim;
  if (int.parse(hour) == 0) {
    tim = "12";
  } else if (int.parse(hour) >= 1 && int.parse(hour) <= 12) {
    tim = hour;
  } else if (int.parse(hour) >= 13 && int.parse(hour) <= 23) {
    tim = (int.parse(hour) - 12).toString();
  }

  return tim!;
}
