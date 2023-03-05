import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

//AIzaSyAhHlIUqk4UIRB1WYz0qXbTpadHtxZLgZI

class HomeScreen extends StatefulWidget {
  static const String routeName = 'home screen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentLocation();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    streamSubscription!.cancel();
  }

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  Set<Marker> markers = {};
  int counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gps'),
      ),
      body: GoogleMap(
          onLongPress: (argument) {
            Marker marker = Marker(
                markerId: MarkerId('Marker$counter'), position: argument);
            markers.add(marker);
            setState(() {
              counter++;
            });
          },
          markers: markers,
          mapType: MapType.hybrid,
          initialCameraPosition:
              myCurrentLocation == null ? _kGooglePlex : myCurrentLocation!,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToMyCurrentLocation,
        label: const Text('My Location!'),
        icon: const Icon(Icons.location_history),
      ),
    );
  }

  Location location = Location();

  PermissionStatus? permissionStatus;

  bool serviceEnable = false;

  LocationData? locationData;

  CameraPosition? myCurrentLocation;

  StreamSubscription<LocationData>? streamSubscription;

  void getCurrentLocation() async {
    var permission = isPermissionGranted();
    if (permission == false) return;

    var service = isServiceEnable();
    if (service == false) return;

    locationData = await location.getLocation();
    location.changeSettings(accuracy: LocationAccuracy.powerSave);
    streamSubscription = location.onLocationChanged.listen((event) {
      locationData = event;
      print('lat:${locationData?.latitude},long:${locationData?.longitude}');
      updateLocation();
    });
    myCurrentLocation = CameraPosition(
        bearing: 60.8334901395799,
        target: LatLng(locationData!.latitude!, locationData!.longitude!),
        tilt: 20.440717697143555,
        zoom: 19.151926040649414);
    updateLocation();
  }

  void updateLocation() async {
    Marker userLocation = Marker(
        markerId: MarkerId('User Location'),
        position: LatLng(locationData!.latitude!, locationData!.longitude!));
    markers.add(userLocation);

    final GoogleMapController controller = await _controller.future;
    controller
        .animateCamera(CameraUpdate.newCameraPosition(myCurrentLocation!));
    setState(() {});
  }

  Future<bool> isServiceEnable() async {
    serviceEnable = await location.serviceEnabled();
    if (serviceEnable == false) {
      serviceEnable = await location.requestService();
      return serviceEnable;
    }
    return serviceEnable;
  }

  Future<bool> isPermissionGranted() async {
    permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
      return permissionStatus == PermissionStatus.granted;
    } else {
      return permissionStatus == PermissionStatus.granted;
    }
  }

  Future<void> _goToMyCurrentLocation() async {
    final GoogleMapController controller = await _controller.future;
    controller
        .animateCamera(CameraUpdate.newCameraPosition(myCurrentLocation!));
  }
}
