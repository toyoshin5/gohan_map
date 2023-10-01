
import 'package:flutter/material.dart';

class AllPostPage extends StatelessWidget {
  const AllPostPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('全投稿',style: TextStyle(color: Colors.black),),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,color: Colors.black,),
          onPressed: () => Navigator.pop(context),
        ),
        //色
        elevation: 0,
        backgroundColor: Colors.white.withOpacity(0.5),
      ),
      body: //サンプルのtableview
      ListView.builder(
        itemCount: 100,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Item $index'),
          );
        },
      ),
    );
  }
}