// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:client/io/io.dart';


class WebIO implements IO {
  @override
  Future<String?> saveFileFromUri(String name, String uri) async {
    final image = await(await DefaultCacheManager().getSingleFile(uri)).readAsBytes();
    AnchorElement(href: Uri.dataFromBytes(image).toString())..setAttribute("download", name)..click();
  }
}

IO getIO() => WebIO();
