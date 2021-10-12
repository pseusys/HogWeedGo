import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class FullscreenPage extends StatefulWidget {
  const FullscreenPage(this.link, {Key? key}) : super(key: key);

  final String link;
  static const route = "/fullscreen:";

  @override
  State<FullscreenPage> createState() => _FullscreenPageState();
}

class _FullscreenPageState extends State<FullscreenPage> {
  var _imageScaler = 0.0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                    onDoubleTap: () => setState(() => _imageScaler = (_imageScaler + 1) % 3),
                    child: CachedNetworkImage(
                        imageUrl: widget.link,
                        fit: BoxFit.contain,
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                        progressIndicatorBuilder: (context, url, downloadProgress) {
                          return CircularProgressIndicator(value: downloadProgress.progress);
                        },
                        imageBuilder: (context, imageProvider) {
                          return Container(decoration: BoxDecoration(
                              image: DecorationImage(image: imageProvider, scale: 1 / pow(2, _imageScaler))
                          ));
                        }
                    )
                )
            )
        )
    );
  }
}
