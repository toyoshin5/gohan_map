import 'dart:convert';
import 'dart:io';

import 'package:date_time_picker/date_time_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/Cupertino.dart';
import 'package:flutter/Material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:gohan_map/collections/shop.dart';
import 'package:gohan_map/collections/timeline.dart';
import 'package:gohan_map/component/post_food_widget.dart';
import 'package:gohan_map/utils/isar_utils.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import 'package:gohan_map/colors/app_colors.dart';
import 'package:gohan_map/component/app_modal.dart';

//飲食店の登録画面
class PlaceCreatePage extends StatefulWidget {
  final LatLng latlng;
  const PlaceCreatePage({
    Key? key,
    required this.latlng,
  }) : super(key: key);

  @override
  State<PlaceCreatePage> createState() => _PlaceCreatePageState();
}

class _PlaceCreatePageState extends State<PlaceCreatePage> {
  String shopName = '';
  String address = '';
  double rating = 3;
  File? image;
  DateTime? date;
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
            //飲食店名
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ShopNameTextField(
                  onChanged: (value) {
                    setState(() {
                      shopName = value;
                    });
                  },
                ),
                const SizedBox(width: 24),
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
              ],
            ),
            //住所
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 16, 0, 4),
              child: Text(
                '住所',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            FutureBuilder(
              future: getAddressFromLatLng(widget.latlng),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  address = snapshot.data.toString();
                  return Text(snapshot.data.toString());
                } else {
                  return const Text('住所を取得中...');
                }
              },
            ),
            //評価
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 16, 0, 4),
              child: Text(
                '店の評価',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _ShopRatingBar(
              rating: rating,
              onRatingUpdate: (rating) {
                setState(() {
                  rating = rating;
                });
              },
            ),
            //最初の投稿
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 16, 0, 8),
              child: Text(
                '最初の投稿',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            PostFoodWidget(
              onImageChanged: (image) {
                setState(() {
                  this.image = image;
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

            Container(
              width: double.infinity,
              height: 50,
              margin: const EdgeInsets.symmetric(vertical: 16),
              child: TextButton(
                child: const Text('決定'),
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  foregroundColor: AppColors.blackTextColor,
                  backgroundColor: AppColors.backgroundWhiteColor,
                ),
                onPressed: () {
                  //iOS風のアラートを表示する
                  onTapComfirm(context);

                  //Navigator.pop(context);
                },
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
    if (shopName.isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text('店名を入力してください'),
            content: const Text('店を登録するためには、店名の入力が必要です。'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () async {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
      return;
    } else if (image == null && date == null && comment.isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text('最初の投稿がありません'),
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
                  addToDB(false);
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
      return;
    }
    addToDB(true);
  }

  Future<void> addToDB(bool initialPostFlg) async {
    final shop = Shop()
      ..shopName = shopName
      ..shopAddress = address //TODO
      ..shopLatitude = widget.latlng.latitude
      ..shopLongitude = widget.latlng.longitude
      ..shopStar = rating
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();
    final shopId = await IsarUtils.createShop(shop);
    if (initialPostFlg) {
      final base64Img = await fileToBase64(image);
      final timeline = Timeline()
        ..image = base64Img
        ..comment = comment
        ..umai = false
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now()
        ..shopId = shopId
        ..date = date ?? DateTime.now();
      await IsarUtils.createTimeline(timeline);
      if (context.mounted) {
        Navigator.pop(context);
        return;
      }
    }
    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  Future<String> fileToBase64(File? file) async {
    if (file == null) {
      return '';
    }
    List<int> fileBytes = await file.readAsBytes();
    String base64Image = base64Encode(fileBytes);
    return base64Image;
  }

  //緯度経度から住所を取得する
  Future<String> getAddressFromLatLng(LatLng latLng) async {
    const String apiKey = String.fromEnvironment("YAHOO_API_KEY");
    final String apiUrl = 'https://map.yahooapis.jp/geoapi/V1/reverseGeoCoder?lat=${latLng.latitude}&lon=${latLng.longitude}&appid=$apiKey&output=json';
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final address = responseData['Feature'][0]['Property']['Address'];
      return address;
    } else {
      return '住所を取得できませんでした';
    }
  }
}

class _ShopRatingBar extends StatelessWidget {
  const _ShopRatingBar({
    super.key,
    required double rating,
    required this.onRatingUpdate,
  }) : _rating = rating;

  final double _rating;
  final Function(double) onRatingUpdate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RatingBar(
        initialRating: _rating,
        minRating: 0,
        maxRating: 5,
        direction: Axis.horizontal,
        allowHalfRating: true,
        itemCount: 5,
        itemSize: 40.0,
        glowColor: Colors.amber,
        onRatingUpdate: onRatingUpdate,
        ratingWidget: RatingWidget(
          full: const Icon(Icons.star, color: Colors.amber),
          half: const _HalfStarIcon(),
          empty: const Icon(Icons.star, color: Color(0xffd3d3d3)),
        ),
      ),
    );
  }
}

class _HalfStarIcon extends StatelessWidget {
  const _HalfStarIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Icon(Icons.star, color: Color(0xffd3d3d3)),
        ClipRect(
          clipper: _HalfClipper(),
          child: const Icon(Icons.star, color: Colors.amber),
        ),
      ],
    );
  }
}

class _HalfClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, size.width / 2, size.height);
  }

  @override
  bool shouldReclip(_HalfClipper oldClipper) => false;
}

//AppTextField
class _ShopNameTextField extends StatelessWidget {
  const _ShopNameTextField({
    Key? key,
    required this.onChanged,
  }) : super(key: key);
  final Function(String) onChanged;
  @override
  Widget build(BuildContext context) {
    //角丸,白いぬりつぶし,枠線なし
    return Flexible(
      child: TextField(
        decoration: InputDecoration(
          hintText: '店名を入力',
          filled: true,
          fillColor: AppColors.textFieldColor,
          contentPadding: const EdgeInsets.all(16),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: AppColors.textFieldColor,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: AppColors.textFieldColor,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
