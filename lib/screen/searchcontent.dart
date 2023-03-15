import 'package:flutter/material.dart';
import 'package:project_maps/constant/color.dart';
import 'package:project_maps/model/location.dart';
import 'package:project_maps/screen/api.dart';

class SearchContent extends SearchDelegate {
  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Icon(Icons.arrow_back_ios));
  }

  FetchUser _userlist = FetchUser();
  @override
  Widget buildResults(BuildContext context) {
    final url = 'http://192.168.1.16/elevated/upload/';
    return Container(
        child: FutureBuilder<List<TampilContent>>(
      future: _userlist.getUserList(query: query),
      builder: (context, snapshot) {
        var data = snapshot.data;
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        return GridView.builder(
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: 1.0,
            crossAxisCount: 2,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            mainAxisExtent: 250,
          ),
          itemCount: data?.length,
          shrinkWrap: true,
          physics: const ScrollPhysics(),
          itemBuilder: (ctx, index) {
            return Container(
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
                      url + data![index].image!,
                      height: 170,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  ListTile(
                    title: Text(
                      data![index].place!.length > 15
                          ? '${data![index].place!.substring(0, 15)}...'
                          : data![index].place!,
                    ),
                    subtitle: Text(
                      data![index].description!.length > 15
                          ? '${data![index].description!.substring(0, 15)}...'
                          : data![index].description!,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Center(
      child: Text('search place'),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = '';
          },
          icon: Icon(Icons.close))
    ];
  }
}
