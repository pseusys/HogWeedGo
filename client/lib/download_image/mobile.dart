import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:gallery_saver/gallery_saver.dart';


void saveFileFromUri(String name, String uri) async {
  final image = await DefaultCacheManager().getSingleFile(uri);
  await GallerySaver.saveImage(image.path);
}
