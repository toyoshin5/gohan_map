import 'dart:ui';

import 'package:flutter/Cupertino.dart';
import 'package:gohan_map/colors/app_colors.dart';
import 'package:gohan_map/component/app_modal.dart';
import 'package:flutter/material.dart';
import 'package:date_time_picker/date_time_picker.dart';

/// 飲食店でのごはん投稿画面
class PlacePostPage extends StatelessWidget {
  const PlacePostPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppModal(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.7,
      child: Padding(
        //余白を作るためのウィジェット
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          //縦に並べるためのウィジェット
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('トリトン'),
            const Text("北海道札幌市豊平区豊平４条６丁目１−１０"),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.backgroundWhiteColor,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.symmetric(vertical: 45),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 15),
                    child: DateTimePicker(
                      dateMask: 'yyyy/MM/dd',
                      initialValue: DateTime.now().toString(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      decoration: const InputDecoration(
                          icon: Icon(Icons.event),
                          filled: true,
                          labelText: '訪問日'),
                      onSaved: (val) => print(val),
                    ),
                  ),
                  TextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: 4,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            width: 0,
                            style: BorderStyle.none,
                          ),
                        ),
                        hintText: 'コメント',
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 17,
                        ),
                        filled: true),
                  ),
                ],
              ),
            ),
            Container(
                width: double.infinity,
                height: 50,
                margin: const EdgeInsets.only(bottom: 10),
                child: CupertinoButton(
                  color: AppColors.backgroundWhiteColor,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    '決定',
                    style: TextStyle(
                        color: AppColors.blueTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                )),
            Container(
                width: double.infinity,
                height: 50,
                child: CupertinoButton(
                  color: AppColors.backgroundWhiteColor,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'キャンセル',
                    style: TextStyle(
                        color: AppColors.redTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
