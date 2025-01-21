class Util {
  static bool checkString(String s) {
    return !s.contains(RegExp(r'[\.\\\/\,\(\)\[\]\{\}\<\>\|]'));
  }

  static (String name, String comment, String email) userIdToComponents(
    String userId,
  ) {
    var result = ("", "", "");
    var cstart = userId.indexOf("(");

    if (cstart == -1) {
      cstart = userId.indexOf("<");
    } else {
      final cend = userId.indexOf(")");
      result =
          (result.$1, userId.substring(cstart + 1, cend).trim(), result.$3);
    }
    final estart = userId.indexOf("<");
    result = (
      userId.substring(0, cstart).trim(),
      result.$2,
      userId.substring(estart + 1, userId.length - 2)
    );

    return result;
  }
}
