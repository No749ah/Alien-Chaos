import 'dart:math' as math;

String reducedFormatNumber(num number) {
  if (number < 1000) return number.toString();

  const suffixes = [
    '',
    'k',
    'm',
    'b',
    't',
    'q',
    'Q',
    's',
    'S',
    'o',
    'n',
    'd',
    'U',
    'D',
    'T',
    'Qt',
    'Qn',
    'Sx',
    'Sp',
    'Oc',
    'Nn',
    'C',
  ];

  int i = (number == 0) ? 0 : (math.log(number) / math.log(1000)).floor();
  num reduced = (number / math.pow(1000, i)).ceilToDouble() / 10;
  String suffix = suffixes[i];

  return '${reduced.toStringAsFixed(1)}$suffix';
}

String slightReducedFormatNumber(num number) {
  if (number < 1000) return number.toString();

  const suffixes = [
    '',
    'k',
    'm',
    'b',
    't',
    'q',
    'Q',
    's',
    'S',
    'o',
    'n',
    'd',
    'U',
    'D',
    'T',
    'Qt',
    'Qn',
    'Sx',
    'Sp',
    'Oc',
    'Nn',
    'C',
  ];

  int i = (number == 0) ? 0 : (math.log(number) / math.log(1000)).floor();
  num reduced = number / math.pow(1000, i);
  String suffix = suffixes[i];

  return '${reduced.toStringAsFixed(3)}$suffix';
}