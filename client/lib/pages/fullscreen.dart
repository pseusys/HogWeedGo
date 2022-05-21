import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cross_file_image/cross_file_image.dart';

import 'package:client/download_image/none.dart'
  if (dart.library.io) 'package:client/download_image/mobile.dart'
  if (dart.library.html) 'package:client/download_image/web.dart';
import 'package:image_picker/image_picker.dart';


class FullscreenPage extends StatefulWidget {
  const FullscreenPage(this.link, this.webLink, {Key? key}) : super(key: key);

  final String link;
  final bool webLink;
  static const route = "/fullscreen:";

  @override
  State<FullscreenPage> createState() => _FullscreenPageState();
}

class _FullscreenPageState extends State<FullscreenPage> {
  late final String _link;
  late final bool _webLink;

  var _imageSize = Offset.zero;
  var _position = Offset.zero;
  var _screen = Offset.zero;

  var _scale = 0.0;
  var _trans = Offset.zero;

  @override
  void initState() {
    super.initState();
    _link = widget.link;
    _webLink = widget.webLink;
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
      case 0: _trans = Offset.zero;
      break;
      case 1: _trans = Offset(-_position.dx, -_position.dy);
      break;
      case 2: _trans = Offset(-_position.dx, -_position.dy) * 3;
      break;
    }
    _pan(Offset.zero);
  }

  void _pan(Offset transform) {
    final mul = pow(2, _scale).toDouble();
    var newT = _trans + transform * mul;

    final offset = -(_screen - _imageSize) / 2;
    final image = _imageSize * mul;
    final inset = (_screen - _imageSize * mul) / 2;

    final left = newT.dx > offset.dx;
    final right = newT.dx < inset.dx;
    final top = newT.dy > offset.dy;
    final bottom = newT.dy < inset.dy;

    if ((left ^ right) && (_screen.dx < image.dx)) {
      if (left) { newT = Offset(offset.dx, newT.dy); }
      if (right) { newT = Offset(inset.dx, newT.dy); }
    } else if (left || right) { newT = Offset(_imageSize.dx * (1 - mul) / 2, newT.dy); }

    if ((top ^ bottom) && (_screen.dy < image.dy)) {
      if (top) { newT = Offset(newT.dx, offset.dy); }
      if (bottom) { newT = Offset(newT.dx, inset.dy); }
    } else if (top || bottom) { newT = Offset(_imageSize.dy * (1 - mul) / 2, offset.dy); }

    _trans = newT;
  }

  double? _bytes(ImageChunkEvent p) => p.expectedTotalBytes != null ? p.cumulativeBytesLoaded / p.expectedTotalBytes! : null;

  @override
  Widget build(BuildContext context) {
    _screen = Offset(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height);
    return FocusWatcher(
      child: Scaffold(
        resizeToAvoidBottomInset: false,

        backgroundColor: Colors.black87,

        appBar: AppBar(
          title: Text(_link),
          backgroundColor: const Color.fromARGB(50, 1, 1, 1),
          shadowColor: Colors.transparent,
        ),
        extendBodyBehindAppBar: true,

        body: Center(
          child: Image(
            image: (_webLink ? CachedNetworkImageProvider(_link) : XFileImage(XFile(_link))) as ImageProvider,
            fit: BoxFit.cover,
            errorBuilder: (_, Object exception, StackTrace? stackTrace) => const Icon(Icons.error),
            loadingBuilder: (_, Widget child, ImageChunkEvent? p) {
              if (p == null) {
                return Transform(
                  transform: Matrix4.identity()..translate(_trans.dx, _trans.dy)..scale(pow(2, _scale)),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onPanUpdate: (DragUpdateDetails details) => setState(() => _pan(details.delta)),
                      onDoubleTapDown: (TapDownDetails details) => _position = details.localPosition,
                      onDoubleTap: () => setState(() => _zoom()),
                      child: child,
                    ),
                  ),
                );
              } else { return CircularProgressIndicator(value: _bytes(p)); }
            },
          )

            ..image.resolve(const ImageConfiguration()).addListener(
              ImageStreamListener((ImageInfo image, bool synchronousCall) {
                final imageSize = Offset(image.image.width.toDouble(), image.image.height.toDouble());
                final verticalCentered = _screen.dx / _screen.dy < imageSize.dx / imageSize.dy;
                _imageSize = imageSize * (verticalCentered ? _screen.dx / imageSize.dx : _screen.dy / imageSize.dy);
              }),
            ),
        ),

        floatingActionButton: _webLink ? FloatingActionButton(
          onPressed: () => saveFileFromUri(widget.link, _link),
          tooltip: "Save",
          child: const Icon(Icons.save),
        ) : null,
      ),
    );
  }
}
