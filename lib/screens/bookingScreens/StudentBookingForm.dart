import 'package:flutter/material.dart';
import 'package:project/screens/dtlScreens/reservationDtl.dart';
import 'package:project/services/reservation_service.dart';
import 'package:project/widgets/alert.dart';
import 'package:project/widgets/agreement.dart';
import 'package:project/widgets/confirm.dart';
import 'package:project/widgets/successful.dart';

class StudentBookingForm extends StatefulWidget {
  final room;
  final building;
  final userId;

  StudentBookingForm(
      {required this.room, required this.building, required this.userId});

  @override
  _StudentBookingFormState createState() => _StudentBookingFormState();
}

class _StudentBookingFormState extends State<StudentBookingForm> {
  String status = 'รอการใช้งาน';
  final _formKey = GlobalKey<FormState>();
  TextEditingController _startTimeController = TextEditingController();
  TextEditingController _endTimeController = TextEditingController();
  TextEditingController _DateController = TextEditingController();
  TextEditingController _peopleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showBookingPopup();
    });
  }

  // ฟังก์ชันที่แสดง popup
  void _showBookingPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BookingPopup(
          onClose: () {
            setState(() {});
          },
        );
      },
    );
  }

  void _showConfirmPopup() {
    showDialog(
      context: context,
      builder: (BuildContext _context) {
        return ConfirmPopup(
            title: 'ยืนยันการจอง',
            onYes: () async {
              Navigator.of(context).pop();

              Map<String, dynamic> data = toBody();

              final startTime = _parseTimeOfDay(data['startTime']);
              final endTime = _parseTimeOfDay(data['endTime']);

              if (_isValidEndTime(startTime!, endTime!)) {
                showDialog(
                    context: context,
                    builder: (context) {
                      return Center(
                          child: CircularProgressIndicator(
                        strokeWidth: 6,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ));
                    });

                String response = await ReservationService().postReserve(data);

                Navigator.of(context).pop();

                if (response ==
                    'ขออภัยครับ กำหนดการดังกล่าวถูกดำเนินการจองไว้แล้ว') {
                  AlertBox.showErrorDialog(context, response);
                } else {
                  Map<String, dynamic>? reserveData =
                      await ReservationService().getReserveById(response);
                  showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return SuccessfulPopup(
                            nextPage: reservationDtl(
                          reserve: reserveData,
                        ));
                      });
                }
              } else {
                AlertBox.showErrorDialog(context, 'เวลาในการจองอย่างน้อย 1 ชั่วโมง และไม่เกิน 2 ชั่วโมง');
              }
            },
            onNo: () {
              print('คำจองถูกยกเลิก');
              Navigator.of(context).pop();
            });
      },
    );
  }

  Map<String, dynamic> toBody() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['roomId'] = widget.room.id;
    data['userId'] = widget.userId;
    data['date'] = _DateController.text;
    data['startTime'] = _startTimeController.text;
    data['endTime'] = _endTimeController.text;
    data['people'] = _peopleController.text;
    data['status'] = status;
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).secondaryHeaderColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(55),
        child: AppBar(
          title: Text(
            "Reservation Form",
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Image.network(
                widget.room['roomImage'],
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      initialValue: widget.room['roomName'],
                      readOnly: true,
                      style: TextStyle(
                        fontFamily: "Mitr",
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        fillColor: Colors.white.withOpacity(0.1),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: Theme.of(context)
                                  .primaryColor),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    TextFormField(
                      controller: _DateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: 'วันที่ใช้งาน',
                        hintStyle: TextStyle(
                          fontFamily: "Mitr",
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                        ),
                        errorStyle:
                            TextStyle(fontFamily: "Mitr", color: Colors.white),
                        suffixIcon: Icon(
                          Icons.calendar_today,
                          color: Colors.grey,
                        ),
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        fillColor: Colors.white.withOpacity(0.1),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: Theme.of(context)
                                  .primaryColor),
                        ),
                      ),
                      style: TextStyle(
                        fontFamily: "Mitr",
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      onTap: () async {
                        DateTime now = DateTime.now();
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: now.add(Duration(days: 1)),
                          firstDate: now.add(Duration(days: 1)),
                          lastDate: DateTime(now.year + 1),
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.light().copyWith(
                                primaryColor: Theme.of(context).primaryColor,
                                hintColor: Theme.of(context).primaryColor,
                                colorScheme: ColorScheme.light(primary: Theme.of(context).primaryColor),
                                buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (pickedDate != null) {
                          _DateController.text =
                              "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                        }
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'กรุณากรอกวันที่ใช้งาน';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _startTimeController,
                            readOnly: true,
                            decoration: InputDecoration(
                              hintText: 'เวลาเริ่มต้น',
                              hintStyle: TextStyle(
                                fontFamily: "Mitr",
                                fontWeight: FontWeight.w500,
                                color: Colors.white70,
                              ),
                              errorStyle: TextStyle(
                                  fontFamily: "Mitr", color: Colors.white),
                              suffixIcon: Icon(
                                Icons.access_time,
                                color: Colors.grey,
                              ),
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              fillColor: Colors.white.withOpacity(0.1),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .primaryColor),
                              ),
                            ),
                            style: TextStyle(
                              fontFamily: "Mitr",
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                            onTap: () async {
                              TimeOfDay? pickedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                                builder: (BuildContext context, Widget? child) {
                                  return Theme(
                                    data: ThemeData.light().copyWith(
                                      primaryColor: Theme.of(context).primaryColor,
                                      colorScheme: ColorScheme.light(primary: Theme.of(context).primaryColor),
                                      buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
                                      textButtonTheme: TextButtonThemeData(
                                        style: TextButton.styleFrom(
                                          foregroundColor: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ),
                                    child: MediaQuery(
                                      data: MediaQuery.of(context)
                                          .copyWith(alwaysUse24HourFormat: true),
                                      child: child!,
                                    ),
                                  );
                                },
                              );
                              if (pickedTime != null) {
                                if (!_isWithinBusinessHours(pickedTime)) {
                                  AlertBox.showErrorDialog(context, 'กรุณาเลือกเวลาในช่วง 9:00 - 18:00 น.');
                                } else {
                                  _startTimeController.text =
                                      MaterialLocalizations.of(context)
                                          .formatTimeOfDay(pickedTime,
                                              alwaysUse24HourFormat: true);
                                }
                              }
                            },
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'กรุณากรอกเวลาที่เริ่มต้น';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _endTimeController,
                            readOnly: true,
                            decoration: InputDecoration(
                              hintText: 'เวลาสิ้นสุด',
                              hintStyle: TextStyle(
                                fontFamily: "Mitr",
                                fontWeight: FontWeight.w500,
                                color: Colors.white70,
                              ),
                              errorStyle: TextStyle(
                                  fontFamily: "Mitr", color: Colors.white),
                              suffixIcon: Icon(
                                Icons.access_time,
                                color: Colors.grey,
                              ),
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              fillColor: Colors.white.withOpacity(0.1),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .primaryColor),
                              ),
                            ),
                            style: TextStyle(
                              fontFamily: "Mitr",
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                            onTap: () async {
                              if (_startTimeController.text.isEmpty) {
                                AlertBox.showErrorDialog(context, 'กรุณาเลือกเวลาเริ่มต้นก่อน');
                              } else {
                                TimeOfDay? pickedTime = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                  builder:
                                      (BuildContext context, Widget? child) {
                                    return Theme(
                                      data: ThemeData.light().copyWith(
                                        primaryColor: Theme.of(context).primaryColor,
                                        colorScheme: ColorScheme.light(primary: Theme.of(context).primaryColor),
                                        buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
                                        textButtonTheme: TextButtonThemeData(
                                          style: TextButton.styleFrom(
                                            foregroundColor: Theme.of(context).primaryColor,
                                          ),
                                        ),
                                      ),
                                      child: MediaQuery(
                                        data: MediaQuery.of(context).copyWith(
                                            alwaysUse24HourFormat: true),
                                        child: child!,
                                      ),
                                    );
                                  },
                                );
                                if (pickedTime != null) {
                                  if (!_isWithinBusinessHours(pickedTime)) {
                                    AlertBox.showErrorDialog(context, 'กรุณาเลือกเวลาในช่วง 9:00 - 18:00 น.');
                                  } else {
                                    final startTime = _parseTimeOfDay(
                                        _startTimeController.text);
                                    final endTime = pickedTime;

                                    if (startTime != null &&
                                        _isValidEndTime(startTime, endTime)) {
                                      _endTimeController.text =
                                          MaterialLocalizations.of(context)
                                              .formatTimeOfDay(pickedTime,
                                                  alwaysUse24HourFormat: true);
                                    } else {
                                      AlertBox.showErrorDialog(context, 'เวลาในการจองอย่างน้อย 1 ชั่วโมง และไม่เกิน 2 ชั่วโมง');
                                    }
                                  }
                                }
                              }
                            },
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'กรุณากรอกเวลาสิ้นสุด';
                              }
                              return null;
                            },
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    TextFormField(
                      controller: _peopleController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'จำนวนผู้เข้าใช้งาน (โดยประมาณ)',
                        hintStyle: TextStyle(
                          fontFamily: "Mitr",
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                        ),
                        errorStyle:
                            TextStyle(fontFamily: "Mitr", color: Colors.white),
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        fillColor: Colors.white.withOpacity(0.1),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: Colors.green),
                        ),
                      ),
                      style: TextStyle(
                        fontFamily: "Mitr",
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'กรุณากรอกจำนวนผู้เข้าใช้งาน';
                        }
                        int? people = int.tryParse(value);
                        if (people == null ||
                            people > widget.room['capacity']) {
                          return 'จำนวนผู้เข้าใช้งานต้องไม่เกิน ${widget.room['capacity']} คน';
                        } else if (people <= 0) {
                          return 'จำนวนผู้เข้าใช้งานต้องไม่ต่ำกว่า 0';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _showConfirmPopup();
                        } else {
                          print('กรุณากรอกข้อมูลให้ครบถ้วน');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        minimumSize: Size(
                            double.infinity, 60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              15),
                        ),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        "ยืนยันข้อมูลการจอง",
                        style: TextStyle(
                            fontFamily: "Mitr",
                            fontWeight: FontWeight.w500,
                            fontSize: 20,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

TimeOfDay? _parseTimeOfDay(String time) {
  try {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return TimeOfDay(hour: hour, minute: minute);
  } catch (e) {
    return null;
  }
}

bool _isWithinBusinessHours(TimeOfDay time) {
  return time.hour >= 9 &&
      (time.hour < 18 || (time.hour == 18 && time.minute == 0));
}

bool _isValidEndTime(TimeOfDay startTime, TimeOfDay endTime) {
  final startDateTime = DateTime(0, 0, 0, startTime.hour, startTime.minute);
  final endDateTime = DateTime(0, 0, 0, endTime.hour, endTime.minute);

  if (endDateTime.isBefore(startDateTime.add(Duration(hours: 1)))) {
    return false;
  }

  if (endDateTime.isAfter(startDateTime.add(Duration(hours: 2)))) {
    return false;
  }
  return true;
}
