import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:client/io/none.dart'
  if (dart.library.io) 'package:client/io/mobile.dart'
  if (dart.library.html) 'package:client/io/web.dart';


class FullscreenPage extends StatefulWidget {
  const FullscreenPage(this.link, {Key? key}) : super(key: key);

  final String link;
  static const domain = "";
  static const route = "/fullscreen:";

  @override
  State<FullscreenPage> createState() => _FullscreenPageState();
}

class _FullscreenPageState extends State<FullscreenPage> {
  late final String _link;

  var _position = Offset.zero;
  var _scale = 0.0;
  var _trans = Offset.zero;

  @override
  void initState() {
    super.initState();
    _link = FullscreenPage.domain + widget.link;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    CachedNetworkImage.evictFromCache(_link);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _zoom() {
    _scale = (_scale + 1) % 3;
    switch (_scale.round()) {
      case 0: { _trans = Offset.zero; }
      break;
      case 1: { _trans = Offset(-_position.dx, -_position.dy); }
      break;
      case 2: { _trans = Offset(-_position.dx, -_position.dy) * 3; }
      break;
    }
  }

  double? _bytes(ImageChunkEvent p) => p.expectedTotalBytes != null ? p.cumulativeBytesLoaded / p.expectedTotalBytes! : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black87,

        body: Center(
            child: Image(
                image: CachedNetworkImageProvider(_link),
                fit: BoxFit.cover,
                errorBuilder: (_, Object exception, StackTrace? stackTrace) => const Icon(Icons.error),
                loadingBuilder: (_, Widget child, ImageChunkEvent? p) {
                  if (p == null) {
                    return Transform(
                        transform: Matrix4.identity()..translate(_trans.dx, _trans.dy)..scale(pow(2, _scale)),
                        child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                                onDoubleTapDown: (TapDownDetails details) => _position = details.localPosition,
                                onDoubleTap: () => setState(() => _zoom()),
                                child: child
                            )
                        )
                    );
                  } else { return CircularProgressIndicator(value: _bytes(p)); }
                }
            )
        ),

        floatingActionButton: FloatingActionButton(
            onPressed: () => saveFileFromUri(widget.link, _link),
            tooltip: "Save",
            child: const Icon(Icons.save)
        )
    );
  }
}
