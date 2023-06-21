import 'dart:convert';
import 'dart:io';

import 'package:date_time_picker/date_time_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/Material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:gohan_map/component/post_food_widget.dart';
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
  double _rating = 3;
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
                const _ShopNameTextField(),
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
              padding: 
              EdgeInsets.fromLTRB(0, 16, 0, 4),
              child: Text(
                '住所',
                style:TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            FutureBuilder(
              future: _getAddressFromLatLng(widget.latlng),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(snapshot.data.toString());
                } else {
                  return const Text('住所を取得中...');
                }
              },
            ),
            //評価
            const Padding(
              padding: 
              EdgeInsets.fromLTRB(0, 16, 0, 4),
              child: Text(
                '店の評価',
                style:TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _ShopRatingBar(
              rating: _rating,
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            //最初の投稿
            const Padding(
              padding: 
              EdgeInsets.fromLTRB(0, 16, 0, 8),
              child: Text(
                '最初の投稿',
                style:TextStyle(
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
                  //image, date, commentを出力
                  print(image);
                  print(date);
                  print(comment);
        
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

  //緯度経度から住所を取得する
  Future<String> _getAddressFromLatLng(LatLng latLng) async {
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
        //allowHalfRating: true,
        itemCount: 5,
        itemSize: 40.0,
        glowColor: Colors.amber,
        onRatingUpdate: onRatingUpdate,
        ratingWidget: RatingWidget(
          full: const Icon(Icons.star, color: Colors.amber),
          half: const Icon(Icons.star_half, color: Colors.amber),
          empty: const Icon(Icons.star, color: Color(0xffd3d3d3)),
        ),
      ),
    );
  }
}

//AppTextField
class _ShopNameTextField extends StatelessWidget {
  const _ShopNameTextField({Key? key}) : super(key: key);
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
      ),
    );
  }
}
