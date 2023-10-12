import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gohan_map/collections/shop.dart';
import 'package:gohan_map/collections/timeline.dart';
import 'package:gohan_map/colors/app_colors.dart';
import 'package:gohan_map/component/app_modal.dart';
import 'package:gohan_map/component/post_card_widget.dart';
import 'package:gohan_map/utils/common.dart';
import 'package:gohan_map/view/place_post_page.dart';
import 'package:gohan_map/view/place_update_page.dart';

import 'package:isar/isar.dart';

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
  double aveStar = 0.0;
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
        //平均
        aveStar = calcAveStar(timelines);
      });
    }();
  }

  double calcAveStar(List<Timeline> timelines) {
    List<double> stars = [];
    for (Timeline p in timelines) {
      stars.add(p.star);
    }
    if (stars.isEmpty) {
      return 0.0;
    }
    return stars.reduce((a, b) => a + b) / stars.length;
  }

  @override
  Widget build(BuildContext context) {
    return AppModal(
        backgroundColor: Colors.white,
        initialChildSize: 0.55,
        showKnob: false,
        child: Column(children: [
          Stack(
            children: [
              SizedBox(
                width: double.infinity,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxHeight: min(MediaQuery.of(context).size.width, 140)),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: Image.asset(
                      "images/header.jpg",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                  right: 12,
                  top: 12,
                  child: SizedBox(
                    height: 30,
                    width: 30,
                    child: IconButton(
                      padding: const EdgeInsets.fromLTRB(0, 0, 12, 12), //44px確保
                      icon: Icon(
                        Icons.cancel_outlined,
                        color: Colors.grey[300],

                        size: 32,
                      ),
                      onPressed: () {
                        Navigator.pop(context); //前の画面に戻る
                      },
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(
            height: 12,
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //画像を100pxの高さで表示

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
                    if (shopTimeline?.isNotEmpty ?? false)
                    //星の数
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 8, bottom: 8, left: 2),
                      child: Row(children: [
                        Text(
                          ((aveStar*100).floor()/100.0).toString(),
                          style: const TextStyle(color: Colors.black38),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(right: 4),
                        ),
                        IgnorePointer(
                          ignoring: true,
                          child: AppRatingBar(
                            initialRating: aveStar-0.24,//星の数の表示が正しくない不具合を対処
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
                                        aveStar = calcAveStar(timeline);
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
            color: AppColors.greyColor,
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
                    for (Timeline timeline in (shopTimeline ?? [])) ...[
                      PostCardWidget(
                        timeline: timeline,
                        imageData: snapshot.data!,
                        onEditTapped: () {
                          if (selectedShop == null) {
                            return;
                          }
                          showModalBottomSheet(
                            //モーダルを表示する関数
                            barrierColor:
                                Colors.black.withOpacity(0), //背景をどれぐらい暗くするか
                            backgroundColor: Colors.transparent,
                            context: context,
                            isScrollControlled: true, //スクロールで閉じたりするか
                            builder: (context) {
                              return PlacePostPage(
                                shop: selectedShop!,
                                timeline: timeline,
                              ); //ご飯投稿
                            },
                          ).then((value) {
                            IsarUtils.getTimelinesByShopId(selectedShop!.id)
                                .then((timeline) {
                              setState(() {
                                shopTimeline = timeline;
                                aveStar = calcAveStar(timeline);
                              });
                            });
                          });
                        },
                        onDeleteTapped: () {
                          IsarUtils.deleteTimeline(timeline.id);
                          setState(() {
                            shopTimeline!.remove(timeline);
                            aveStar = calcAveStar(shopTimeline!);
                          });
                        },
                      ),
                      const Divider(
                        thickness: 1,
                        height: 1,
                      ),
                    ],
                  ]);
                }
              }),
        ]));
  }
}
