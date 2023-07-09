import 'dart:io';

import 'package:flutter/Cupertino.dart';
import 'package:flutter/Material.dart';
import 'package:gohan_map/collections/shop.dart';
import 'package:gohan_map/collections/timeline.dart';
import 'package:gohan_map/component/post_food_widget.dart';
import 'package:gohan_map/utils/common.dart';
import 'package:gohan_map/utils/isar_utils.dart';

import 'package:gohan_map/colors/app_colors.dart';
import 'package:gohan_map/component/app_modal.dart';

// 飲食店でのごはん投稿・編集画面
class PlacePostPage extends StatefulWidget {
  final Shop shop;
  final Timeline? timeline; // 編集ページの際に外部から初期データを渡す

  const PlacePostPage({Key? key, required this.shop, this.timeline})
      : super(key: key);

  @override
  State<PlacePostPage> createState() => _PlacePostPageState();
}

class _PlacePostPageState extends State<PlacePostPage> {
  File? image;
  bool isUmai = false;
  DateTime date = DateTime.now();
  String comment = '';

  @override
  void initState() {
    super.initState();
    if (widget.timeline != null) {
      image = base64ImageToFile(widget.timeline?.image);
      isUmai = widget.timeline?.umai ?? false;
      date = widget.timeline?.date ?? DateTime.now();
      comment = widget.timeline?.comment ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppModal(
      initialChildSize: 0.6,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 30, right: 20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //飲食店名
                    Text(widget.shop.shopName,style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: Text(
                          (widget.timeline != null)?"投稿編集":"新規投稿",
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        )),
                        const SizedBox(width: 24),
                        SizedBox(
                          height: 30,
                          width: 30,
                          child: IconButton(
                            icon: const Icon(
                              Icons.cancel_outlined,
                              size: 32,
                            ),
                            onPressed: () {
                              Navigator.pop(context); //前の画面に戻る
                            },
                          ),
                        ),
                      ],
                    ),
                    
                  ]),
            ),
            // 追加の投稿
            PostFoodWidget(
              initialImage: image,
              onImageChanged: (image) {
                setState(() {
                  this.image = image;
                });
              },
              initialIsUmai: isUmai,
              onUmaiChanged: (isUmai) {
                setState(() {
                  this.isUmai = isUmai;
                });
              },
              initialDate: date,
              onDateChanged: (date) {
                setState(() {
                  this.date = date;
                });
              },
              initialComment: comment,
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
              margin: const EdgeInsets.only(top: 30, bottom: 8),
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
                child: const Text(
                  '決定',
                  style: TextStyle(
                      color: AppColors.blueTextColor,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            // キャンセルボタン
            Container(
              width: double.infinity,
              height: 50,
              margin: const EdgeInsets.only(bottom: 50),
              child: TextButton(
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  foregroundColor: AppColors.blackTextColor,
                  backgroundColor: AppColors.backgroundWhiteColor,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'キャンセル',
                  style: TextStyle(
                      color: AppColors.redTextColor,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
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
            actions: [
              CupertinoDialogAction(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
      return;
    }

    if (widget.timeline != null) {
      _updateTimeline();
    } else {
      _addToDB();
    }
  }

  //DBに店を新規登録
  Future<void> _addToDB() async {
    final base64Img = await fileToBase64(image);
    final timeline = Timeline()
      ..image = base64Img
      ..comment = comment
      ..umai = isUmai
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now()
      ..shopId = widget.shop.id
      ..date = date ?? DateTime.now();
    await IsarUtils.createTimeline(timeline);

    if (context.mounted) {
      Navigator.pop(context);
      return;
    }
  }

  //DBに店を新規登録
  Future<void> _updateTimeline() async {
    final base64Img = await fileToBase64(image);
    final timeline = Timeline()
      ..id = widget.timeline!.id
      ..image = base64Img
      ..comment = comment
      ..umai = isUmai
      ..createdAt = widget.timeline!.createdAt
      ..updatedAt = DateTime.now()
      ..shopId = widget.shop.id
      ..date = date;
    await IsarUtils.createTimeline(timeline);

    if (context.mounted) {
      Navigator.pop(context);
      return;
    }
  }
}
