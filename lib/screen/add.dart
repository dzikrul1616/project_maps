import 'dart:convert';
import 'package:flutter/src/widgets/framework.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:project_maps/constant/color.dart';
import 'dart:io';
import 'package:flutter_map/src/layer/tile_layer/tile_layer.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_map/flutter_map.dart';

const MAPBOX_ACCES_TOKEN =
    'pk.eyJ1IjoiZHppa3J1bDE2MTYiLCJhIjoiY2xleWJ6aTdlMGc0ODQxcXZsaDZlaDhwciJ9.Nz95V3UL1b8AfExigWUllA';

class AddMaps extends StatefulWidget {
  @override
  State<AddMaps> createState() => _AddMapsState();
}

class _AddMapsState extends State<AddMaps> {
  File? _image;
  final picker = ImagePicker();
  late String place, description, latitude, longitude;
  String latitude1 = '';
  String longitude1 = '';
  Future getImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: source);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  final _key = new GlobalKey<FormState>();

  check() {
    final form = _key.currentState;
    if (form!.validate()) {
      form.save();
      _submitForm();
    }
  }

  Future<void> _submitForm() async {
    if (!_key.currentState!.validate()) {
      return;
    }
    _key.currentState!.save();

    final url = Uri.parse('http://192.168.1.16/elevated/addContent.php');
    final request = http.MultipartRequest('POST', url);

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        _image!.path,
      ),
    );

    request.fields.addAll({
      'place': place,
      'description': description,
      'latitude': latitude1,
      'longtitude': longitude1,
    });

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final responseJson = json.decode(responseString);
      print(responseJson);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(responseJson.toString()),
          backgroundColor: appGrey,
        ),
      );
    } else {
      print('Error: ${response.reasonPhrase}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan saat menambahkan data'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: appPrimary,
          centerTitle: true,
          title: Text(
            "Add Place",
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        extendBodyBehindAppBar: true,
        body: Form(
          key: _key,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: ListView(
              children: [
                const SizedBox(
                  height: 20.0,
                ),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return SafeArea(
                          child: Container(
                            child: Wrap(
                              children: <Widget>[
                                ListTile(
                                  leading: Icon(Icons.camera_alt),
                                  title: Text('Camera'),
                                  onTap: () {
                                    getImage(ImageSource.camera);
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  leading: Icon(Icons.image),
                                  title: Text('Gallery'),
                                  onTap: () {
                                    getImage(ImageSource.gallery);
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Container(
                    height: 200.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: _image == null
                        ? Icon(
                            Icons.camera_alt,
                            color: Colors.grey,
                            size: 50.0,
                          )
                        : Image.file(
                            _image!,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                SizedBox(height: 16.0),
                const SizedBox(
                  height: 16.0,
                ),
                TextFormField(
                  onSaved: (e) => place = e!,
                  decoration: InputDecoration(
                    hintText: 'Place',
                    filled: true,
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    fillColor: Color(0xffF2F2F2),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            width: 0, style: BorderStyle.none)),
                  ),
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return 'Harap isi Place';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  onSaved: (e) => description = e!,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Deskripsi',
                    filled: true,
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    fillColor: Color(0xffF2F2F2),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            width: 0, style: BorderStyle.none)),
                  ),
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return 'Harap isi deskripsi';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 16.0,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 250,
                  child: Expanded(
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
                          options: MapOptions(
                              center: markerPosition,
                              minZoom: 10,
                              maxZoom: 18,
                              zoom: 18,
                              onTap: (as, LatLng? latlng) {
                                setState(() {
                                  latitude1 = latlng!.latitude.toString();
                                  longitude1 = latlng!.longitude.toString();
                                });
                              }),
                          nonRotatedChildren: [
                            TileLayer(
                              additionalOptions: {
                                'accestoken': MAPBOX_ACCES_TOKEN,
                                'id': 'mapbox/streets-v12',
                              },
                              urlTemplate:
                                  'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}@2x?access_token={accestoken}',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: LatLng(
                                      double.tryParse(latitude1) ?? 0.0,
                                      double.tryParse(longitude1) ?? 0.0),
                                  builder: (context) {
                                    return InkWell(
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
                            )
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16.0,
                ),
                // Row(
                //   children: [
                //     Expanded(
                //         child: Container(
                //       width: MediaQuery.of(context).size.width,
                //       height: 60,
                //       decoration: BoxDecoration(
                //           borderRadius: BorderRadius.circular(10),
                //           color: Color(0xffF2F2F2)),
                //       child: Center(child: Text('Latitude : ' + latitude1)),
                //     )),
                //     const SizedBox(
                //       width: 10.0,
                //     ),
                //     Expanded(
                //         child: Container(
                //       width: MediaQuery.of(context).size.width,
                //       height: 60,
                //       decoration: BoxDecoration(
                //           borderRadius: BorderRadius.circular(10),
                //           color: Color(0xffF2F2F2)),
                //       child: Center(child: Text('Longitude : ' + longitude1)),
                //     ))
                //   ],
                // ),
                // Row(
                //   children: [
                //     Expanded(
                //       child: TextFormField(
                //         initialValue: latitude1,
                //         onChanged: (value) {
                //           setState(() {
                //             latitude1 = value;
                //           });
                //         },
                //         onSaved: (e) => latitude = e!,
                //         keyboardType: TextInputType.number,
                //         decoration: InputDecoration(
                //           hintText: 'Latitude',
                //           filled: true,
                //           floatingLabelBehavior: FloatingLabelBehavior.never,
                //           fillColor: Color(0xffF2F2F2),
                //           border: OutlineInputBorder(
                //               borderRadius: BorderRadius.circular(10),
                //               borderSide: const BorderSide(
                //                   width: 0, style: BorderStyle.none)),
                //         ),
                //         validator: (String? value) {
                //           if (value!.isEmpty) {
                //             return 'Harap isi Latitude';
                //           }
                //           return null;
                //         },
                //       ),
                //     ),
                //     const SizedBox(
                //       width: 15.0,
                //     ),
                //     Expanded(
                //       child: TextFormField(
                //         initialValue: longitude1,
                //         onChanged: (value) {
                //           setState(() {
                //             longitude1 = value;
                //           });
                //         },
                //         onSaved: (e) => longitude = e!,
                //         keyboardType: TextInputType.number,
                //         decoration: InputDecoration(
                //           hintText: 'Longitude',
                //           filled: true,
                //           floatingLabelBehavior: FloatingLabelBehavior.never,
                //           fillColor: Color(0xffF2F2F2),
                //           border: OutlineInputBorder(
                //               borderRadius: BorderRadius.circular(10),
                //               borderSide: const BorderSide(
                //                   width: 0, style: BorderStyle.none)),
                //         ),
                //         validator: (String? value) {
                //           if (value!.isEmpty) {
                //             return 'Harap isi Longitude';
                //           }
                //           return null;
                //         },
                //       ),
                //     ),
                //   ],
                // ),
                const SizedBox(
                  height: 16.0,
                ),
                SizedBox(height: 16.0),
                Expanded(
                  child: Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                      onPressed: check,
                      child: Text('Add Data'),
                      style: ElevatedButton.styleFrom(primary: appPrimary),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
              ],
            ),
          ),
        ));
  }
}
