import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

class BookingPopup extends StatelessWidget {
  final VoidCallback onClose;

  BookingPopup({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(FluentIcons.info_24_filled, color: Colors.red,),
          SizedBox(width: 10,),
          Text("ข้อปฏิบัติในการจองห้องประชุม", style: TextStyle(
            fontFamily: "Mitr",
            fontSize: 20,
            color: Colors.red
            ),
          ),
        ],
      ),

      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            DefaultTextStyle(
              style: TextStyle(
                fontFamily: "Mitr",
                color: Colors.black,
                fontSize: 15
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("- ผู้จองต้องกรอกข้อมูลให้ครบถ้วน"),
                  Text("- การจองต้องดำเนินการล่วงหน้าอย่างน้อย 24 ชั่วโมง และไม่เกิน 30 วันล่วงหน้า"),
                  Text("- การจองต้องมีระยะเวลาอย่างน้อย 1 ชั่วโมง และไม่เกินเวลาสูงสุดที่กำหนด ดังนี้:"),
                  Text("    1. นิสิต จองได้ไม่เกิน 2 ชั่วโมง"),
                  Text("    2. องค์กรนิสิต จองได้ไม่เกิน 4 ชั่วโมง"),
                  Text("    3. องค์นิสิต จองได้ไม่เกิน 6 ชั่วโมง"),
                  Text("สามารถขยายเวลาได้อีก 1 ชั่วโมง ในกรณีที่ไม่มีผู้ใช้บริการท่านอื่นจองต่อ โดยต้องมาติดต่อเจ้าหน้าที่ก่อนหมดเวลาใช้งาน 15 นาที"),
                  Text("- หากต้องการยกเลิกการจอง กรุณาดำเนินการล่วงหน้าอย่างน้อย 12 ชั่วโมงก่อนเวลาเริ่มต้น"),
                  Text("- ท่านต้องมายืนยันการใช้งานด้วยตนเอง"),
                  Text("- ยืนยันกับเจ้าหน้าที่ประจำเคาน์เตอร์ให้บริการ"),
                  Text("- มีเวลายืนยัน 15 นาทีหลังเวลาจองเริ่มต้น"),
                  Text("- หากไม่ได้ยืนยัน จะถูกยกเลิกสิทธิ์อัตโนมัติ"),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                onClose();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.green
              ),
              child: Text("ยอมรับ",style: TextStyle(
                fontFamily: "Mitr"
              ),),
            ),
          ],
        ),
      ],
    );
  }
}
