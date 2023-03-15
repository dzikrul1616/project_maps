import 'package:flutter/material.dart';

import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:project_maps/constant/color.dart';
import 'package:project_maps/screen/dashboard.dart';
import 'package:project_maps/screen/maps.dart';

class BottombarView extends StatefulWidget {
  final VoidCallback determinePosition;
  BottombarView(this.determinePosition);

  @override
  State<BottombarView> createState() => _BottombarViewState();
}

class _BottombarViewState extends State<BottombarView> {
  // ignore: prefer_typing_uninitialized_variables
  _determinePosition() async {
    setState(() {
      widget.determinePosition();
    });
  }

  late var _pgno = [
    MapsView(),
    DashboardView(ondeterminePosition: widget.determinePosition),
  ];
  int _pilihtabbar = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.w600);
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Home',
      style: optionStyle,
    ),
    Text(
      'Profile',
      style: optionStyle,
    ),
  ];

  void _changetabbar(int index) {
    setState(() {
      _pilihtabbar = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _pgno = [
      MapsView(),
      DashboardView(ondeterminePosition: () {
        _determinePosition;
      })
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      body: _pgno[_pilihtabbar],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 20,
                color: Colors.black.withOpacity(.1),
              )
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
              child: GNav(
                style: GnavStyle.google,
                rippleColor: Color.fromARGB(255, 255, 132, 0),
                hoverColor: Color.fromARGB(255, 255, 171, 14),
                gap: 3,
                activeColor: appPrimary,
                iconSize: 18,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 18),
                duration: Duration(milliseconds: 400),
                tabBackgroundColor: Colors.grey[100]!,
                color: appPrimary,
                tabs: [
                  GButton(
                    icon: Icons.maps_ugc,
                    text: 'Maps',
                  ),
                  GButton(
                    icon: Icons.list,
                    text: 'List',
                  ),
                ],
                selectedIndex: _pilihtabbar,
                onTabChange: (index) {
                  setState(() {
                    _pilihtabbar = index;
                  });
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
