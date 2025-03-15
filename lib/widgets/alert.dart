import 'package:flutter/material.dart';

class AlertBox {
  static void showErrorDialog(BuildContext context, String message) {
    showDialog(context: context,
        builder: (context) => AlertDialog(
          title: Text('KUMeeting', style: TextStyle(
            fontFamily: "Mitr",
            fontWeight: FontWeight.w600,
            fontSize: 30,
          ),),
          content: Text(message, style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontFamily: "Mitr"
          ),),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('ตกลง', style: TextStyle(
                  color: Colors.green,
                  fontSize: 20,
                  fontFamily: "Mitr"
                ),)
            )
          ],
        )
    );
  }
}