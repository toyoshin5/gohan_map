import 'dart:convert';

import 'package:flutter/Cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gohan_map/collections/shop.dart';
import 'package:gohan_map/collections/timeline.dart';
import 'package:gohan_map/component/app_modal.dart';
import 'package:gohan_map/view/place_post_page.dart';
import 'package:gohan_map/view/place_update_page.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:pull_down_button/pull_down_button.dart';

import '../component/app_rating_bar.dart';
import '../utils/isar_utils.dart';

///飲食店の詳細画面
class PlaceDetailPage extends StatefulWidget {
  final Id id;
  const PlaceDetailPage({Key? key, required this.id}) : super(key: key);

  @override
  State<PlaceDetailPage> createState() => _PlaceDetailPageState();
}

class _PlaceDetailPageState extends State<PlaceDetailPage> {
  Shop? selectedShop;
  List<Timeline>? shopTimeline;
  @override
  void initState() {
    super.initState();
    IsarUtils.getShopById(widget.id).then((shop) {
      setState(() {
        selectedShop = shop;
      });
      if (shop == null) {
        return;
      }
      IsarUtils.getTimelinesByShopId(shop.id).then((timeline) {
        setState(() {
          shopTimeline = timeline;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppModal(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(
                children: [
                  Text(
                    selectedShop?.shopName ?? '',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 2),
                  IconButton(
                      onPressed: () {
                        showModalBottomSheet(
                          //モーダルを表示する関数
                          barrierColor:
                              Colors.black.withOpacity(0), //背景をどれぐらい暗くするか
                          backgroundColor: Colors.transparent,
                          context: context,
                          isScrollControlled: true, //スクロールで閉じたりするか
                          builder: (context) {
                            return PlaceUpdatePage(
                              shop: selectedShop!,
                            ); //ご飯投稿
                          },
                        ).then((value) {
                          IsarUtils.getShopById(widget.id).then((shop) {
                            setState(() {
                              selectedShop = shop;
                            });
                          });
                        });
                      },
                      icon: const Icon(Icons.mode,
                          size: 20, color: Color.fromARGB(255, 103, 103, 103))),
                ],
              ),
              SizedBox(
                  height: 30,
                  width: 30,
                  child: IconButton(
                    padding: const EdgeInsets.fromLTRB(0, 0, 12, 12), //44px確保
                    icon: const Icon(
                      Icons.cancel_outlined,
                      size: 32,
                    ),
                    onPressed: () {
                      Navigator.pop(context); //前の画面に戻る
                    },
                  ),
                ),
            ]),
            Row(
              children: [
                const Icon(
                  Icons.place,
                  color: Colors.blue,
                ),
                const Padding(padding: EdgeInsets.only(right: 5)),
                Text(
                  selectedShop?.shopAddress ?? '',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            SizedBox(
              height: 30,
              width: 100,
              child: IgnorePointer(
                ignoring: true,
                child: AppRatingBar(
                  initialRating: selectedShop?.shopStar ?? 0,
                  onRatingUpdate: (rating) {},
                  itemSize: 20,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                style: TextButton.styleFrom(
                    fixedSize: Size(140, 40),
                    backgroundColor: Color(0xFF25399D),
                    foregroundColor: Colors.white),
                onPressed: () {
                  if (selectedShop == null) {
                    return;
                  }
                  showModalBottomSheet(
                    //モーダルを表示する関数
                    barrierColor: Colors.black.withOpacity(0), //背景をどれぐらい暗くするか
                    backgroundColor: Colors.transparent,
                    context: context,
                    isScrollControlled: true, //スクロールで閉じたりするか
                    builder: (context) {
                      return PlacePostPage(
                        shop: selectedShop!,
                      ); //ご飯投稿
                    },
                  ).then((value) {
                    IsarUtils.getTimelinesByShopId(selectedShop!.id)
                        .then((timeline) {
                      setState(() {
                        shopTimeline = timeline;
                      });
                    });
                  });
                },
                child: const Text('投稿',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            for (var timeline in (shopTimeline ?? []).reversed)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // アイコンとテキストの間のスペースを設定
                                  Text(
                                    DateFormat('yyyy/MM/dd')
                                        .format(timeline.date),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  PullDownButton(
                                    itemBuilder: (context) => [
                                      PullDownMenuItem(
                                        onTap: () {
                                          if (selectedShop == null) {
                                            return;
                                          }
                                          showModalBottomSheet(
                                            //モーダルを表示する関数
                                            barrierColor: Colors.black
                                                .withOpacity(0), //背景をどれぐらい暗くするか
                                            backgroundColor: Colors.transparent,
                                            context: context,
                                            isScrollControlled:
                                                true, //スクロールで閉じたりするか
                                            builder: (context) {
                                              return PlacePostPage(
                                                shop: selectedShop!,
                                                timeline: timeline,
                                              ); //ご飯投稿
                                            },
                                          ).then((value) {
                                            IsarUtils.getTimelinesByShopId(
                                                    selectedShop!.id)
                                                .then((timeline) {
                                              setState(() {
                                                shopTimeline = timeline;
                                              });
                                            });
                                          });
                                        },
                                        title: '編集',
                                        icon: CupertinoIcons.pencil,
                                      ),
                                      PullDownMenuItem(
                                        onTap: () {
                                          IsarUtils.deleteTimeline(timeline.id);
                                          setState(() {
                                            shopTimeline!.remove(timeline);
                                          });
                                        },
                                        title: '削除',
                                        isDestructive: true,
                                        icon: CupertinoIcons.delete,
                                      ),
                                    ],
                                    animationBuilder: null,
                                    position: PullDownMenuPosition.automatic,
                                    buttonBuilder: (_, showMenu) =>
                                        CupertinoButton(
                                      onPressed: showMenu,
                                      padding: EdgeInsets.zero,
                                      pressedOpacity: 1,
                                      child: const Icon(
                                        CupertinoIcons.ellipsis,
                                        color: Colors.black,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (timeline.image != null &&
                                  timeline.image!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        12.0), // 角丸の半径を適切に設定してください
                                    child: Image.memory(
                                      base64Decode(timeline.image!),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              if (timeline.umai)
                                Container(
                                  //角丸四角形
                                  height: 32,
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.pinkAccent,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),

                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: Colors.pinkAccent,
                                        size: 22,
                                      ),
                                      SizedBox(width: 2),
                                      Text(
                                        'うまい！',
                                        style: TextStyle(
                                          color: Colors.pinkAccent,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                child: Text(
                                  timeline.comment,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
