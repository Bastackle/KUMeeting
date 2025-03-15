import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/screens/dtlScreens/roomDtl.dart';
import 'package:project/services/room_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _selectedBuilding = 'All';
  String _selectedSize = 'All';

  List<QueryDocumentSnapshot> rooms = [];
  List<QueryDocumentSnapshot> buildings = [];
  List<QueryDocumentSnapshot> filteredRooms = [];
  bool isLoading = true;

  final RoomService roomService = RoomService();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      roomService.getBuildings().listen((snapshot) {
        setState(() {
          buildings = snapshot.docs;
        });
      });

      roomService.getRooms().listen((snapshot) {
        setState(() {
          rooms = snapshot.docs;
          filteredRooms = rooms;
          isLoading = false;
        });
      });
      _filterRooms();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error Fetching Data: $e");
    }
  }

  void _filterRooms() {
    setState(() {
      filteredRooms = rooms.where((room) {
        bool matchesBuilding = _selectedBuilding == 'All' ||
            room['buildingId'] == _selectedBuilding;

        String roomSize = _getRoomSize(room['capacity']);
        bool matchesSize = _selectedSize == 'All' || roomSize == _selectedSize;

        return matchesBuilding && matchesSize;
      }).toList();
    });
  }

  String _getRoomSize(dynamic capacity) {
    int roomCapacity = int.tryParse(capacity.toString()) ?? 0;

    if (roomCapacity >= 1 && roomCapacity <= 50) return 'Small';
    if (roomCapacity >= 51 && roomCapacity <= 120) return 'Medium';
    if (roomCapacity >= 121) return 'Large';
    return 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).secondaryHeaderColor,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(10),
        child: FloatingActionButton.extended(
          onPressed: (){
            setState(() {
              _selectedBuilding = 'All';
              _selectedSize = 'All';
              _filterRooms();
            });
          },
          label: Text('Clear all', style: TextStyle(
            fontFamily: "Mitr",
            fontSize: 15,
            color: Colors.white
          ),),
          icon: Icon(FluentIcons.broom_16_filled, color: Colors.white,),
          backgroundColor: Theme.of(context).primaryColor,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
      body: isLoading
        ? Center(
        child: Container(
          child: Padding(
            padding: EdgeInsets.all(15),
            child: CircularProgressIndicator(
              strokeWidth: 6,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
        )
      : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'อาคาร: ',
                    style: TextStyle(fontFamily: "Mitr", color: Colors.white),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  DropdownButton<String>(
                    value: _selectedBuilding,
                    dropdownColor: Colors.grey[850],
                    onChanged: (newValue) {
                      setState(() {
                        _selectedBuilding = newValue!;
                        _filterRooms();
                      });
                    },
                    items: [
                      DropdownMenuItem(
                        value: 'All',
                        child: SizedBox(
                          width: 100,
                          child: Text(
                            'All',
                            style: TextStyle(
                                fontFamily: "Mitr", color: Colors.white),
                            overflow:
                                TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      ...buildings.map((building) {
                        return DropdownMenuItem<String>(
                          value: building.id,
                          child: SizedBox(
                            width: 150,
                            child: Text(
                              building['buildingName'].toString(),
                              style: TextStyle(
                                  fontFamily: "Mitr", color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                  SizedBox(width: 25),
                  Text(
                    'ขนาด: ',
                    style: TextStyle(fontFamily: "Mitr", color: Colors.white),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  DropdownButton<String>(
                    value: _selectedSize,
                    dropdownColor: Colors.grey[850],
                    onChanged: (newValue) {
                      setState(() {
                        _selectedSize = newValue!;
                        _filterRooms();
                      });
                    },
                    items: <String>['All', 'Small', 'Medium', 'Large']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(
                              fontFamily: "Mitr", color: Colors.white),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Rooms Grid
              filteredRooms.isEmpty
                  ? Center(
                      child: Text(
                        'ไม่พบห้องประชุมที่ตรงกับการค้นหา',
                        style:
                            TextStyle(fontFamily: "Mitr", color: Colors.white),
                      ),
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: filteredRooms.length,
                      itemBuilder: (context, index) {
                        final room = filteredRooms[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => BookingScreen(
                                      room: room,
                                      building: buildings.firstWhere(
                                            (building) => building.id == room['buildingId'],
                                      ),
                                    )
                                )
                            );
                          },
                          child: Card(
                            color: Colors.grey[850],
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.network(
                                  room['roomImage'],
                                  width: double.infinity,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        room['roomName'],
                                        style: TextStyle(
                                          fontFamily: "Mitr",
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        'ขนาด: ${room['capacity']} คน',
                                        style: TextStyle(
                                            fontFamily: "Mitr",
                                            color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
}
