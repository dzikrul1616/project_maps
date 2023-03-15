import 'dart:convert';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:project_maps/constant/color.dart';
import 'package:project_maps/model/location.dart';
import 'package:project_maps/screen/add.dart';
import 'package:project_maps/screen/profil.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:project_maps/screen/searchcontent.dart';

class DashboardView extends StatefulWidget {
  final VoidCallback ondeterminePosition;
  DashboardView({required this.ondeterminePosition});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  late List<TampilContent> list = <TampilContent>[];
  List<TampilContent> searchResult = [];
  var loading = false;
  bool _refreshing = false;
  _determine() {
    setState(() {
      widget.ondeterminePosition();
    });
  }

  Future<void> _onRefresh() async {
    await _get();
  }

  _get({String? query}) async {
    final url = 'http://192.168.1.16/elevated/detileContent.php';
    final response = await Dio().get(url);
    var data = [];
    if (response.data.length == 2) {
    } else {
      final data = jsonDecode(response.data);
      List<TampilContent> tempList = [];
      data.forEach((api) {
        final ab = new TampilContent(
          api!['id_content'],
          api['image'],
          api['place'],
          api['latitude'],
          api['longtitude'],
          api['description'],
          api['date_content'],
          api['id_users'],
          api['username'],
        );
        tempList.add(ab);
      });
      setState(() {
        list = tempList;
        loading = false;
      });
    }
  }

  @override
  void initState() {
    _determine();
    _get();
    super.initState();
  }

  TextEditingController searchController = TextEditingController();
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final url = 'http://192.168.1.16/elevated/upload/';
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: EdgeInsets.only(top: 10),
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(12.0),
                              ),
                            ),
                            child: InkWell(
                              onTap: () {
                                showSearch(
                                    context: context,
                                    delegate: SearchContent());
                              },
                              child: Row(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(Icons.search),
                                  ),
                                  Expanded(
                                    child: TextField(
                                      enabled: false,
                                      decoration:
                                          const InputDecoration.collapsed(
                                        filled: true,
                                        fillColor: Colors.transparent,
                                        hintText: "Search",
                                        hoverColor: Colors.transparent,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {},
                                    child: const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.filter_list,
                                        size: 20.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ProfilView()));
                          },
                          child: CircleAvatar(
                            radius: 18,
                            child: const Icon(
                              Icons.person,
                              size: 20.0,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  StaggeredGridView.countBuilder(
                    padding: EdgeInsets.zero,
                    crossAxisCount: 2,
                    itemCount: list.length,
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
                    itemBuilder: (ctx, index) {
                      final item = list[index];
                      return InkWell(
                        onLongPress: () {
                          _dialogdelete(item.idContent!);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: appTrans,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(12.0),
                            ),
                          ),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(10),
                                  topLeft: Radius.circular(10),
                                ),
                                child: Image.network(
                                  url + item.image!,
                                  height: index.isEven ? 175 : 212,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Expanded(
                                child: ListTile(
                                  title: Text(
                                    item.place!.length > 15
                                        ? '${item.place!.substring(0, 15)}...'
                                        : item.place!,
                                    style: const TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.description!.length > 8
                                            ? '${item.description!.substring(0, 8)}...'
                                            : item.description!,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Latitude :",
                                            style: TextStyle(
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              item.latitude!.length > 10
                                                  ? '${item.latitude!.substring(0, 10)}...'
                                                  : item.latitude!,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Longtitude :",
                                            style: TextStyle(
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              item.longtitude!.length > 8
                                                  ? '${item.longtitude!.substring(0, 8)}...'
                                                  : item.longtitude!,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    staggeredTileBuilder: (index) {
                      return StaggeredTile.count(1, index.isEven ? 1.4 : 1.6);
                    },
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _delete(String id_content) async {
    final url = Uri.parse('http://192.168.1.16/elevated/delete.php');
    final response = await http.post(url, body: {"id_content": id_content});
    final data = jsonDecode(response.body);
    int value = data['value'];
    String pesan = data['messege'];
    if (value == 1) {
      _get();
    } else {
      print(pesan);
    }
  }

  _dialogdelete(String id_content) {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: ListView(
              padding: EdgeInsets.all(20),
              shrinkWrap: true,
              children: <Widget>[
                Text(
                  'Apakah anda yakin ingin menghapus file?',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('No'),
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _delete(id_content);
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Ya',
                        style: const TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(primary: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }
}
