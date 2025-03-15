import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:project/screens/bookingScreens/StaffBookingForm.dart';
import 'package:project/screens/bookingScreens/StudentBookingForm.dart';
import 'package:project/screens/bookingScreens/stdOrganiztionBookingForm.dart';
import 'package:project/screens/dtlScreens/map_screen.dart';
import 'package:project/services/user_service.dart';
import 'package:project/widgets/reservationStatus.dart';

class BookingScreen extends StatefulWidget {
  final room;
  final building;
  BookingScreen({required this.room, required this.building});
  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  String? docId;
  Map<String, dynamic> userDetail = {};
  String _bookingType = '';

  Future<void> _fetchdata() async {
    if (user == null) return;

    UserService().getUserData(user!.email!).listen((snapshot) {
      if (snapshot != null) {
        setState(() {
          docId = snapshot.id;
          userDetail = snapshot.data() as Map<String, dynamic>;
          _bookingType = userDetail['role'];
        });
      }
    });
  }

  Future<void> _showBookingTypeDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Text(
              "เลือกประเภทการจอง",
              style: TextStyle(
                fontFamily: "Mitr",
                fontSize: 25,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          content: Container(
            width: 450,
            height: 450,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _bookingType = 'นิสิต';
                    });
                    Navigator.of(context).pop();
                    _goToBookingForm();
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Card(
                        shape: CircleBorder(),
                        elevation: 8,
                        child: Container(
                          padding: EdgeInsets.all(16),
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: AssetImage(
                                'assets/images/student.png',
                              ),
                              fit: BoxFit.cover
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                          height: 10),
                      Text(
                        "นิสิตทั่วไป",
                        style: TextStyle(
                          fontFamily: "Mitr",
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                          fontSize: 25,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _bookingType = 'องค์กรนิสิต';
                    });
                    Navigator.of(context).pop();
                    _goToBookingForm();
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Card(
                        shape: CircleBorder(),
                        elevation: 8,
                        child: Container(
                          padding: EdgeInsets.all(16),
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape
                                .circle,
                            image: DecorationImage(
                              image: AssetImage('assets/images/stdOrganization.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                          height: 10),
                      Text(
                        "องค์กรนิสิต",
                        style: TextStyle(
                          fontFamily: "Mitr",
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                          fontSize: 25,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _goToBookingForm() {
    if (_bookingType == 'บุคลากร') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StaffBookingForm(
            room: widget.room,
            building: widget.building,
            userId: docId,
          ),
        ),
      );
    } else if (_bookingType == 'นิสิต') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StudentBookingForm(
            room: widget.room,
            building: widget.building,
            userId: docId,
          ),
        ),
      );
    } else if (_bookingType == 'องค์กรนิสิต') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StdOrganiztionBookingForm(
            room: widget.room,
            building: widget.building,
            userId: docId,
          ),
        ),
      );
    }
  }

  void _showStatusPopUp() {
    showDialog(
        context: context,
        builder: (context) => BookingStatusPopup(roomId: widget.room.id));
  }

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    _fetchdata();
  }

  @override
  Widget build(BuildContext context) {
    final room = widget.room;
    final building = widget.building;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(55),
        child: AppBar(
          title: Text(
            "Room Information",
            style: TextStyle(
              fontFamily: "Mitr",
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontSize: 25,
            ),
          ),
          backgroundColor: Theme.of(context).secondaryHeaderColor,
          elevation: 4,
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Theme.of(context).secondaryHeaderColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        room['roomImage'],
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'รายละเอียดห้องประชุม:',
                      style: TextStyle(
                        fontFamily: "Mitr",
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16),
                    Table(
                      border:
                          TableBorder.all(color: Colors.grey[700]!, width: 1),
                      columnWidths: const {
                        0: FixedColumnWidth(125),
                        1: FlexColumnWidth(),
                      },
                      children: [
                        TableRow(
                          decoration: BoxDecoration(color: Colors.grey[800]),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'ชื่อห้อง:',
                                style: TextStyle(
                                    fontFamily: "Mitr",
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    color: Colors.white),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                room['roomName'],
                                style: TextStyle(
                                    fontFamily: "Mitr",
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    color: Colors.grey[300]),
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          decoration: BoxDecoration(color: Colors.grey[850]),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'อาคาร:',
                                style: TextStyle(
                                    fontFamily: "Mitr",
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    color: Colors.white),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                building['buildingName'],
                                style: TextStyle(
                                    fontFamily: "Mitr",
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    color: Colors.grey[300]),
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          decoration: BoxDecoration(color: Colors.grey[800]),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'ขนาด:',
                                style: TextStyle(
                                    fontFamily: "Mitr",
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    color: Colors.white),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '${room['capacity']} คน',
                                style: TextStyle(
                                    fontFamily: "Mitr",
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    color: Colors.grey[300]),
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          decoration: BoxDecoration(color: Colors.grey[850]),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'อุปกรณ์:',
                                style: TextStyle(
                                    fontFamily: "Mitr",
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    color: Colors.white),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                room['amenities'].join(', '),
                                style: TextStyle(
                                    fontFamily: "Mitr",
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    color: Colors.grey[300]),
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          decoration: BoxDecoration(color: Colors.grey[800]),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'สถานะ:',
                                style: TextStyle(
                                    fontFamily: "Mitr",
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    color: Colors.white),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: room['availability']
                                  ? Text(
                                      'พร้อมใช้งาน',
                                      style: TextStyle(
                                          fontFamily: "Mitr",
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                          color: Colors.white),
                                    )
                                  : Text(
                                      'ไม่พร้อมใช้งาน',
                                      style: TextStyle(
                                          fontFamily: "Mitr",
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                          color: Colors.white),
                                    ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: room['availability']
                              ? () {
                                  print(widget.room.id);
                                  _showStatusPopUp();
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: room['availability']
                                ? Colors.blueGrey[700]
                                : Colors.blueGrey.shade200,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 14),
                            disabledBackgroundColor: Colors.blueGrey.shade200,
                            disabledForegroundColor: Colors.white70,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                FluentIcons.info_24_filled,
                                color: Colors.white,
                                size: 30,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'สถานะการจอง',
                                style: TextStyle(
                                  fontFamily: "Mitr",
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 10,),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => BuildingMap(
                                    buildingName: building['buildingName'],
                                    buildingLocation: building['location']
                                ))
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                FluentIcons.map_16_filled,
                                size: 30,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'แสดงแผนที่',
                                style: TextStyle(
                                  fontFamily: "Mitr",
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: room['availability']
                          ? () {
                              if (_bookingType == 'บุคลากร') {
                                _goToBookingForm();
                              } else {
                                _showBookingTypeDialog();
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: room['availability']
                            ? Theme.of(context).primaryColor
                            : Colors.green.shade200,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14),
                        disabledBackgroundColor: Colors
                            .green.shade200,
                        disabledForegroundColor:
                            Colors.white70,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            FluentIcons.add_16_filled,
                            size: 30,
                            color: Colors.white,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'เริ่มทำการจอง',
                            style: TextStyle(
                                fontFamily: "Mitr",
                                fontWeight: FontWeight.w500,
                                fontSize: 20,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
