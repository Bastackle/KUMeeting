import 'package:cloud_firestore/cloud_firestore.dart';
class ReservationService{
  final CollectionReference reservationsReference = FirebaseFirestore.instance.collection('reservations');
  final CollectionReference roomsReference = FirebaseFirestore.instance.collection('meetingRooms');
  final CollectionReference buildingsReference = FirebaseFirestore.instance.collection('buildings');

  Future<List<Map<String, dynamic>>> getReserveList({String? uid, String? roomId}) async {
    if((uid == null && roomId == null) || (uid != null && roomId != null)) {
      print('Error: ต้องระบุ userId หรือ roomId อย่างใดอย่างหนึ่งเท่านั้น');
      return [];
    }

    List<Map<String, dynamic>> reserveList = [];
    try {
      Query query = reservationsReference;

      if(uid != null) {
        query = query.where('userId', isEqualTo: uid);
      } else if (roomId != null) {
        query = query.where('roomId', isEqualTo: roomId);
      }

      QuerySnapshot reservationSnapshot = await query.get();

      for(var doc in reservationSnapshot.docs){
        Map<String, dynamic> reservation = await getReservationDtl(doc);
        reserveList.add(reservation);
      }

      DateTime now = DateTime.now();

      reserveList.sort((a , b){
        DateTime dateTimeA = _parseTime(a["date"], a["startTime"]);
        DateTime dateTimeB = _parseTime(b["date"], b["startTime"]);

        String statusA = a['status'];
        String statusB = b['status'];

        int getPriority(String status, DateTime datetime){
          if(status == 'กำลังใช้งาน') return 1;
          if(status == 'รอการใช้งาน') return 2;
          if(status == 'ใช้งานแล้ว') return 3;
          if(status == 'ยกเลิกแล้ว') return 4;
          return 99;
        }

        int priorityA = getPriority(statusA, dateTimeA);
        int priorityB = getPriority(statusB, dateTimeB);

        if(priorityA != priorityB) return priorityA.compareTo(priorityB);

        print('กำลังส่งข้อมูลไป');
        return dateTimeA.compareTo(dateTimeB);
      });
      return reserveList;
    } catch (e) {
      print("Error fetching user reservations: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>?>? getReserveById(String reservationId) async {
    try {
      DocumentSnapshot doc = await reservationsReference.doc(reservationId).get();
      if(!doc.exists) return null;
      return await getReservationDtl(doc);
    } catch (e) {
      print('เกิดข้อผิดพลาดในการดึงข้อมูลการจอง: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> getReservationDtl(DocumentSnapshot doc) async {
    Map<String, dynamic> reservationData = doc.data() as Map<String, dynamic>;
    String roomId = reservationData['roomId'];
    DocumentSnapshot roomSnapshot = await roomsReference.doc(roomId).get();

    String roomName = '';
    String roomImage = '';
    String buildingName = '';
    GeoPoint? buildingLocation;

    if(roomSnapshot.exists) {
      Map<String, dynamic> roomData = roomSnapshot.data() as Map<String, dynamic>;
      roomName = roomData['roomName'] ?? 'ไม่ทราบชื่อห้อง';
      roomImage = roomData['roomImage'] ?? '';
      String buildingId = roomData['buildingId'];

      DocumentSnapshot buildingSnapshot = await buildingsReference.doc(buildingId).get();

      if(buildingSnapshot.exists) {
        Map<String, dynamic> buildingData = buildingSnapshot.data() as Map<String, dynamic>;
        buildingName = buildingData['buildingName'] ?? 'ไม่พบชื่ออาคาร';
        buildingLocation = buildingData['location'];
      }
    }

    return {
      'reservationId': doc.id,
      'roomId': roomId,
      'roomName': roomName,
      'roomImage': roomImage,
      'buildingName': buildingName,
      'location': buildingLocation,
      'date': reservationData['date'],
      'startTime': reservationData['startTime'],
      'endTime': reservationData['endTime'],
      'people': reservationData['people'],
      'status': reservationData['status'],
    };
  }

  Future<String> postReserve(Map<String, dynamic> reservationData) async{
    try {
      String roomId = reservationData['roomId'];
      String date = reservationData['date'];
      String startTime = reservationData['startTime'];
      String endTime = reservationData['endTime'];
      print('$startTime $endTime');

      bool isExist = await _checkForTimeConflict(roomId, date, startTime, endTime);
      print(isExist);

      if(isExist) {
        return 'ขออภัยครับ กำหนดการดังกล่าวถูกดำเนินการจองไว้แล้ว';
      } else {
        DocumentReference newReservation = await reservationsReference.add(reservationData);
        return newReservation.id;
      }

    } catch (e) {
      return 'Error creating new reservation: $e';
    }
  }

  Future<String> cancelReservation(String reservationId) async {
    try {
      await reservationsReference.doc(reservationId).update({
        'status': 'ยกเลิกแล้ว'
      });
      return 'ยกเลิกการจองสำเร็จ';
    } catch (e) {
      print('เกิดข้อผิดพลาด: $e');
      return 'เกิดข้อผิดพลาดในการยกเลิกการจอง';
    }
  }

  Future<bool> _checkForTimeConflict(String roomId, String date, String startTime, String endTime) async {
    bool isExist = false;
    try {
      DateTime postStart = _parseTime(date, startTime);
      DateTime postEnd = _parseTime(date, endTime);

      QuerySnapshot snapshot = await reservationsReference
          .where('roomId', isEqualTo: roomId)
          .where('date', isEqualTo: date)
          .where('status', isNotEqualTo: "ยกเลิกแล้ว")
          .get();

      print("พบรายการจองที่มีอยู่แล้ว: ${snapshot.docs.length} รายการ");

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        DateTime existingStart = _parseTime(date, data['startTime']);
        DateTime existingEnd = _parseTime(date, data['endTime']);

        print('$postStart $postEnd $existingStart $existingEnd');

        if (postStart.isBefore(existingEnd) && postEnd.isAfter(existingStart)) {
          isExist = true;
          break;
        }
      }
    } catch (e) {
      print("Error checking for time conflict: $e");
    }
    return isExist;
  }
  DateTime _parseTime(String date, String time) {
    List<String> dateParts = date.split('/');
    int day = int.parse(dateParts[0]);
    int month = int.parse(dateParts[1]);
    int year = int.parse(dateParts[2]);

    List<String> timeParts = time.split(':');
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);

    DateTime dateTime = DateTime(year, month, day, hour, minute);
    return dateTime;
  }
}