import 'package:flutter/material.dart';
import 'package:gohan_map/collections/timeline.dart';
import 'package:gohan_map/component/post_card_widget.dart';
import 'package:gohan_map/utils/isar_utils.dart';
import 'package:gohan_map/view/place_post_page.dart';

import '../utils/common.dart';

class AllPostPage extends StatefulWidget {
  const AllPostPage({super.key});

  @override
  State<AllPostPage> createState() => _AllPostPageState();
}

class _AllPostPageState extends State<AllPostPage> {
  List<Timeline>? shopTimeline;
  @override
  void initState() {
    super.initState();
    () async {
      final timelines = await IsarUtils.getAllTimelines();
      setState(() {
        shopTimeline = timelines;
      });
    }();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: const Text(
          'すべての投稿',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        //色
        elevation: 0,
        backgroundColor: Colors.white.withOpacity(0.5),
      ),
      body: //サンプルのtableview
          SingleChildScrollView(
            child: FutureBuilder(
                future: getLocalPath(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return Container();
                  } else {
                    return Column(children: [
                      for (Timeline timeline in (shopTimeline ?? [])) 
                        FutureBuilder(
                        future: IsarUtils.getShopById(timeline.shopId),
                        builder: (context, snapshot2) {
                          return Column(
                            children: [
                              Container(
                                color: Colors.white,
                                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                                width: double.infinity,
                                child: Text(
                                  snapshot2.data?.shopName ?? "",
                                  style: const TextStyle(
                                      fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              ),
                              PostCardWidget(
                                timeline: timeline,
                                snapshot: snapshot,
                                onEditTapped: () {
                                  showModalBottomSheet(
                                    //モーダルを表示する関数
                                    barrierColor: Colors.black
                                        .withOpacity(0), //背景をどれぐらい暗くするか
                                    backgroundColor: Colors.transparent,
                                    context: context,
                                    isScrollControlled: true, //スクロールで閉じたりするか
                                    builder: (context) {
                                      if (snapshot2.data != null) {
                                        return PlacePostPage(
                                        shop: snapshot2.data!,
                                        timeline: timeline,
                                      ); //ご飯投稿
                                      } else {
                                        return Container();
                                      }
                                    },
                                  ).then((value) {
                                    if (value == null) {
                                      return;
                                    }
                                    IsarUtils.getAllTimelines()
                                        .then((timeline) {
                                      setState(() {
                                        shopTimeline = timeline;
                                      });
                                    });
                                  });
                                },
                                onDeleteTapped: () {
                                  IsarUtils.deleteTimeline(timeline.id);
                                  setState(() {
                                    shopTimeline!.remove(timeline);
                                  });
                                },
                              ),
                              const Divider(
                                thickness: 1,
                                height: 1,
                              ),
                            ],
                          );
                        }),
                        
                      ],
                    );
                  }
                }),
          ),
    );
  }
}
