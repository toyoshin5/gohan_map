import 'package:flutter/Cupertino.dart';
import 'package:gohan_map/component/app_modal.dart';
import 'package:latlong2/latlong.dart';
///飲食店の登録画面
class PlaceCreatePage extends StatelessWidget {
  final LatLng latlng;
  const PlaceCreatePage({Key? key,
    required this.latlng,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AppModal(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('PlaceCreatePage'),
            const Text('緯度経度'),
            Text('緯度: ${latlng.latitude}'),
            Text('経度: ${latlng.longitude}'),
            CupertinoButton(
              child: const Text('Create'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),  
      ),
    );
  }
}


