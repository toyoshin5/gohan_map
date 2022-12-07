import 'package:flutter/Cupertino.dart';

class GohanAppModal extends StatelessWidget {
  final double? height;
  final Widget child;
  const GohanAppModal({
    required this.child,
    this.height,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey2,
              spreadRadius: 5,
              blurRadius: 10,
              offset: const Offset(0, 0), // changes position of shadow
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10.0),
            topRight: Radius.circular(10.0),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(0, 16, 0, 15),
              height: 5,
              width: 26,
              decoration: BoxDecoration(
                color: const Color(0x26000000),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
