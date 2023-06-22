import 'package:flutter/Material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';


//レーティングのバー
class AppRatingBar extends StatelessWidget {
  const AppRatingBar({
    super.key,
    this.initialRating = 3.0,
    required this.onRatingUpdate,
  });

  final double initialRating;
  final Function(double) onRatingUpdate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RatingBar(
        initialRating: initialRating,
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