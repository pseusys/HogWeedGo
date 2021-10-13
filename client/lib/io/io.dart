import 'package:client/io/io_stub.dart'
  if (dart.library.io) 'mobile.dart'
  if (dart.library.html) 'web.dart';


// TODO: replace with actual multiplatform code if there are any issues on android.
abstract class IO {
  Future<String?> saveFileFromUri(String name, String uri);

  /// factory constructor to return the correct implementation.
  factory IO() => getIO();
}