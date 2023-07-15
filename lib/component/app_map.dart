import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gohan_map/colors/app_colors.dart';
import 'package:gohan_map/component/app_direction_light.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

class AppMap extends StatefulWidget {
  final void Function(TapPosition?, LatLng) onLongPress;
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
  LatLng? currentPosition;
  late StreamSubscription<Position> positionStream;
  bool isCurrentLocation = true;

  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 1,
  );

  late Animation<double> currentIconAni;
  late AnimationController plMarkerController;
  @override
  void initState() {
    super.initState();
    init();
    //アニメーションの定義
    plMarkerController = AnimationController(vsync: this, duration: const Duration(seconds: 5));
    const shrinkSize = 0.8;
    currentIconAni = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(
            begin: 1,
            end: shrinkSize,
          ),
          weight: 3),
      TweenSequenceItem(
          tween: Tween(
            begin: shrinkSize,
            end: shrinkSize,
          ),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(
            begin: shrinkSize,
            end: 1,
          ),
          weight: 5),
      TweenSequenceItem(
          tween: Tween(
            begin: 1,
            end: 1,
          ),
          weight: 3),
    ]).animate(plMarkerController);

    plMarkerController
      ..forward()
      ..addListener(() {
        if (plMarkerController.isCompleted) {
          plMarkerController.repeat();
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    if (currentPosition == null) {
      return const SizedBox();
    }

    return Stack(
      children: [
        StreamBuilder<CompassEvent>(
            stream: FlutterCompass.events,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error reading heading: ${snapshot.error}');
              }
              //シミュレーターの場合は無視
              if (snapshot.connectionState == ConnectionState.waiting && kReleaseMode == true) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              double direction = snapshot.data?.heading ?? 0;
              // 現在位置と方向のマーカーを作成する
              var presetLocationMarker = _buildPresetLocationMarker();
              var compassMarker = _buildCompassMarker(direction);

              return FlutterMap(
                options: MapOptions(
                  center: currentPosition,
                  minZoom: 3,
                  maxZoom: 18,
                  zoom: 15,
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
                        onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
                      ),
                    ],
                  ),
                ],
                children: [
                  TileLayer(
                    urlTemplate: 'https://api.maptiler.com/maps/jp-mierune-streets/256/{z}/{x}/{y}@2x.png?key=j4Xnfvwl9nEzUVlzCdBr',
                  ),
                  if (widget.pins != null)
                    MarkerLayer(
                      markers: widget.pins!,
                      rotate: true,
                    ),
                  MarkerLayer(
                    markers: [
                      compassMarker,
                      presetLocationMarker,
                    ],
                    rotate: false,
                  )
                ],
              );
            }),
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
                _animatedMapMove(currentPosition!, 15);
              },
              child: Icon((isCurrentLocation) ? Icons.near_me : Icons.near_me_outlined),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> init() async {
    await checkGPSPermission();

    // ユーザの現在位置を取得し続ける
    positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position position) {
      var latLng = LatLng(position.latitude, position.longitude);
      setState(() {
        currentPosition = latLng;
      });
    });
  }

  Future<void> checkGPSPermission() async {
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
  }

  Marker _buildPresetLocationMarker() {
    const markerSize = 24.0;
    var marker = Marker(
        width: markerSize,
        height: markerSize,
        point: currentPosition!,
        builder: (context) => GestureDetector(
            onTap: () {
              if (currentPosition == null) {
                return;
              }
              widget.onLongPress(null, currentPosition!);
            },
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26, spreadRadius: 3)],
              ),
              child: CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white,
                  child: ScaleTransition(
                    scale: currentIconAni,
                    child: Icon(
                      Icons.circle,
                      size: 22,
                      color: Colors.blue.shade600,
                    ),
                  )),
            )));

    return marker;
  }

  Marker _buildCompassMarker(
    double direction,
  ) {
    const markerSize = 12.0;

    return Marker(
        width: markerSize,
        height: markerSize / 2 * math.sqrt(3),
        point: currentPosition!,
        builder: (context) {
          return Transform.translate(offset: const Offset(0, -16), child: Transform.rotate(angle: (direction * (math.pi / 180)), origin: const Offset(0, 16), child: AppDirectionLight()));
        });
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    if (widget.mapController == null) {
      return;
    }
    final latTween = Tween<double>(begin: widget.mapController!.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(begin: widget.mapController!.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: widget.mapController!.zoom, end: destZoom);
    final rotateTween = Tween<double>(begin: widget.mapController!.rotation, end: 0.0);
    final controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    final Animation<double> animation = CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);
    controller.addListener(() {
      widget.mapController!.move(LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)), zoomTween.evaluate(animation));
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

  @override
  void dispose() {
    plMarkerController.dispose();
    super.dispose();
  }
}
