import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late GoogleMapController mapController;
  Set<Marker> markers = Set();
  final LatLng _center = const LatLng(37.420567772796204, -122.0780600979924);
  TextEditingController searchController = TextEditingController();
  _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }
  void _addMarker(LatLng latLng) {
    setState(() {
      markers.add(
        Marker(
          markerId: MarkerId('${latLng.latitude}_${latLng.longitude}'),
          position: latLng,
          infoWindow: const InfoWindow(title: 'Tıklanan Konum'),
          onTap: (){
            _removeMarker('${latLng.latitude}_${latLng.longitude}');
          }

        ),
      );
      print(latLng.latitude);
      print(latLng.longitude);
      //sendEmail();
    });
  }
  void _removeMarker(String markerId) {
    setState(() {
      markers.removeWhere((marker) => marker.markerId.value == markerId);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 12,
              ),
              onMapCreated: _onMapCreated,
              markers: markers,
              onTap: (LatLng latlng){
                _addMarker(latlng);
              },
            ),
          ),
          ElevatedButton(onPressed: (){
            getDistance();

          }, child: Text("Hesapla"))
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _getUserLocation,
        child: Icon(Icons.location_searching),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
    );
  }
  Future<void> getDistance()async{
    bool locationPermissionGranted = await _checkLocationPermission();
    if (locationPermissionGranted) {
      // Konum izni verilmişse, konum bilgisini al
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      double anlikEnlem=position.latitude;
      double anlikBoylam=position.longitude;
      var distance =await Geolocator.distanceBetween(
        markers.last.position.latitude,
        markers.last.position.longitude,
        position.latitude,
        position.longitude,
      );
      if(distance<100)
      {
        print("hedef konumda ${distance}");

      }
      else{
        print(distance);
      }
    }
    else {
      // Konum izni yok veya reddedilmişse, izin iste
      await _requestLocationPermission();
    }
  }
  Future<void> _getUserLocation() async {
    bool locationPermissionGranted = await _checkLocationPermission();
    if (locationPermissionGranted) {
      // Konum izni verilmişse, konum bilgisini al
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      // Konum bilgisini kullan
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 15.0,
          ),
        ),
      );
    } else {
      // Konum izni yok veya reddedilmişse, izin iste
      await _requestLocationPermission();
    }
  }

  Future<bool> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Kullanıcı izni reddetti, bu durumu işleyebilirsiniz.
      print('Kullanıcı konum iznini reddetti.');
    } else if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      // Kullanıcı izni kabul etti, konum bilgisini alabilirsiniz.
      await _getUserLocation();
    }
  }
}