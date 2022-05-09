extension StringSupport on String {
  String urize() {
    if (endsWith('/')) {
      return substring(0, length - 1);
    } else {
      return this;
    }
  }
}
