import 'dart:math' as math;

String getRandomId(int length) {
  const String chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final rng = math.Random();

  return String.fromCharCodes(List.generate(
      length, (index) => chars.codeUnitAt(rng.nextInt(chars.length))));
}
