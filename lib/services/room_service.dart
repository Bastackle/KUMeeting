import 'package:cloud_firestore/cloud_firestore.dart';

class RoomService {
  final CollectionReference roomsCollection = FirebaseFirestore.instance.collection('meetingRooms');
  final CollectionReference buildingCollection = FirebaseFirestore.instance.collection('buildings');

  Stream<QuerySnapshot> getRooms() {
    return roomsCollection.snapshots();
  }

  List<QueryDocumentSnapshot> getRandomRooms(List<QueryDocumentSnapshot> rooms, int count) {
    final shuffledRooms = List<QueryDocumentSnapshot>.from(rooms)..shuffle();
    return shuffledRooms.take(count).toList();
  }

  Stream<QuerySnapshot> getBuildings() {
    return buildingCollection.snapshots();
  }

  Future<DocumentSnapshot> getBuildingById(String buildingId) {
    return buildingCollection.doc(buildingId).get();
  }
}
