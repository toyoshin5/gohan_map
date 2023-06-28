import 'package:flutter/material.dart';
import 'package:gohan_map/colors/app_colors.dart';
import 'package:gohan_map/component/app_modal.dart';

class ChangeMapPage extends StatelessWidget {
  const ChangeMapPage({Key? key, this.isIOS = false}) : super(key: key);

  final bool isIOS;

  @override
  Widget build(BuildContext context) {
    return AppModal(
        child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('地図の切り替え', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          //OpenStreetMap
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: AppColors.backgroundWhiteColor,
              foregroundColor: AppColors.blackTextColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('OpenStreetMap', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('標準的なマップです。'),
                    ],
                  ),
                  SizedBox(
                    width: 50,
                    child: (!isIOS) ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor) : Container(),
                  ),
                ],
              ),
            ),
            onPressed: () {
              Navigator.pop(context, 'osm');
            },
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: AppColors.backgroundWhiteColor,
              foregroundColor: AppColors.blackTextColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('AppleMap(試験的)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('iOSネイティブのマップを表示します。\n一部のパフォーマンスに影響を与える場合があります。'),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 50,
                    child: (isIOS) ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor) : Container(),
                  ),
                ],
              ),
            ),
            onPressed: () {
              Navigator.pop(context, "apple");
            },
          ),
        ],
      ),
    ));
  }
}
