

import 'package:flutter/material.dart';

class ShowNoti extends StatefulWidget {
  final String title, message;
  const ShowNoti({Key? key, required this.title, required this.message})
      : super(key: key);

  @override
  _ShowNotiState createState() => _ShowNotiState();
}

class _ShowNotiState extends State<ShowNoti> {
  String? title, message;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    title = widget.title;
    message = widget.message;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
           Text(title!),
           Text(message!),
        ],
      ),
    );
  }
}
