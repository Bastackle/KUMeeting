import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BuildingMap extends StatefulWidget {
  String buildingName;
  GeoPoint buildingLocation;
  BuildingMap(
      {super.key, required this.buildingName, required this.buildingLocation});

  @override
  State<BuildingMap> createState() => _BuildingMapState();
}

class _BuildingMapState extends State<BuildingMap> {
  late LatLng latLngBuilding;
  String googleApiKey = "AIzaSyCJWcPP4y9BsatfQDHFTGxjtovqxHhP7Ls";
  GoogleMapController? mapController;
  double? latitude, longitude;
  final Set<Marker> markers = {};
  String mapTheme = '''
  [
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#242f3e"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#746855"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#242f3e"
      }
    ]
  },
  {
    "featureType": "administrative.locality",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#263c3f"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#6b9a76"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#38414e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#212a37"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9ca5b3"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#746855"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#1f2835"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#f3d19c"
      }
    ]
  },
  {
    "featureType": "transit",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#2f3948"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#17263c"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#515c6d"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#17263c"
      }
    ]
  }
]
  ''';
  @override
  void initState() {
    super.initState();
    latLngBuilding = LatLng(
        widget.buildingLocation.latitude, widget.buildingLocation.longitude);
    markers.add(Marker(
        markerId: const MarkerId('id'),
        position: latLngBuilding,
        infoWindow: InfoWindow(title: widget.buildingName),
        icon: BitmapDescriptor.defaultMarker));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).secondaryHeaderColor,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: AppBar(
            title: Text(
              widget.buildingName,
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
        body: Container(
          child: GoogleMap(
            zoomControlsEnabled: true,
            initialCameraPosition: CameraPosition(
              target: latLngBuilding,
              zoom: 18.25,
            ),
            markers: markers,
            mapType: MapType.normal,
            onMapCreated: (controller) {
              setState(() {
                mapController = controller;
                mapController?.setMapStyle(mapTheme);
              });
            },
            onTap: (LatLng latlng) {
              markers.clear();

              latitude = latlng.latitude;
              longitude = latlng.longitude;

              print('${latitude.toString()} ${longitude.toString()}');

              setState(() {
                markers.add(Marker(
                    markerId: const MarkerId('id'),
                    position: LatLng(latitude!, longitude!),
                    infoWindow: const InfoWindow(title: 'อื่นๆ'),
                    icon: BitmapDescriptor.defaultMarker));
              });
            },
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
              new Factory<OneSequenceGestureRecognizer>(
                () => new EagerGestureRecognizer(),
              )
            ].toSet(),
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 50, 50),
          child: FloatingActionButton.extended(
            label: Text(
              'Reset',
              style: TextStyle(
                  fontFamily: "Mitr", fontSize: 15, color: Colors.white),
            ),
            onPressed: () {
              LatLng newLatLng = latLngBuilding;
              mapController?.animateCamera(CameraUpdate.newCameraPosition(
                  CameraPosition(target: newLatLng, zoom: 18.25)));
              setState(() {
                markers.clear();
                markers.add(Marker(
                    markerId: const MarkerId('id'),
                    position: newLatLng,
                    infoWindow: InfoWindow(title: widget.buildingName),
                    icon: BitmapDescriptor.defaultMarker));
              });
            },
            backgroundColor: Theme.of(context).primaryColor,
          ),
        ));
  }
}
