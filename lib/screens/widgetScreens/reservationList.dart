import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:project/screens/dtlScreens/reservationDtl.dart';
import 'package:project/services/reservation_service.dart';
import 'package:project/services/user_service.dart';

class reservationList extends StatefulWidget {
  const reservationList({super.key});

  @override
  State<reservationList> createState() => _reservationListState();
}

class _reservationListState extends State<reservationList> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  Map<String, dynamic> userDetail = {};
  String? docId;

  List<Map<String, dynamic>> reserveList = [];
  bool isLoading = true;

  Future<void> _fetchData() async {
    if (user == null) return;

    UserService().getUserData(user!.email!).listen((snapshot) {
      if (snapshot != null) {
        setState(() {
          docId = snapshot.id;
          _fetchReserveList();
        });
      }
    });
  }

  Future<void> _fetchReserveList() async {
    if (docId == null) {
      setState(() {
        isLoading = false;
      });
      print("docId is null");
      return;
    }
    setState(() {
      isLoading = true;
    });
    List<Map<String, dynamic>> data =
      await ReservationService().getReserveList(uid: docId);
    setState(() {
      if (reserveList != data) {
        isLoading = false;
        reserveList = data;
        print('ได้รับแล้ว');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).secondaryHeaderColor,
      
      body: RefreshIndicator(
        onRefresh: _fetchReserveList,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'รายการจองห้องประชุม',
                    style: TextStyle(
                      fontFamily: "Mitr",
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: (){
                      _fetchReserveList();
                    },
                    child: Icon(
                      FluentIcons.arrow_sync_24_filled,
                      color: Colors.redAccent,
                      size: 25,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: Colors.redAccent,
                          width: 2
                        )
                      )
                    ),
                  )
                ],
              ),
              SizedBox(height: 20),
              isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                      strokeWidth: 6,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ))
                  : reserveList.isEmpty
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 50),
                            child: Text(
                              'ไม่มีรายการจอง',
                              style: TextStyle(
                                fontFamily: "Mitr",
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: reserveList.length,
                          itemBuilder: (context, index) {
                            var booking = reserveList[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => reservationDtl(
                                              reserve: booking,
                                            )));
                              },
                              child: Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                                color: Colors.grey[850],
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  leading: Icon(
                                    FluentIcons.conference_room_28_filled,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                  title: Text(
                                    booking['roomName']!,
                                    style: TextStyle(
                                        fontFamily: "Mitr",
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  subtitle: Text(
                                    'วันที่: ${booking['date']} \nเวลา: ${booking['startTime']} - ${booking['endTime']}',
                                    style: TextStyle(
                                        fontFamily: "Mitr",
                                        fontSize: 14,
                                        color: Color(0xFFb3b3b3)),
                                  ),
                                  trailing:
                                      _buildStatusLabel(booking['status']!),
                                ),
                              ),
                            );
                          },
                        ),
            ],
          ),
        ),
      ),
    );
  }

  // ฟังก์ชันกำหนดสีของสถานะ
  Widget _buildStatusLabel(String status) {
    Color color;
    switch (status) {
      case 'กำลังใช้งาน':
        color = Colors.green;
        break;
      case 'รอการใช้งาน':
        color = Colors.orange;
        break;
      case 'ใช้งานแล้ว':
        color = Colors.blueAccent;
        break;
      case 'ยกเลิกแล้ว':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontFamily: "Mitr",
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
