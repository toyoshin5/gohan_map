import 'dart:io';

import 'package:date_time_picker/date_time_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:exif/exif.dart';
import 'package:flutter/Cupertino.dart';
import 'package:flutter/Material.dart';
import 'package:flutter/services.dart';
import 'package:gohan_map/colors/app_colors.dart';
import 'package:gohan_map/component/app_rating_bar.dart';
import 'package:gohan_map/utils/logger.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class PostFoodWidget extends StatefulWidget {
  const PostFoodWidget({
    Key? key,
    required this.images,
    required this.onImageAdded,
    required this.onImageDeleted,
    this.initialStar,
    required this.onStarChanged,
    this.initialDate,
    required this.onDateChanged,
    this.initialComment,
    required this.onCommentChanged,
    this.onCommentFocusChanged,
  }) : super(key: key);
  final List<File> images;
  final Function(File) onImageAdded;
  final Function(int) onImageDeleted;

  final double? initialStar;
  final Function(double) onStarChanged;

  final DateTime? initialDate;
  final Function(DateTime) onDateChanged;

  final String? initialComment;
  final Function(String) onCommentChanged;

  final Function(bool)? onCommentFocusChanged;

  @override
  State<PostFoodWidget> createState() => _PostFoodWidgetState();
}

//白い枠で囲まれた、投稿内容を入力する部分
class _PostFoodWidgetState extends State<PostFoodWidget> {
  TextEditingController dateController = TextEditingController();

  @override
  void initState() {
    dateController.text = widget.initialDate != null
        ? widget.initialDate.toString()
        : DateTime.now().toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StarSection(
          initialStar: widget.initialStar,
          onChanged: widget.onStarChanged,
        ),
        const SizedBox(height: 16),
        _ImgSection(
            images: widget.images,
            onAdded: widget.onImageAdded,
            onDeleted: widget.onImageDeleted,
            onDateTimeChanged: (DateTime dateTime) {
              dateController.value =
                  dateController.value.copyWith(text: dateTime.toString());
              widget.onDateChanged(dateTime);
            }),
        const SizedBox(height: 16),
        _DateSection(
          controller: dateController,
          onChanged: widget.onDateChanged,
        ),
        const SizedBox(height: 16),
        _CommentSection(
          initialComment: widget.initialComment,
          onChanged: widget.onCommentChanged,
          onFocusChanged: widget.onCommentFocusChanged,
        ),
      ],
    );
  }

  @override
  void dispose() {
    dateController.dispose();
    super.dispose();
  }
}

class _StarSection extends StatelessWidget {
  const _StarSection({
    this.initialStar,
    required this.onChanged,
  });

  final double? initialStar;
  final Function(double) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: _SectionTitle(icon: Icons.star_rounded, title: "評価"),
        ),
        AppRatingBar(
            initialRating: initialStar ?? 4.0, onRatingUpdate: onChanged),
      ],
    );
  }
}

