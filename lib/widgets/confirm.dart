import 'package:flutter/material.dart';

class ConfirmPopup extends StatelessWidget {
  final String title;
  final VoidCallback onYes;
  final VoidCallback onNo;
  const ConfirmPopup({required this.title, required this.onYes , required this.onNo, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title ,style: TextStyle(
        fontFamily: "Mitr",
        fontWeight: FontWeight.w500,
        fontSize: 25,
      ),),
      actions: [
        TextButton(
            onPressed: onNo,
            child: Text('ไม่', style: TextStyle(
              fontFamily: "Mitr",
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Colors.red,
            ),)
        ),
        TextButton(
            onPressed: onYes,
            child: Text('ใช่', style: TextStyle(
              fontFamily: "Mitr",
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Colors.green,
            ),)
        )
      ],
    );
  }
}
