/// Doc link:
/// https://dart.dev/guides/libraries/create-library-packages#conditionally-importing-and-exporting-library-files
Future<String?> saveFileFromUri(String name, String uri) {
  throw UnsupportedError("Cannot create IO not for mobile or web platform");
}
