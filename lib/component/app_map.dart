import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

class AppMap extends StatefulWidget {
  final void Function(TapPosition, LatLng)? onLongPress;
  final List<Marker>? pins;
  final MapController? mapController;

  const AppMap({Key? key,
    required this.onLongPress,
    this.pins,
    this.mapController,
  }) : super(key: key);

  @override
  State<AppMap> createState() => _AppMapState();
}

class _AppMapState extends State<AppMap> {
  late Future<Position> future;

  @override
  void initState() {
    super.initState();
    future = Future(() async {
      return await getCurrentPosition();
    });
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
            return FlutterMap(
              options: MapOptions(
                  center:
                      LatLng(snapshot.data!.latitude, snapshot.data!.longitude),
                  zoom: 13,
                  interactiveFlags: InteractiveFlag.all,
                  onLongPress: widget.onLongPress),
              mapController: widget.mapController,
              nonRotatedChildren: [
                RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution(
                      'OpenStreetMap contributors',
                      onTap: () => launchUrl(
                          Uri.parse('https://openstreetmap.org/copyright')),
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
                  markers: widget.pins!,
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
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    var position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return position;
  }
}
