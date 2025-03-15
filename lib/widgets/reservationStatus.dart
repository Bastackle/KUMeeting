import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:project/services/reservation_service.dart';

class BookingStatusPopup extends StatefulWidget {
  final String roomId;
  const BookingStatusPopup({super.key, required this.roomId});

  @override
  State<BookingStatusPopup> createState() => _BookingStatusPopupState();
}

class _BookingStatusPopupState extends State<BookingStatusPopup> {
  List<Map<String, dynamic>> reserveList = [];
  bool isLoading = true;

  Future<void> _fetchBookingData() async {
    setState(() {
      isLoading = true;
    });
    List<Map<String, dynamic>> data =
    await ReservationService().getReserveList(roomId: widget.roomId);

    List<Map<String, dynamic>> filteredData = data.where((booking) {
      return booking['status'] == 'กำลังใช้งาน' || booking['status'] == 'รอการใช้งาน';
    }).toList();

    setState(() {
      if(reserveList!=data){
        isLoading = false;
        reserveList = filteredData;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchBookingData();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'สถานะการจองห้อง',
        style: TextStyle(fontFamily: "Mitr", fontSize: 20, fontWeight: FontWeight.w500),
        textAlign: TextAlign.center,
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: isLoading
            ? Center(child: CircularProgressIndicator(
                strokeWidth: 6,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ))
            : reserveList.isEmpty
              ? Center(
                child: Text(
                  "ไม่มีรายการจอง",
                  style: TextStyle(
                    fontFamily: "Mitr",
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              )
              : SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      horizontalMargin: 10,
                      columnSpacing: 20.0,

                      columns: const [
                        DataColumn(label: Text('Date', style: TextStyle(
                          fontFamily: "Mitr",
                        ),)),
                        DataColumn(label: Text('Use Time', style: TextStyle(
                          fontFamily: "Mitr"
                        ),)),
                        DataColumn(label: Text('Status', style: TextStyle(
                          fontFamily: "Mitr"
                        ),)),
                      ],
                      rows: reserveList.map((booking) {
                        bool isUsed = booking['status'] == 'กำลังใช้งาน';
                        return DataRow(cells: [
                          DataCell(
                            Text(
                              "${booking['date']}",
                              style: TextStyle(
                                fontFamily: "Mitr",
                                color: Colors.black,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              "${booking['startTime']} - ${booking['endTime']}",
                              style: TextStyle(
                                fontFamily: "Mitr",
                                color: Colors.black,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          DataCell(Container(
                            child: Row(
                              children: [
                                Icon(
                                  FluentIcons.circle_12_filled,
                                  size: 10,
                                  color: isUsed ? Colors.green : Colors.orangeAccent,
                                ),
                                SizedBox(
                                  width: 2,
                                ),
                                Text(
                                  "${booking['status']}",
                                  style: TextStyle(
                                    fontFamily: "Mitr",
                                    color: isUsed ? Colors.green : Colors.orangeAccent,
                                    fontSize: 13,
                                  ),
                                )
                              ],
                            ),
                          )),
                        ]);
                      }).toList(),
                    ),
                  ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('ปิด', style: TextStyle(
            fontFamily: "Mitr",
            color: Colors.black
          ),),
        ),
        ElevatedButton.icon(
          onPressed: _fetchBookingData,
          icon: Icon(FluentIcons.arrow_counterclockwise_12_regular, color: Colors.white,),
          label: Text('รีเฟรช', style: TextStyle(
            fontFamily: "Mitr",
            color: Colors.white,
          ),),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
        ),
      ],
    );
  }
}
