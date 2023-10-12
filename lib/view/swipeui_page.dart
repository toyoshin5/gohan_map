import 'package:flutter/material.dart';

class SwipeUIPage extends StatefulWidget {
  const SwipeUIPage({super.key});

  @override
  State<SwipeUIPage> createState() => SwipeUIPageState();
}

class SwipeUIPageState extends State<SwipeUIPage> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("スワイプページ",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
    );
  }


  //タブを選択した時に行う再描画処理(必要なら)
  void reload() {

  }
}