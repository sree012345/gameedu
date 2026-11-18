import 'package:flutter/material.dart';

class ShowBottomsheet {
  static void enableBottomSheet(BuildContext context, Widget widget) async {
   await showModalBottomSheet<void>(
      isDismissible: false,
      enableDrag:false,
      backgroundColor: Colors.transparent, // 
      context: context,
      builder: (BuildContext context) {
        return widget;
      },
    );
  }
}