class _ImgSection extends StatelessWidget {
  final List<File> images;
  final Function(File) onAdded;
  final Function(int) onDeleted;
  final Function(DateTime) onDateTimeChanged;
  const _ImgSection({
    required this.images,
    required this.onAdded,
    required this.onDeleted,
    required this.onDateTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: _SectionTitle(icon: Icons.camera_alt_rounded, title: "写真"),
        ),
        DottedBorder(
          padding: EdgeInsets.zero,
          borderType: BorderType.RRect,
          radius: const Radius.circular(10),
          dashPattern: const [5, 5],
          color: AppColors.blackTextColor,
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                _UploadButton(
                    onPressed: (images.length >= 4)
                        ? null
                        : () {
                  //iOS風のアクションシート
                  showCupertinoModalPopup(
                    context: context,
                    builder: (BuildContext context) {
                      return CupertinoActionSheet(
                        title: const Text('写真を追加'),
                        actions: [
                          CupertinoActionSheetAction(
                            onPressed: () async {
                                        if (context.mounted) {
                                Navigator.pop(context);
                              }
                              await takePhoto();
                            },
                            child: const Text('カメラで撮影'),
                          ),
                          CupertinoActionSheetAction(
                            onPressed: () async {
                                        if (context.mounted) {
                                Navigator.pop(context);
                              }
                              await pickImage();
                            },
                            child: const Text('アルバムから選択'),
                          ),
                        ],
                        cancelButton: CupertinoActionSheetAction(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('キャンセル'),
                        ),
                      );
                    },
                  );
                          }),
                for (int i = 0; i < images.length; i++)
                  _SelectedImgWidget(
                    image: images[i],
                    onDeletePressed: () {
                      onDeleted(i);
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future takePhoto() async {
    try {
      final image = await ImagePicker()
          .pickImage(source: ImageSource.camera, maxWidth: 1200);
      // 画像がnullの場合戻る
      if (image == null) return;

      final imageTemp = File(image.path);
      onAdded(imageTemp);
    } on PlatformException catch (e) {
      logger.e('Failed to pick image: $e');
    }
  }

  // 画像をギャラリーから選ぶ関数
  Future pickImage() async {
    try {
      final image = await ImagePicker()
          .pickImage(source: ImageSource.gallery, maxWidth: 1200);

      // 画像がnullの場合戻る
      if (image == null) return;

      final imageTemp = File(image.path);
      // 撮影日を読み取る
      final tags = await readExifFromBytes(await imageTemp.readAsBytes());
      if (tags.containsKey("Image DateTime")) {
        // フォーマットが全デバイスで正しいのかは検討
        var imageDateTime = DateFormat("yyyy:MM:dd HH:mm:ss")
            .parse(tags["Image DateTime"].toString());
        onDateTimeChanged(imageDateTime);
      }
      onAdded(imageTemp);
    } on PlatformException catch (e) {
      logger.e('Failed to pick image: $e');
    }
  }
}

class _SelectedImgWidget extends StatelessWidget {
  const _SelectedImgWidget({
    super.key,
    required this.image,
    required this.onDeletePressed,
  });

  final File? image;
  final VoidCallback onDeletePressed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        //画像を表示
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: IntrinsicHeight(
            child: Image.file(
              image!,
              fit: BoxFit.contain,
            ),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: IconButton(
            onPressed: onDeletePressed,
            icon: const Icon(
              Icons.cancel,
              color: AppColors.whiteColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _UploadButton extends StatelessWidget {
  const _UploadButton({
    required this.onPressed,
  });
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: AppColors.whiteColor,
        ),
        child: SizedBox(
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.upload_rounded,
                color: Colors.grey.shade800,
                size: 30,
              ),
              const Text(
                '写真を追加する',
                style: TextStyle(color: AppColors.blackTextColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//訪問日入力欄
class _DateSection extends StatelessWidget {
  const _DateSection({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final Function(DateTime) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: _SectionTitle(icon: Icons.edit_calendar_rounded, title: "訪問日"),
        ),
        Container(
          //角丸四角形
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          decoration: BoxDecoration(
            color: AppColors.searchBarColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DateTimePicker(
            type: DateTimePickerType.date,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            dateMask: 'yyyy/MM/dd',
            //icon: Icon(Icons.watch_later_outlined),
            dateLabelText: '訪問日',
            controller: controller,
            use24HourFormat: true,
            onChanged: (value) {
              onChanged(DateTime.parse(value));
            },
          ),
        ),
      ],
    );
  }
}

//コメント入力欄
class _CommentSection extends StatelessWidget {
  const _CommentSection({
    this.initialComment,
    required this.onChanged,
    this.onFocusChanged,
  });
  final String? initialComment;
  final Function(String) onChanged;
  final Function(bool)? onFocusChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: _SectionTitle(icon: Icons.comment_bank_rounded, title: "コメント"),
        ),
        Focus(
          onFocusChange: onFocusChanged,
          child: TextFormField(
            keyboardType: TextInputType.multiline,
            maxLines: null,
            minLines: 3,
            initialValue: initialComment,
            decoration: InputDecoration(
              hintText: 'コメント',
              filled: true,
              fillColor: AppColors.searchBarColor,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: AppColors.whiteColor,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: AppColors.whiteColor,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
  });
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 26,
        ),
        const SizedBox(
          width: 4,
        ),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }
}
