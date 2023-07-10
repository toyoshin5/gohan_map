import 'dart:io';
import 'dart:math';

import 'package:date_time_picker/date_time_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/Cupertino.dart';
import 'package:flutter/Material.dart';
import 'package:flutter/services.dart';
import 'package:gohan_map/colors/app_colors.dart';
import 'package:image_picker/image_picker.dart';

//白い枠で囲まれた、投稿内容を入力する部分
class PostFoodWidget extends StatelessWidget {
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
  }) : super(key: key);
  final File? initialImage;
  final Function(File?) onImageChanged;

  final bool? initialIsUmai;
  final Function(bool) onUmaiChanged;

  final DateTime? initialDate;
  final Function(DateTime) onDateChanged;

  final String? initialComment;
  final Function(String) onCommentChanged;
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
            initialImage: this.initialImage,
            onChanged: onImageChanged,
          ),
          UmaiButton(
            initialIsUmai: this.initialIsUmai,
            onChanged: onUmaiChanged,
          ),
          _DateSection(
            initialDate: this.initialDate,
            onChanged: onDateChanged,
          ),
          _CommentSection(
            initialComment: this.initialComment,
            onChanged: onCommentChanged,
          ),
        ],
      ),
    );
  }
}

class _ImgSection extends StatefulWidget {
  final File? initialImage;
  final Function(File?) onChanged;
  const _ImgSection({
    super.key,
    this.initialImage,
    required this.onChanged,
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
                            onPressed: () {
                              setState(() {
                                isSelecting = true;
                              });
                              takePhoto();
                              Navigator.pop(context);
                            },
                            child: const Text('カメラで撮影'),
                          ),
                          CupertinoActionSheetAction(
                            onPressed: () {
                              setState(() {
                                isSelecting = true;
                              });
                              pickImage();
                              Navigator.pop(context);
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
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
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
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
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
    this.initialDate,
    required this.onChanged,
  });

  final DateTime? initialDate;
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
        initialValue: initialDate != null
            ? initialDate.toString()
            : DateTime.now().toString(),
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
  });
  final String? initialComment;
  final Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
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
    );
  }
}
