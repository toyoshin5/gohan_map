import 'dart:io';
import 'package:flutter/Material.dart';
import 'package:gohan_map/collections/timeline.dart';
import 'package:gohan_map/colors/app_colors.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:path/path.dart' as p;

// 投稿の写真を表示する部分。最大4枚
class AppPhotosView extends StatelessWidget {
  const AppPhotosView({
    super.key,
    required this.timeline,
    required this.imageData,
  });

  final Timeline timeline;
  final String imageData;

  @override
  Widget build(BuildContext context) {
    int imageCount = timeline.images.length;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.greyDarkColor),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          child: Row(
            children: [
              Flexible(
                child: Column(
                  children: [
                    Flexible(
                      child: GestureDetector(
                        onTap: () => openImage(context, 0),
                        child: SizedBox(
                          height: double.infinity,
                          width: double.infinity,
                          child: Hero(
                            tag: timeline.images[0],
                            child: Image.file(
                              File(p.join(imageData, timeline.images[0])),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (imageCount >= 4) ...[
                      const SizedBox(
                        height: 2,
                      ),
                      Flexible(
                        child: GestureDetector(
                          onTap: () => openImage(context, 3),
                          child: SizedBox(
                            height: double.infinity,
                            width: double.infinity,
                            child: Hero(
                              tag: timeline.images[3],
                              child: Image.file(
                                File(p.join(imageData, timeline.images[3])),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (imageCount >= 2) ...[
                const SizedBox(width: 2),
                Flexible(
                  child: Column(
                    children: [
                      Flexible(
                        child: GestureDetector(
                          onTap: () => openImage(context, 1),
                          child: SizedBox(
                            height: double.infinity,
                            width: double.infinity,
                            child: Hero(
                              tag: timeline.images[1],
                              child: Image.file(
                                File(p.join(imageData, timeline.images[1])),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (imageCount >= 3) ...[
                        const SizedBox(
                          height: 2,
                        ),
                        Flexible(
                          child: GestureDetector(
                            onTap: () => openImage(context, 2),
                            child: SizedBox(
                              height: double.infinity,
                              width: double.infinity,
                              child: Hero(
                                tag: timeline.images[2],
                                child: Image.file(
                                  File(p.join(imageData, timeline.images[2])),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void openImage(BuildContext context, final int index) {
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            _GalleryPhotoViewWrapper(
          imageData: imageData,
          imagePaths: timeline.images,
          backgroundDecoration: const BoxDecoration(
            color: Colors.black,
          ),
          initialIndex: index,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}

class _GalleryPhotoViewWrapper extends StatefulWidget {
  _GalleryPhotoViewWrapper({
    super.key,
    this.loadingBuilder,
    this.backgroundDecoration,
    this.minScale,
    this.maxScale,
    this.initialIndex = 0,
    required this.imagePaths,
    required this.imageData,
    this.scrollDirection = Axis.horizontal,
  }) : pageController = PageController(initialPage: initialIndex);

  final LoadingBuilder? loadingBuilder;
  final BoxDecoration? backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;
  final int initialIndex;
  final PageController pageController;
  final List<String> imagePaths; // 画像のパス
  final String imageData; // 画像の保存先のルートパス
  final Axis scrollDirection;

  @override
  State<StatefulWidget> createState() {
    return _GalleryPhotoViewWrapperState();
  }
}

class _GalleryPhotoViewWrapperState extends State<_GalleryPhotoViewWrapper> {
  late int currentIndex = widget.initialIndex;

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: widget.backgroundDecoration,
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: <Widget>[
            PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              builder: _buildItem,
              itemCount: widget.imagePaths.length,
              loadingBuilder: widget.loadingBuilder,
              backgroundDecoration: widget.backgroundDecoration,
              pageController: widget.pageController,
              onPageChanged: onPageChanged,
              scrollDirection: widget.scrollDirection,
            ),
            Container(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "${currentIndex + 1}/${widget.imagePaths.length}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17.0,
                  decoration: null,
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 0,
              child: IconButton(
                onPressed: (() => Navigator.of(context).pop()),
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PhotoViewGalleryPageOptions _buildItem(BuildContext context, int index) {
    final String item = widget.imagePaths[index];
    return PhotoViewGalleryPageOptions(
      imageProvider: FileImage(File(p.join(widget.imageData, item))),
      initialScale: PhotoViewComputedScale.contained,
      heroAttributes: PhotoViewHeroAttributes(tag: item),
    );
  }
}
