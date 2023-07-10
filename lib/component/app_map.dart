import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gohan_map/colors/app_colors.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

class AppMap extends StatefulWidget {
  final void Function(TapPosition, LatLng)? onLongPress;
  final List<Marker>? pins;
  final MapController? mapController;

  const AppMap({
    Key? key,
    required this.onLongPress,
    this.pins,
    this.mapController,
  }) : super(key: key);

  @override
  State<AppMap> createState() => _AppMapState();
}

class _AppMapState extends State<AppMap> with TickerProviderStateMixin {
  late Future<Position> future;
  Marker? presetLocationMarker;
  late LatLng currentPosition;
  bool isCurrentLocation = true;

  @override
  void initState() {
    super.initState();
    future = Future(() async {
      var pos = await getCurrentPosition();
      setPresetLocationMarker(LatLng(pos.latitude, pos.longitude));
      return pos;
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
            currentPosition =
                LatLng(snapshot.data!.latitude, snapshot.data!.longitude);
            return Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    center: currentPosition,
                    minZoom: 3,
                    maxZoom: 18,
                    zoom: 13,
                    interactiveFlags: InteractiveFlag.all,
                    enableMultiFingerGestureRace: true,
                    onLongPress: widget.onLongPress,
                    onPositionChanged: (position, hasGesture) {
                      if (hasGesture && isCurrentLocation) {
                        setState(() {
                          isCurrentLocation = false;
                        });
                      }
                    },
                  ),
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
                      urlTemplate:
                          'https://api.maptiler.com/maps/jp-mierune-streets/256/{z}/{x}/{y}@2x.png?key=j4Xnfvwl9nEzUVlzCdBr',
                    ),
                    if (widget.pins != null)
                      MarkerLayer(
                        markers: [...widget.pins!, presetLocationMarker!],
                        rotate: true,
                      ),
                  ],
                ),
                //現在地に戻るボタン
                Positioned(
                  bottom: 120,
                  right: 20,
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: ElevatedButton(
                      //角丸で白
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(0),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.blueTextColor,
                      ),
                      onPressed: () {
                        setState(() {
                          isCurrentLocation = true;
                        });
                        _animatedMapMove(currentPosition, 13);
                      },
                      child: Icon((isCurrentLocation)
                          ? Icons.near_me
                          : Icons.near_me_outlined),
                    ),
                  ),
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

  void setPresetLocationMarker(LatLng latlng) {
    const markerSize = 30.0;

    var marker = Marker(
        width: markerSize,
        height: markerSize,
        point: LatLng(latlng.latitude, latlng.longitude),
        builder: (context) => Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      blurRadius: 10, color: Colors.black26, spreadRadius: 3)
                ],
              ),
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.circle,
                  size: 27,
                  color: Colors.blue.shade600,
                ),
              ),
            ));

    setState(() {
      presetLocationMarker = marker;
    });
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    if (widget.mapController == null) {
      return;
    }
    final latTween = Tween<double>(
        begin: widget.mapController!.center.latitude,
        end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: widget.mapController!.center.longitude,
        end: destLocation.longitude);
    final zoomTween =
        Tween<double>(begin: widget.mapController!.zoom, end: destZoom);
    final rotateTween =
        Tween<double>(begin: widget.mapController!.rotation, end: 0.0);
    final controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    final Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);
    controller.addListener(() {
      widget.mapController!.move(
          LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
          zoomTween.evaluate(animation));
      widget.mapController!.rotate(rotateTween.evaluate(animation));
    });
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });
    controller.forward();
  }
}
