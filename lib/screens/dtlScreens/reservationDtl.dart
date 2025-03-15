import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:project/screens/dtlScreens/map_screen.dart';
import 'package:project/services/reservation_service.dart';
import 'package:project/widgets/confirm.dart';

class reservationDtl extends StatelessWidget {
  final reserve;
  final String lateCancellationMessage =
      'กรณีที่มาช้ากว่าเวลาจองห้อง 15 นาที การจองจะถูกยกเลิก';
  final String CancellationMessage =
      'การจองนี้ถูกยกเลิกแล้ว';
  reservationDtl({super.key, required this.reserve});

  @override
  Widget build(BuildContext context) {
    bool isPending = reserve['status'] == 'รอการใช้งาน';
    bool isCancelled = reserve['status'] == 'ยกเลิกแล้ว';

    return Scaffold(
      backgroundColor: Theme.of(context).secondaryHeaderColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          title: Text(
            'Reservation Details',
            style: TextStyle(
              fontFamily: "Mitr",
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontSize: 22,
            ),
          ),
          backgroundColor: Theme.of(context).secondaryHeaderColor,
          elevation: 4,
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    reserve['roomImage'],
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  'รายละเอียดการจองห้องประชุม:',
                  style: TextStyle(
                    fontFamily: "Mitr",
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),

                _buildRowWithIcon('สถานะการจองห้องประชุม', '${reserve['status']}', FluentIcons.checkmark_12_filled),
                _buildRowWithIcon('ห้อง', '${reserve['roomName']}', FluentIcons.conference_room_16_filled),
                _buildingClickableRow(context, 'อาคาร', '${reserve['buildingName']}', reserve['location'],FluentIcons.location_12_filled),
                _buildRowWithIcon('วันที่ใช้งาน', '${reserve['date']}', FluentIcons.calendar_ltr_12_filled),
                _buildRowWithIcon('เวลา', '${reserve['startTime']} - ${reserve['endTime']}', FluentIcons.clock_12_filled),
                _buildRowWithIcon('จำนวนผู้เข้าใช้งาน', '${reserve['people']} คน', FluentIcons.people_12_filled),

                if (isPending || isCancelled)
                  Column(
                    children: [
                      SizedBox(height: 24),
                      Text(
                        isPending ? lateCancellationMessage : CancellationMessage,
                        style: TextStyle(
                          fontFamily: "Mitr",
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 30),
                    ],
                  ),

                if(isPending)
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _showConfirmPopup(context);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          minimumSize: Size(240, 60),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                            side: BorderSide(
                              color: Colors.blueGrey.shade300,
                              width: 2,
                            ),
                          ),
                          backgroundColor: Color(0xFF212121),
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.redAccent.shade100),
                        ),
                        child: Text(
                          "ยกเลิกการจองห้องประชุม",
                          style: TextStyle(
                              fontFamily: "Mitr",
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.redAccent.shade100),
                        ),
                      ),
                      SizedBox(height: 30),
                    ],
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRowWithIcon(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFF212121),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade600, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white, size: 28),
                SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: "Mitr",
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            Text(
              value,
              style: TextStyle(
                fontFamily: "Mitr",
                color: Colors.grey.shade300,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildingClickableRow(BuildContext context, String label, String value, GeoPoint location, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFF212121),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade600, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white, size: 28),
                SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: "Mitr",
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BuildingMap(
                          buildingName: value,
                          buildingLocation: location,
                        )
                    )
                );
              },
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: 250
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.greenAccent,
                      width: 1
                    )
                  )
                ),
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: "Mitr",
                    color: Colors.greenAccent,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmPopup(BuildContext mainContext) {
    showDialog(
      context: mainContext,
      builder: (BuildContext dialogContext) {
        return ConfirmPopup(
          title: 'ยกเลิกการจองห้องประชุม',
          onYes: () async {
            showDialog(
              context: mainContext,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return Center(child: CircularProgressIndicator(
                  strokeWidth: 6,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ));
              },
            );

            print('ยกเลิกการจองห้องประชุมเรียบร้อย');
            Navigator.of(dialogContext).pop();

            try {
              String response = await ReservationService().cancelReservation(reserve['reservationId']);
              Navigator.of(mainContext).pop();
              showDialog(
                context: mainContext,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('แจ้งเตือน', style: TextStyle(
                        fontFamily: "Mitr",
                        fontWeight: FontWeight.w600,
                        fontSize: 30
                    ),),
                    content: Text(response, style: TextStyle(
                        fontFamily: "Mitr",
                        fontSize: 20,
                        color: Colors.black
                    ),),
                    actions: [
                      TextButton(
                        child: Text('ตกลง', style: TextStyle(
                            fontFamily: "Mitr",
                            fontSize: 20,
                            color: Colors.green
                        ),),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(mainContext).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            } catch (e) {
              Navigator.of(mainContext).pop();
              showDialog(
                context: mainContext,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('ข้อผิดพลาด'),
                    content: Text('การยกเลิกการจองไม่สำเร็จ'),
                    actions: <Widget>[
                      TextButton(
                        child: Text('ปิด'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            }
          },
          onNo: () {
            print('คำจองถูกยกเลิก');
            Navigator.of(dialogContext).pop();
          },
        );
      },
    );
  }
}
