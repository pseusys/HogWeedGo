import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';


Future<String?> saveFileFromUri(String name, String uri) async {
  final image = await DefaultCacheManager().getSingleFile(uri);
  await ImageGallerySaver.saveImage(await image.readAsBytes(), quality: 100, name: name);
}
