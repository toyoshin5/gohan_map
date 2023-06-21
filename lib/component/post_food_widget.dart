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
class PostFoodWidget extends StatefulWidget {
  const PostFoodWidget({
    Key? key,
    required this.onImageChanged,
    required this.onDateChanged,
    required this.onCommentChanged,
  }) : super(key: key);
  final Function(File) onImageChanged;
  final Function(DateTime) onDateChanged;
  final Function(String) onCommentChanged;
  @override
  State<PostFoodWidget> createState() => _PostFoodWidgetState();
}

class _PostFoodWidgetState extends State<PostFoodWidget> {
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
        children: [
          _ImgSection(
            onChanged: widget.onImageChanged,
          ),
          _DateSection(
            onChanged: widget.onDateChanged,
          ),
          _CommentSection(
            onChanged: widget.onCommentChanged,
          ),
        ],
      ),
    );
  }
}

class _ImgSection extends StatefulWidget {
  final Function(File) onChanged;
  const _ImgSection({
    super.key,
    required this.onChanged,
  });
  
  @override
  State<_ImgSection> createState() => _ImgSectionState();
}

class _ImgSectionState extends State<_ImgSection> {
  File? image;
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
                              takePhoto();
                              Navigator.pop(context);
                            },
                            child: const Text('カメラで撮影'),
                          ),
                          CupertinoActionSheetAction(
                            onPressed: () {
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
                  aspectRatio: 16/9,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.upload_file,
                        color: Colors.grey.shade800,
                        size: 40,
                      ),
                      const Text(
                        '写真を追加する',
                        style: TextStyle(color: AppColors.blackTextColor),
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
                    setState(() {
                      image = null;
                    });
                  },
                  icon: const Icon(Icons.cancel,color: AppColors.backgroundWhiteColor,),
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
      setState(() => this.image = imageTemp);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  // 画像をギャラリーから選ぶ関数
  Future pickImage() async {
    //HEIFはダメ?
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      // 画像がnullの場合戻る
      if (image == null) return;

      final imageTemp = File(image.path);
      widget.onChanged(imageTemp);
      setState(() => this.image = imageTemp);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }
}

class _DateSection extends StatefulWidget {
  const _DateSection({
    super.key,
    required this.onChanged,
  });

  final Function(DateTime) onChanged;

  @override
  State<_DateSection> createState() => _DateSectionState();
}

class _DateSectionState extends State<_DateSection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      //角丸四角形
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.searchBarColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DateTimePicker(
        type: DateTimePickerType.date,
        //controller: _controller1,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        //icon: Icon(Icons.watch_later_outlined),
        dateLabelText: '訪問日',
        //use24HourFormat: false,
        //locale: Locale('pt', 'BR'),
        selectableDayPredicate: (date) {
          if (date.weekday == 6 || date.weekday == 7) {
            return false;
          }
          return true;
        },
        onChanged: (value) {
          widget.onChanged(DateTime.parse(value));
        },
      ),
    );
  }
}

class _CommentSection extends StatefulWidget {
  const _CommentSection({
    super.key,
    required this.onChanged,
  });
  final Function(String) onChanged;

  @override
  State<_CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<_CommentSection> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: TextInputType.multiline,
      maxLines: null,
      minLines: 3,
      decoration: InputDecoration(
        hintText: 'コメント',
        filled: true,
        fillColor: AppColors.searchBarColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      onChanged: widget.onChanged,
    );
  }
}
