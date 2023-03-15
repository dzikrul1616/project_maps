import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:project_maps/constant/color.dart';
import 'package:project_maps/screen/add.dart';
import 'package:project_maps/screen/profil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;

const MAPBOX_ACCES_TOKEN =
    'pk.eyJ1IjoiZHppa3J1bDE2MTYiLCJhIjoiY2xleWJ6aTdlMGc0ODQxcXZsaDZlaDhwciJ9.Nz95V3UL1b8AfExigWUllA';

class MapsView extends StatefulWidget {
  const MapsView({key}) : super(key: key);

  @override
  State<MapsView> createState() => _MapsViewState();
}

class _MapsViewState extends State<MapsView> {
  late LatLng myPosition = LatLng(1.045626, 104.030453);
  final databaseReference = FirebaseDatabase.instance.reference();

  void getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition();
    myPosition = LatLng(position.latitude, position.longitude);
    final newLocationRef = databaseReference.child('locations').push();
    newLocationRef.set({
      'latitude': position.latitude,
      'longitude': position.longitude,
      'address': currentAddressFull
    });
  }

  String currentAddressFull = 'Batam, Kepulauan Riau, Indonesia';
  String currentAddress = 'Batam, Kepulauan Riau, Indonesia';
  late Position currentposition = Position(
      latitude: 0,
      longitude: 0,
      accuracy: 0,
      heading: 0,
      altitude: 0,
      speed: 0,
      speedAccuracy: 0,
      timestamp: null);

  Future<Position> _determinePosition() async {
    bool serviceEnable;
    LocationPermission permission;

    serviceEnable = await Geolocator.isLocationServiceEnabled();
    if (serviceEnable) {
      Fluttertoast.showToast(msg: 'Please keep your location');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: 'Location permission is denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(
          msg:
              'Location permission is permanently denied, we cannot request permission');
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    try {
      List<Placemark> placemark =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemark[0];

      setState(() {
        currentposition = position;
        currentAddress = "${place.locality}, ${place.country}";
        currentAddressFull =
            "${place.locality},${place.subLocality},${place.subAdministrativeArea},${place.administrativeArea},${place.country}";
      });
    } catch (e) {
      print(e);
    }
    return position;
  }

  @override
  void initState() {
    getCurrentLocation();
    _determinePosition();
    mapController = MapController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 20.0, left: 40, bottom: 80),
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 55,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    title: Text(
                      currentAddress.length > 25
                          ? currentAddress.substring(0, 25) + '...'
                          : currentAddress,
                      style: const TextStyle(fontSize: 14),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        currentposition != null
                            ? Text(
                                'latitude :' +
                                    currentposition.latitude.toString(),
                                style: const TextStyle(fontSize: 12),
                              )
                            : Text(''),
                        currentposition != null
                            ? Text(
                                'longitude :' +
                                    currentposition.longitude.toString(),
                                style: const TextStyle(fontSize: 12),
                              )
                            : Text(''),
                      ],
                    ),
                  )),
            ),
          ),
          const SizedBox(
            height: 10.0,
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 80),
            child: SpeedDial(
              direction: SpeedDialDirection.up,
              icon: Icons.menu,
              animatedIcon: AnimatedIcons.menu_close,
              backgroundColor: appPrimary,
              children: [
                SpeedDialChild(
                    child: Image.asset('assets/add.gif'),
                    label: 'Add',
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => AddMaps()));
                    }),
                SpeedDialChild(
                    child: Image.asset('assets/maps.gif'),
                    label: 'Theme Maps',
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: Container(
                              width: 250,
                              height: 400,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Selecte Theme Maps",
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 15.0,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                selectedTheme = 'outdoors-v12';
                                              });
                                            },
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  height: 95,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: Image.asset(
                                                    'assets/outdoor.png',
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 5.0,
                                                ),
                                                Text(
                                                  "Outdoors Theme",
                                                  style: TextStyle(
                                                    fontSize: 12.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 5.0,
                                        ),
                                        Expanded(
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                selectedTheme = 'dark-v11';
                                              });
                                            },
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  height: 95,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: Image.asset(
                                                    'assets/dark.png',
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 5.0,
                                                ),
                                                Text(
                                                  "Dark Theme",
                                                  style: TextStyle(
                                                    fontSize: 12.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10.0,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                selectedTheme = 'satellite-v9';
                                              });
                                            },
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  height: 95,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: Image.asset(
                                                    'assets/satelite.png',
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 5.0,
                                                ),
                                                Text(
                                                  "Satelite Theme",
                                                  style: TextStyle(
                                                    fontSize: 12.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 5.0,
                                        ),
                                        Expanded(
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                selectedTheme = 'light-v11';
                                              });
                                            },
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  height: 95,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: Image.asset(
                                                    'assets/light.png',
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 5.0,
                                                ),
                                                Text(
                                                  "Light Theme",
                                                  style: TextStyle(
                                                    fontSize: 12.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10.0,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                selectedTheme = 'streets-v12';
                                              });
                                            },
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  height: 95,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: Image.asset(
                                                    'assets/street.png',
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 5.0,
                                                ),
                                                Text(
                                                  "Street Theme",
                                                  style: TextStyle(
                                                    fontSize: 12.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 5.0,
                                        ),
                                        Expanded(
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                selectedTheme =
                                                    'navigation-day-v1';
                                              });
                                            },
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  height: 95,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: Image.asset(
                                                    'assets/day.png',
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 5.0,
                                                ),
                                                Text(
                                                  "Day Theme",
                                                  style: TextStyle(
                                                    fontSize: 12.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10.0,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                selectedTheme =
                                                    'navigation-night-v1';
                                              });
                                            },
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  height: 95,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: Image.asset(
                                                    'assets/night.png',
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 5.0,
                                                ),
                                                Text(
                                                  "Night Theme",
                                                  style: TextStyle(
                                                    fontSize: 12.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 5.0,
                                        ),
                                        Expanded(
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                selectedTheme =
                                                    'satellite-streets-v12';
                                              });
                                            },
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  height: 95,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: Image.asset(
                                                    'assets/satelite-street.png',
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 5.0,
                                                ),
                                                Text(
                                                  "Satelite Street",
                                                  style: TextStyle(
                                                    fontSize: 12.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 1,
            child: StreamBuilder(
              stream: Geolocator.getPositionStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final position = snapshot.data as Position;
                final markerPosition =
                    LatLng(position.latitude, position.longitude);
                return FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                      center: markerPosition,
                      minZoom: 10,
                      maxZoom: 18,
                      zoom: 18,
                      onTap: (as, LatLng? latlng) {
                        if (routeCoords.isNotEmpty) {
                          setState(() {
                            isRouteShown = false;
                            routeCoords.clear();
                            distance = 0.0;
                          });
                        }
                        _getRoute(markerPosition, latlng!);
                      }),
                  nonRotatedChildren: [
                    TileLayer(
                      additionalOptions: {
                        'accestoken': MAPBOX_ACCES_TOKEN,
                        'id': 'mapbox/$selectedTheme',
                      },
                      urlTemplate:
                          'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}@2x?access_token={accestoken}',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: routeCoords.isNotEmpty
                              ? routeCoords.last
                              : markerPosition,
                          builder: (context) {
                            return InkWell(
                              onLongPress: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return Dialog(
                                      child: ListView(
                                        padding: EdgeInsets.all(20),
                                        shrinkWrap: true,
                                        children: <Widget>[
                                          Text(
                                            currentAddressFull,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(
                                            height: 10.0,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text('OK'),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Container(
                                child: Icon(
                                  Icons.location_pin,
                                  color: Colors.red,
                                  size: 40,
                                ),
                              ),
                            );
                          },
                        ),
                        Marker(
                          point: markerPosition,
                          builder: (context) {
                            return InkWell(
                              onLongPress: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return Dialog(
                                      child: ListView(
                                        padding: EdgeInsets.all(20),
                                        shrinkWrap: true,
                                        children: <Widget>[
                                          Text(
                                            currentAddressFull,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(
                                            height: 10.0,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text('OK'),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Container(
                                child: Icon(
                                  Icons.location_pin,
                                  color: Colors.blue,
                                  size: 40,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: routeCoords,
                          color: Colors.red,
                          strokeWidth: 5.0,
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20, top: 40),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6.0,
                    horizontal: 12.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(12.0),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.search),
                      ),
                      Expanded(
                        child: TextFormField(
                          initialValue: null,
                          decoration: const InputDecoration.collapsed(
                            filled: true,
                            fillColor: Colors.transparent,
                            hintText: "Search",
                            hoverColor: Colors.transparent,
                          ),
                          onFieldSubmitted: (value) {},
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          if (routeCoords.isNotEmpty) {
                            mapController.fitBounds(
                                LatLngBounds.fromPoints(routeCoords),
                                options: FitBoundsOptions(
                                    padding: EdgeInsets.all(20.0)));
                          }
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.gps_fixed,
                            size: 20.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 30,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Distance: ${distance.toStringAsFixed(2)} km",
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Text(
                                  "Duration: $duration",
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          )),
                    ),
                    const SizedBox(
                      width: 5.0,
                    ),
                    Expanded(
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 30,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: Center(
                            child: Text(
                              "To: $destinationName",
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          )),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  final Map<String, String> mapboxThemes = {
    'outdoors-v12': 'Pemandangan Alam',
    'light-v11': 'Tema Terang',
    'streets-v12': 'Jalan',
    'dark-v11': 'Tema Gelap',
    'satellite-v9': 'Satelit',
    'satellite-streets-v12': 'Jalan Satelit',
    'navigation-day-v1': 'Navigasi Siang Hari',
    'navigation-night-v1': 'Navigasi Malam Hari',
  };

  String selectedTheme = 'outdoors-v12';

  bool isRouteShown = false;
  late MapController mapController;
  List<LatLng> routeCoords = [];
  double distance = 0.0;
  String latitude1 = '';
  String longitude1 = '';
  String duration = "";

  String destinationName = "";

  Future<void> _getRoute(LatLng origin, LatLng destination) async {
    final url =
        "https://api.mapbox.com/directions/v5/mapbox/driving/${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}?alternatives=true&exclude=toll&geometries=geojson&language=en&overview=simplified&steps=true&access_token=${MAPBOX_ACCES_TOKEN}";

    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);
    final route = data['routes'][0]['geometry']['coordinates'];
    final legs = data['routes'][0]['legs'][0];
    final duration = legs['duration'] ~/ 60;

    final destinationName = legs['summary'].split(',').last;
    setState(() {
      routeCoords = route
          .map((point) => LatLng(point[1], point[0]))
          .toList()
          .cast<LatLng>();
      distance = data['routes'][0]['distance'] / 1000.0;
      this.duration = "$duration min";

      this.destinationName = destinationName;
    });
  }
}
