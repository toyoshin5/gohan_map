
import 'package:flutter/Material.dart';
import 'package:gohan_map/collections/timeline.dart';
import 'package:gohan_map/component/post_card_widget.dart';

class PostDetailPage extends StatefulWidget {
  const PostDetailPage({super.key, required this.timeline, this.imageData, required this.shopName});
  final Timeline timeline;
  final String? imageData;
  final String shopName;
  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '投稿詳細',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        //色
        backgroundColor: Colors.white,
      ),
      body: (widget.imageData!=null)?
      Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(
                16, 12, 16, 0),
            width: double.infinity,
            child: Text(
              widget.shopName ?? "",
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ),
          PostCardWidget(
            timeline: widget.timeline, 
            imageData: widget.imageData!, 
            onEditTapped: (){

            }, onDeleteTapped: (){

            }),
        ],
      ):
        Container(),
    );
  }
}
