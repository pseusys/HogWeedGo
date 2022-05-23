import 'package:flutter/material.dart';

import 'package:cross_file_image/cross_file_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:client/misc/const.dart';
import 'package:client/pages/fullscreen.dart';
import 'package:client/blocs/report/report_bloc.dart';
import 'package:client/blocs/report/report_event.dart';
import 'package:client/models/report.dart';
import 'package:client/hogweedgo.dart';


extension _RequestSupport on Photo {
  String get thumbnailURL => "${HogWeedGo.server}${thumbnail.toString()}";
  String get photoURL => "${HogWeedGo.server}${photo.toString()}";
}

class PhotoGallery extends StatefulWidget {
  final bool _editable;
  final List<XFile> _photos = [];
  final List<Photo> _pictures;

  PhotoGallery._(this._editable, this._pictures, {Key? key}): super(key: key);
  PhotoGallery.editable({Key? key}): this._(true, [], key: key);
  PhotoGallery.constant(List<Photo> photos, {Key? key}): this._(false, photos, key: key);

  @override
  State<PhotoGallery> createState() => _PhotoGalleryState();
}

class _PhotoGalleryState extends State<PhotoGallery> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _getImage(BuildContext context, ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source, maxWidth: 1800, maxHeight: 1800);
    if (image != null) {
      widget._photos.add(image);
      context.read<ReportBloc>().add(ReportPhotosChanged(widget._photos));
    }
  }

  Widget _buildChild(BuildContext context, int index, bool isEditable, bool isFinal) {
    return SizedBox(
      width: OFFSET * 4,
      height: OFFSET * 4,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          SizedBox(
            width: OFFSET * 3,
            height: OFFSET * 3,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () async {
                  if (isFinal) {
                    await _getImage(context, ImageSource.camera);
                    setState(() {});
                  } else {
                    Navigator.of(context, rootNavigator: true).pushNamed(FullscreenPage.route, arguments: [isEditable ? widget._photos[index].path : widget._pictures[index].photoURL, isEditable]);
                  }
                },
                child: Card(
                  semanticContainer: true,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: isFinal ? const Icon(Icons.camera_alt) : Image(image: (isEditable ? XFileImage(widget._photos[index]) : CachedNetworkImageProvider(widget._pictures[index].thumbnailURL)) as ImageProvider),
                  ),
                ),
              ),
            ),
          ),
          if (isEditable) Align(
            alignment: Alignment.topRight,
            child: FloatingActionButton(
              mini: true,
              onPressed: () {
                setState(() async {
                  if (isFinal) {
                    await _getImage(context, ImageSource.gallery);
                    setState(() {});
                  } else {
                    widget._photos.removeAt(index);
                    context.read<ReportBloc>().add(ReportPhotosChanged(widget._photos));
                  }
                });
              },
              child: Icon(isFinal ? Icons.add : Icons.close),
              backgroundColor: isFinal ? REGULAR : DANGER,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: OFFSET * 4,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget._editable ? widget._photos.length + 1 : widget._pictures.length,
        itemBuilder: (BuildContext context, int i) => _buildChild(context, i, widget._editable, widget._editable && i == widget._photos.length),
      ),
    );
  }
}
