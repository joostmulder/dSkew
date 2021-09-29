class Validator {
  bool isURL(String url) {
    var urlPattern =
        r"(https?|http)://([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?";
    var match = new RegExp(urlPattern, caseSensitive: false).firstMatch(url);
    bool result = RegExp(urlPattern, caseSensitive: false).hasMatch(url);
    return result;
  }
}
