import 'package:flutter/material.dart';

class FullscreenGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final ValueChanged<List<String>>? onImagesChanged;

  const FullscreenGallery(
      {super.key,
      required this.images,
      this.initialIndex = 0,
      this.onImagesChanged});

  @override
  State<FullscreenGallery> createState() => _FullscreenGalleryState();
}

class _FullscreenGalleryState extends State<FullscreenGallery> {
  late PageController _controller;
  late List<String> _images;

  @override
  void initState() {
    super.initState();
    _images = List.from(widget.images);
    _controller = PageController(initialPage: widget.initialIndex);
  }

  void _removeCurrent() {
    final idx = _controller.page?.round() ?? 0;
    if (idx >= 0 && idx < _images.length) {
      setState(() => _images.removeAt(idx));
      widget.onImagesChanged?.call(List.from(_images));
      if (_images.isEmpty) Navigator.of(context).pop(_images);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gallery'),
        actions: [
          IconButton(icon: Icon(Icons.delete), onPressed: _removeCurrent)
        ],
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: _images.length,
        itemBuilder: (context, i) =>
            Center(child: Image.network(_images[i], fit: BoxFit.contain)),
      ),
    );
  }
}
