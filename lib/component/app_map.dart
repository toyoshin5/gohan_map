import 'dart:math';
import 'dart:ui';

import 'package:apple_maps_flutter/apple_maps_flutter.dart' as Apple;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:isar/isar.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

class Pin {
  Id? id;
  Marker marker;
  Pin(this.id, this.marker);
}

class AppMap extends StatefulWidget {
  final bool isAppleMap;
  final void Function(LatLng)? onLongPress;//両Map共通
  final void Function(Id, LatLng)? onTapApplePin; //ピンをタップしたときの処理(AppleMapのみ)
  final List<Pin>? pins; //両Map共通。FlutterMapはピンがButtonなので、こちらにピンのタップ時処理も記述。
  final MapController? mapController;//FlutterMap用のコントローラー
  final void Function(Apple.AppleMapController)? onAppleMapCreated;//AppleMap用のコントローラー

  const AppMap({
    Key? key,
    this.isAppleMap = false,
    required this.onLongPress,
    this.onTapApplePin,
    this.pins,
    this.mapController,
    this.onAppleMapCreated,
  }) : super(key: key);

  @override
  State<AppMap> createState() => _AppMapState();
}

class _AppMapState extends State<AppMap> {
  late Future<Position> future;
  late Uint8List markerIcon;

  @override
  void initState() {
    super.initState();
    future = Future(() async {
      return await getCurrentPosition();
    });
    getBytesFromAsset('images/pin.png', 100).then((value) => markerIcon = value);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Position>(
      future: future,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return const SizedBox();
          case ConnectionState.waiting:
            return const SizedBox();
          case ConnectionState.active:
            return const SizedBox();
          case ConnectionState.done:
            if (widget.isAppleMap) {
              //iOS:AppleMap
              return Apple.AppleMap(
                myLocationButtonEnabled: true,
                myLocationEnabled: true,
                compassEnabled: false,
                initialCameraPosition: Apple.CameraPosition(
                  target: Apple.LatLng(snapshot.data!.latitude, snapshot.data!.longitude),
                  zoom: 13,
                ),
                onLongPress: (widget.onLongPress != null)
                    ? (latLng) {
                        widget.onLongPress!(toFlutterLatlng(latLng));
                      }
                    : null,
                annotations: toAppleAnnotation(widget.pins),
                onMapCreated: widget.onAppleMapCreated,
              );
            }
            //Android:OpenStreetMap
            return FlutterMap(
              options: MapOptions(
                  center: LatLng(snapshot.data!.latitude, snapshot.data!.longitude),
                  minZoom: 3,
                  maxZoom: 18,
                  zoom: 13,
                  interactiveFlags: InteractiveFlag.all,
                  onLongPress: (widget.onLongPress != null)
                      ? (_, latLng) {
                          widget.onLongPress!(latLng);
                        }
                      : null),
              mapController: widget.mapController,
              nonRotatedChildren: [
                RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution(
                      'OpenStreetMap contributors',
                      onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
                    ),
                  ],
                ),
              ],
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                ),
                if (widget.pins != null)
                  MarkerLayer(
                    markers: widget.pins!.map((pin) => pin.marker).toList(),
                    rotate: true,
                  ),
              ],
            );
        }
      },
    );
  }

  Future<Position> getCurrentPosition() async {
    // 位置情報サービスが有効かチェック
    var serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Future.error("Location services are disabled");
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("Location permission are denied");
      }
    }

    // 永久に拒否されている場合はエラーを返す
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    var position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    return position;
  }

  
  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    Codec codec = await instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ImageByteFormat.png))!.buffer.asUint8List();
  }

  //MarkerからApple.annotationに変換する関数
  Set<Apple.Annotation>? toAppleAnnotation(List<Pin>? pin) {
    if (pin == null) {
      return null;
    }
    return pin.map((e) {
      return Apple.Annotation(
        annotationId: Apple.AnnotationId(e.hashCode.toString()),
        position: toAppleLatlng(e.marker.point),
        icon: Apple.BitmapDescriptor.fromBytes(markerIcon),
        onTap: (widget.onTapApplePin != null && e.id != null)
            ? () {
                widget.onTapApplePin!(e.id!, e.marker.point);
              }
            : null,
      );
    }).toSet();
  }

  //LatlngからApple.LatLngに変換する関数
  Apple.LatLng toAppleLatlng(LatLng latLng) {
    return Apple.LatLng(latLng.latitude, latLng.longitude);
  }

  //Apple.LatLngからLatlngに変換する関数
  LatLng toFlutterLatlng(Apple.LatLng latLng) {
    return LatLng(latLng.latitude, latLng.longitude);
  }
}
