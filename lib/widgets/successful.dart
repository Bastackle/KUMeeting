import 'package:flutter/material.dart';

class SuccessfulPopup extends StatelessWidget {
  final Widget nextPage;
  SuccessfulPopup({required this.nextPage});
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey.shade50,
      title: Align(
        alignment: Alignment.center,
        child: Text(
          'ดำเนินการเสร็จสิ้น',
          style: TextStyle(
            fontFamily: "Mitr",
            fontWeight: FontWeight.w600,
            fontSize: 25,
          ),
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.only(top: 25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(
              'https://media.tenor.com/BSY1qTH8g-oAAAAM/check.gif',
              height: 150,
              width: 150,
              fit: BoxFit.cover,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // ปิด popup
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => nextPage)
            );
          },
          child: Text(
            'ตกลง',
            style: TextStyle(
              fontFamily: "Mitr",
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Theme.of(context).primaryColor
            ),
          ),
        ),
      ],
    );
  }
}
