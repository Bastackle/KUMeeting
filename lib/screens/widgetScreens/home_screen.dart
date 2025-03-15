import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:project/services/room_service.dart';
import '../dtlScreens/roomDtl.dart';

class HomeScreen extends StatelessWidget {
  final RoomService _roomService = RoomService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).secondaryHeaderColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 5,
              ),
              Container(
                height: 50,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blueGrey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(FluentIcons.calendar_add_16_filled, color: Colors.white),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'ระบบจองห้องประชุมมหาวิทยาลัยเกษตรศาสตร์',
                        style: TextStyle(
                          fontFamily: 'Mitr',
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
              Text(
                'ภาพห้องประชุม',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontFamily: "Mitr",
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 36,
                    ),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                'ตัวอย่างภาพห้องประชุมที่เปิดให้บริการ',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontFamily: "Mitr",
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
              ),
              SizedBox(height: 10),
              StreamBuilder(
                  stream: _roomService.getRooms(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator(
                        strokeWidth: 6,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(child: Text('No rooms available'));
                    }

                    final rooms = snapshot.data!.docs;
                    final selectedRooms = _roomService.getRandomRooms(rooms, 5);

                    return Column(
                      children: [
                        Container(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: selectedRooms.length,
                            itemBuilder: (context, index) {
                              final room = selectedRooms[index].data()
                                  as Map<String, dynamic>;
                              return Padding(
                                padding: const EdgeInsets.only(right: 15),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.network(
                                    room['roomImage'] ?? '',
                                    height: 200,
                                    width: 350,
                                    fit: BoxFit.fill,
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
                                            FluentIcons.image_off_20_filled,
                                            size: 150,
                                            color: Colors.grey),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }),
              SizedBox(height: 30),
              Text(
                'ROOMS',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontFamily: "Mitr",
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 36,
                    ),
              ),
              Text(
                'ห้องประชุมที่เปิดให้บริการ',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontFamily: "Mitr",
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
              ),
              SizedBox(height: 10),
              StreamBuilder(
                stream: _roomService.getRooms(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(
                      strokeWidth: 6,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ));
                  }
                  final rooms = snapshot.data?.docs;

                  if (rooms == null || rooms.isEmpty) {
                    return Center(child: Text('No rooms available'));
                  }

                  final selectedRooms = _roomService.getRandomRooms(rooms, 5);

                  return FutureBuilder(
                      future: Future.wait(
                          selectedRooms.map((room) => _roomService.getBuildingById(room['buildingId']))),
                      builder: (context, buildingSnapshot) {
                        if (buildingSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: Container(
                              child: Padding(
                                padding: EdgeInsets.all(15),
                                child: CircularProgressIndicator(
                                  strokeWidth: 6,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              ),
                            ),
                          );
                        }
                        final buildingDocs = buildingSnapshot.data;
                        return ListView.builder(
                            itemCount: selectedRooms.length,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final room = selectedRooms[index];
                              final buildingData = buildingDocs?[index];

                              if (buildingData == null) {
                                return Center(
                                    child: Text('Building not found'));
                              }

                              return GestureDetector(
                                onTap: () {
                                  String roomId = selectedRooms[index].id;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BookingScreen(
                                        room: room,
                                        building: buildingData,
                                      ),
                                    ),
                                  );
                                },
                                child: Card(
                                  margin: EdgeInsets.symmetric(vertical: 8),
                                  elevation: 10,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Container(
                                      padding: EdgeInsets.all(12),
                                      height: 180,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image:
                                              NetworkImage(room['roomImage']),
                                          fit: BoxFit.cover,
                                          colorFilter: ColorFilter.mode(
                                            Colors.black.withOpacity(0.5),
                                            BlendMode.darken,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: <Widget>[
                                          CircleAvatar(
                                            backgroundColor: Colors.grey[500],
                                            child: Icon(FluentIcons.conference_room_28_filled,
                                                color: Colors.white, size: 35),
                                            radius: 40,
                                          ),
                                          SizedBox(width: 15),
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  room['roomName'],
                                                  style: TextStyle(
                                                    fontFamily: "Mitr",
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                                Text(
                                                  buildingData['buildingName'],
                                                  style: TextStyle(
                                                    fontFamily: "Mitr",
                                                    color: Colors.white70,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                                Text(
                                                  'ขนาด: ${room['capacity']}',
                                                  style: TextStyle(
                                                    fontFamily: "Mitr",
                                                    color: Colors.white70,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(Icons.arrow_forward_ios,
                                              color: Colors.white),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            });
                      });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
