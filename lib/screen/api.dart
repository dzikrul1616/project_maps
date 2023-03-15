import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:project_maps/model/location.dart';
import 'package:http/http.dart' as http;

class FetchUser {
  var data = [];
  List<TampilContent> result = [];
  String fetchurl = "http://192.168.1.16/elevated/detileContent.php";

  Future<List<TampilContent>> getUserList({String? query}) async {
    var url = Uri.parse(fetchurl);
    var response = await http.get(url);
    try {
      if (response.statusCode == 200) {
        data = jsonDecode(response.body);
        result = data.map((e) => TampilContent.fromJson(e)).toList();
        if (query != null) {
          result = result
              .where((element) =>
                  element.place!.toLowerCase().contains(query.toLowerCase()))
              .toList();
        }
      } else {
        print('api_eror');
      }
    } on Exception catch (e) {
      print('eror : $e');
    }
    return result;
  }
}
