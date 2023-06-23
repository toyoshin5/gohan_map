import 'dart:convert';
import 'dart:io';

import 'package:flutter/Cupertino.dart';
import 'package:flutter/Material.dart';
import 'package:gohan_map/collections/shop.dart';
import 'package:gohan_map/collections/timeline.dart';
import 'package:gohan_map/component/post_food_widget.dart';
import 'package:gohan_map/utils/isar_utils.dart';

import 'package:gohan_map/colors/app_colors.dart';
import 'package:gohan_map/component/app_modal.dart';

/// 飲食店でのごはん投稿画面
class PlacePostPage extends StatefulWidget {
  const PlacePostPage({Key? key}) : super(key: key);

  @override
  State<PlacePostPage> createState() => _PlacePostPageState();
}

class _PlacePostPageState extends State<PlacePostPage> {
  String shopName = '';
  String address = '';
  int shopId = 1;
  double rating = 3;
  File? image;
  bool isUmai = false;
  DateTime date = DateTime.now();
  String comment = '';
  @override
  Widget build(BuildContext context) {
    return AppModal(
      initialChildSize: 0.6,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 追加の投稿
            PostFoodWidget(
              onImageChanged: (image) {
                setState(() {
                  this.image = image;
                });
              },
              onUmaiChanged: (isUmai) {
                setState(() {
                  this.isUmai = isUmai;
                });
              },
              onDateChanged: (date) {
                setState(() {
                  this.date = date;
                });
              },
              onCommentChanged: (comment) {
                setState(() {
                  this.comment = comment;
                });
              },
            ),
            //決定ボタン
            Container(
              width: double.infinity,
              height: 50,
              margin: const EdgeInsets.symmetric(vertical: 16),
              child: TextButton(
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  foregroundColor: AppColors.blackTextColor,
                  backgroundColor: AppColors.backgroundWhiteColor,
                ),
                onPressed: () {
                  onTapComfirm(context);
                },
                child: const Text('決定'),
              ),
            ),
            const SizedBox(height: 300),
          ],
        ),
      ),
    );
  }

  //決定ボタンを押した時の処理
  void onTapComfirm(BuildContext context) {
    //バリデーション
    if (image == null && comment.isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text('投稿の入力がありません'),
            content: const Text('最初の投稿なしで登録しますか？'),
            actions: [
              CupertinoDialogAction(
                child: const Text('キャンセル'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              CupertinoDialogAction(
                child: const Text('店だけ登録'),
                onPressed: () async {
                  _addToDB(false);
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
      return;
    }
    _addToDB(true);
  }

  //DBに店を登録(initalPostFlg: 最初の投稿をするかどうか)
  Future<void> _addToDB(bool initialPostFlg) async {
    final base64Img = await _fileToBase64(image);
    final timeline = Timeline()
      ..image = base64Img
      ..comment = comment
      ..umai = isUmai
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now()
      ..shopId = shopId
      ..date = date ?? DateTime.now();
    await IsarUtils.createTimeline(timeline);
    if (context.mounted) {
      Navigator.pop(context);
      return;
    }

    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  //画像をbase64に変換する関数
  Future<String> _fileToBase64(File? file) async {
    if (file == null) {
      return '';
    }
    List<int> fileBytes = await file.readAsBytes();
    String base64Image = base64Encode(fileBytes);
    return base64Image;
  }
}
