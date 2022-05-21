import 'package:flutter/material.dart';

import 'package:client/misc/const.dart';


class PhotoLoader extends StatefulWidget {
  const PhotoLoader(this._editable, {Key? key}): super(key: key);

  final bool _editable;

  @override
  State<PhotoLoader> createState() => _PhotoLoaderState();
}

class _PhotoLoaderState extends State<PhotoLoader> {
  final List<String> _photos = [];

  Widget _buildChild(int index, bool isEditable, bool isFinal) {
    return SizedBox(
      width: OFFSET * 4,
      height: OFFSET * 4,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          SizedBox(
            width: OFFSET * 3,
            height: OFFSET * 3,
            child: Card(
                semanticContainer: true,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: isFinal ? const Icon(Icons.camera_alt) : Image.network(_photos[index]),
                )
            ),
          ),
          if (isEditable) Align(
            alignment: Alignment.topRight,
            child: FloatingActionButton(
              mini: true,
              onPressed: () => setState(() => isFinal ? _photos.add('https://i.imgur.com/koOENqs.jpeg') : _photos.removeAt(index)),
              child: Icon(isFinal ? Icons.add : Icons.close),
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
        itemCount: widget._editable ? _photos.length + 1 : _photos.length,
        itemBuilder: (BuildContext context, int i) => _buildChild(i, widget._editable, i == _photos.length),
      ),
    );
  }
}
