import 'dart:io';
import 'dart:math';

import 'package:date_time_picker/date_time_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:exif/exif.dart';
import 'package:flutter/Cupertino.dart';
import 'package:flutter/Material.dart';
import 'package:flutter/services.dart';
import 'package:gohan_map/colors/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class PostFoodWidget extends StatefulWidget {
  const PostFoodWidget({
    Key? key,
    this.initialImage,
    required this.onImageChanged,
    this.initialIsUmai,
    required this.onUmaiChanged,
    this.initialDate,
    required this.onDateChanged,
    this.initialComment,
    required this.onCommentChanged,
    this.onCommentFocusChanged,
  }) : super(key: key);
  final File? initialImage;
  final Function(File?) onImageChanged;

  final bool? initialIsUmai;
  final Function(bool) onUmaiChanged;

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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhiteColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ImgSection(
              initialImage: widget.initialImage,
              onChanged: widget.onImageChanged,
              onDateTimeChanged: (DateTime dateTime) {
                dateController.value =
                    dateController.value.copyWith(text: dateTime.toString());
                widget.onDateChanged(dateTime);
              }),
          UmaiButton(
            initialIsUmai: widget.initialIsUmai,
            onChanged: widget.onUmaiChanged,
          ),
          _DateSection(
            controller: dateController,
            onChanged: widget.onDateChanged,
          ),
          _CommentSection(
            initialComment: widget.initialComment,
            onChanged: widget.onCommentChanged,
            onFocusChanged: widget.onCommentFocusChanged,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    dateController.dispose();
    super.dispose();
  }
}

class _ImgSection extends StatefulWidget {
  final File? initialImage;
  final Function(File?) onChanged;
  final Function(DateTime) onDateTimeChanged;
  const _ImgSection({
    this.initialImage,
    required this.onChanged,
    required this.onDateTimeChanged,
  });

  @override
  State<_ImgSection> createState() => _ImgSectionState();
}

//画像選択欄
class _ImgSectionState extends State<_ImgSection> {
  File? image;
  bool isSelecting = false; //選択/ロード中か

  @override
  void initState() {
    super.initState();
    this.image = widget.initialImage;
  }

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      padding: EdgeInsets.zero,
      borderType: BorderType.RRect,
      radius: const Radius.circular(10),
      dashPattern: const [5, 5],
      color: (image == null) ? Colors.grey : Colors.transparent,
      child: SizedBox(
        width: double.infinity,
        child: Stack(
          children: [
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  //iOS風のアクションシート
                  showCupertinoModalPopup(
                    context: context,
                    builder: (BuildContext context) {
                      return CupertinoActionSheet(
                        title: const Text('写真を追加'),
                        actions: [
                          CupertinoActionSheetAction(
                            onPressed: () async {
                              setState(() {
                                isSelecting = true;
                              });
                              if (mounted) {
                                Navigator.pop(context);
                              }
                              await takePhoto();
                            },
                            child: const Text('カメラで撮影'),
                          ),
                          CupertinoActionSheetAction(
                            onPressed: () async {
                              setState(() {
                                isSelecting = true;
                              });
                              if (mounted) {
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
                },
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: AppColors.backgroundWhiteColor,
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.upload_file,
                        color: Colors.grey.shade800,
                        size: 40,
                      ),
                      Text(
                        (isSelecting) ? '写真を読み込み中..' : '写真を追加する',
                        style: const TextStyle(color: AppColors.blackTextColor),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (image != null)
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
            if (image != null)
              Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                  onPressed: () {
                    widget.onChanged(null);
                    setState(() {
                      image = null;
                      isSelecting = false;
                    });
                  },
                  icon: const Icon(
                    Icons.cancel,
                    color: AppColors.backgroundWhiteColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future takePhoto() async {
    try {
      final image = await ImagePicker()
          .pickImage(source: ImageSource.camera, maxWidth: 1200);
      // 画像がnullの場合戻る
      if (image == null) return;

      final imageTemp = File(image.path);
      widget.onChanged(imageTemp);
      setState(() {
        this.image = imageTemp;
      });
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
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
        widget.onDateTimeChanged(imageDateTime);
      }

      widget.onChanged(imageTemp);
      setState(() {
        this.image = imageTemp;
      });
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }
}

//うまいボタン
class UmaiButton extends StatefulWidget {
  const UmaiButton({
    super.key,
    this.initialIsUmai,
    required this.onChanged,
  });

  final bool? initialIsUmai;
  final Function(bool) onChanged;

  @override
  State<UmaiButton> createState() => _UmaiButtonState();
}

class _UmaiButtonState extends State<UmaiButton> {
  bool isOn = false;

  @override
  void initState() {
    super.initState();
    this.isOn = widget.initialIsUmai ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: (isOn) ? 0 : 2,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: (isOn) ? Colors.pinkAccent : Colors.grey.shade400, //色
            ),
            borderRadius: BorderRadius.circular(100),
          ),
          padding: EdgeInsets.zero,
        ),
        onPressed: () {
          setState(() {
            isOn = !isOn;
            widget.onChanged(isOn);
          });
        },
        child: Container(
          //角丸四角形
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.star,
                color: (isOn) ? Colors.pinkAccent : Colors.grey.shade400,
                size: 22,
              ),
              const SizedBox(width: 2),
              Text(
                'うまい！',
                style: TextStyle(
                  color: (isOn) ? Colors.pinkAccent : Colors.grey.shade400,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
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
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final Function(DateTime) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      //角丸四角形
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 16),
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
    );
  }
}

//コメント入力欄
class _CommentSection extends StatelessWidget {
  const _CommentSection({
    super.key,
    this.initialComment,
    required this.onChanged,
    this.onFocusChanged,
  });
  final String? initialComment;
  final Function(String) onChanged;
  final Function(bool)? onFocusChanged;

  @override
  Widget build(BuildContext context) {
    return Focus(
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
              color: AppColors.textFieldColor,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: AppColors.textFieldColor,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
