import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';

import 'package:client/io/io.dart';


class WebIO implements IO {
  @override
  Future<String?> saveFileFromUri(String name, String uri) async {
    final image = await DefaultCacheManager().getSingleFile(uri);
    final String path = (await getApplicationDocumentsDirectory()).path;
    await image.copy('$path/$name');
  }
}

IO getIO() => WebIO();
