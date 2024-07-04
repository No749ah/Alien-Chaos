class timeHelper {
  static bool isPreviousDay(DateTime givenDate) {
    DateTime now = DateTime.now();
    return givenDate.year < now.year ||
        (givenDate.year == now.year && givenDate.month < now.month) ||
        (givenDate.year == now.year && givenDate.month == now.month && givenDate.day < now.day);
  }
}