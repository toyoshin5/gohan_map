import 'dart:io';

import 'package:flutter/Cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gohan_map/collections/shop.dart';
import 'package:gohan_map/collections/timeline.dart';
import 'package:gohan_map/colors/app_colors.dart';
import 'package:gohan_map/component/app_modal.dart';
import 'package:gohan_map/utils/common.dart';
import 'package:gohan_map/view/place_post_page.dart';
import 'package:gohan_map/view/place_update_page.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:path/path.dart' as p;

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
    () async {
      final shop = await IsarUtils.getShopById(widget.id);
      if (shop == null) return;

      final timelines = await IsarUtils.getTimelinesByShopId(shop.id);
      setState(() {
        selectedShop = shop;
        shopTimeline = timelines;
      });
    }();
  }

  @override
  Widget build(BuildContext context) {
    return AppModal(
        backgroundColor: Colors.white,
        initialChildSize: 0.55,
        child: Column(children: [
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                              child: Text(
                            selectedShop?.shopName ?? '',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          )),
                          SizedBox(
                            height: 30,
                            width: 30,
                            child: IconButton(
                              padding: const EdgeInsets.fromLTRB(
                                  0, 0, 12, 12), //44px確保
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
                    const Padding(padding: EdgeInsets.only(top: 5)),
                    Row(
                      children: [
                        const Icon(
                          Icons.place,
                          color: Colors.blue,
                        ),
                        const Padding(padding: EdgeInsets.only(right: 5)),
                        Flexible(
                          child: Text(
                            selectedShop?.shopAddress ?? '',
                            style: const TextStyle(fontSize: 12),
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 8, bottom: 8, left: 2),
                      child: Row(children: [
                        Text(
                          selectedShop?.shopStar.toString() ?? "",
                          style: const TextStyle(color: Colors.black38),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(right: 4),
                        ),
                        IgnorePointer(
                          ignoring: true,
                          child: AppRatingBar(
                            initialRating: selectedShop?.shopStar ?? 0,
                            onRatingUpdate: (rating) {},
                            itemSize: 20,
                          ),
                        )
                      ]),
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                style: TextButton.styleFrom(
                                    fixedSize: const Size(140, 50),
                                    backgroundColor: const Color(0xFF4CAF50),
                                    foregroundColor: Colors.white,
                                    alignment: Alignment.centerLeft,
                                    shape: const StadiumBorder()),
                                onPressed: () {
                                  showModalBottomSheet(
                                    //モーダルを表示する関数
                                    barrierColor: Colors.black
                                        .withOpacity(0), //背景をどれぐらい暗くするか
                                    backgroundColor: Colors.transparent,
                                    context: context,
                                    isScrollControlled: true, //スクロールで閉じたりするか
                                    builder: (context) {
                                      return PlaceUpdatePage(
                                        shop: selectedShop!,
                                      ); //ご飯投稿
                                    },
                                  ).then((value) {
                                    IsarUtils.getShopById(widget.id)
                                        .then((shop) {
                                      setState(() {
                                        selectedShop = shop;
                                      });
                                    });
                                  });
                                },
                                child: RichText(
                                  text: TextSpan(children: [
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: Container(
                                        padding: const EdgeInsets.only(
                                            right: 10, left: 6),
                                        child: const Icon(Icons.home, size: 30),
                                      ),
                                    ),
                                    const TextSpan(
                                        text: '店舗の編集',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ]),
                                ),
                              ),
                              const Padding(
                                  padding: EdgeInsets.only(right: 30)),
                              TextButton(
                                style: TextButton.styleFrom(
                                    fixedSize: const Size(140, 50),
                                    backgroundColor: const Color(0xFF2196F3),
                                    foregroundColor: Colors.white,
                                    alignment: Alignment.centerLeft,
                                    shape: const StadiumBorder()),
                                onPressed: () {
                                  if (selectedShop == null) {
                                    return;
                                  }
                                  showModalBottomSheet(
                                    //モーダルを表示する関数
                                    barrierColor: Colors.black
                                        .withOpacity(0), //背景をどれぐらい暗くするか
                                    backgroundColor: Colors.transparent,
                                    context: context,
                                    isScrollControlled: true, //スクロールで閉じたりするか
                                    builder: (context) {
                                      return PlacePostPage(
                                        shop: selectedShop!,
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
                                child: RichText(
                                  text: TextSpan(children: [
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: Container(
                                        padding: const EdgeInsets.only(
                                            right: 25, left: 10),
                                        child: const Icon(
                                          Icons.restaurant,
                                          size: 25,
                                        ),
                                      ),
                                    ),
                                    const TextSpan(
                                        text: '投稿',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ]),
                                ),
                              ),
                            ])),
                  ])),
          const Divider(
            color: AppColors.backgroundGrayColor,
            thickness: 1,
            height: 1,
          ),
          FutureBuilder(
              future: getLocalPath(),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return Container();
                } else {
                  return Column(children: [
                    for (Timeline timeline in (shopTimeline ?? []))
                      Column(children: [
                        Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                const Padding(
                                                  padding:
                                                      EdgeInsets.only(right: 6),
                                                  child: Icon(
                                                    Icons.access_time,
                                                    size: 18,
                                                  ),
                                                ),
                                                // アイコンとテキストの間のスペースを設定
                                                Text(
                                                  DateFormat('yyyy/MM/dd')
                                                      .format(timeline.date),
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black38),
                                                ),
                                                if (timeline.umai)
                                                  const Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 12),
                                                    child: Icon(
                                                      Icons.thumb_up,
                                                      size: 18,
                                                      color: Color(0xFF2196F3),
                                                    ),
                                                  ),
                                              ],
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
                                                          .withOpacity(
                                                              0), //背景をどれぐらい暗くするか
                                                      backgroundColor:
                                                          Colors.transparent,
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
                                                      IsarUtils
                                                              .getTimelinesByShopId(
                                                                  selectedShop!
                                                                      .id)
                                                          .then((timeline) {
                                                        setState(() {
                                                          shopTimeline =
                                                              timeline;
                                                        });
                                                      });
                                                    });
                                                  },
                                                  title: '編集',
                                                  icon: CupertinoIcons.pencil,
                                                ),
                                                PullDownMenuItem(
                                                  onTap: () {
                                                    IsarUtils.deleteTimeline(
                                                        timeline.id);
                                                    setState(() {
                                                      shopTimeline!
                                                          .remove(timeline);
                                                    });
                                                  },
                                                  title: '削除',
                                                  isDestructive: true,
                                                  icon: CupertinoIcons.delete,
                                                ),
                                              ],
                                              animationBuilder: null,
                                              position: PullDownMenuPosition
                                                  .automatic,
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
                                        if (timeline.comment != "")
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 8),
                                            child: Text(
                                              timeline.comment,
                                              style:
                                                  const TextStyle(fontSize: 15),
                                            ),
                                          )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )),
                        if (timeline.image != null &&
                            timeline.image!.isNotEmpty)
                          Image.file(
                            File(p.join(snapshot.data!, timeline.image!)),
                            fit: BoxFit.fitWidth,
                          )
                      ])
                  ]);
                }
              }),
          const Divider(
            color: AppColors.backgroundGrayColor,
            thickness: 3,
            height: 3,
          ),
        ]));
  }
}
