import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/global/MyColours.dart';

import 'package:flutter_app/global/myWidget/custom_scrollable_center_container.dart';
import 'package:flutter_app/settingstab/geofence/geofenceList.dart';

const _PATH = "assets/images";
const _PIC09 = "$_PATH/pic09.png";
const _PIC10 = "$_PATH/circle_10.png";

class SettingsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget colItems(
        IconData icon, String label, bool isLast, String routeName) {
      return Container(
          margin: EdgeInsets.fromLTRB(60, 0, 60, 0),
          decoration: isLast
              ? null
              : BoxDecoration(
                  border: BorderDirectional(
                      bottom: BorderSide(
                  color: MyColours.grey2,
                ))),
          child: Material(
            color: Colors.white,
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, routeName);
              },
              child: Container(
                padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(
                          icon,
                          size: 25,
                          color: MyColours.lightBlue1,
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                          child: Text(
                            label,
                          ),
                        )
                      ],
                    ),
                    Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
          ));
    }

    return new Scaffold(
      body: Container(
          child: Column(
        children: <Widget>[
          Expanded(
              flex: 5,
              child: Container(
                  color: MyColours.darkBlue1,
                  child: Stack(
                    children: <Widget>[
                      Align(
                          alignment: Alignment(0.9, -0.6),
                          child: IconButton(
                              icon: Icon(
                                Icons.exit_to_app,
                                color: Colors.white,
                              ),
                              onPressed: () {})),
                      Align(
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              CircleAvatar(
                                radius: 60.0,
                                backgroundImage: AssetImage(_PIC09),
                                backgroundColor: Colors.transparent,
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                                child: Text(
                                  "Algie UBER",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              )
                            ],
                          ))
                    ],
                  ))),
          Expanded(
              flex: 7,
              child: CustomScrollableCenterContainer(
                  Colors.white,
                  Container(
                    color: Colors.white,
                    child: Stack(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              colItems(Icons.public, "Geo Fence", false, GeoFenceList.routeName),
                              colItems(Icons.feedback, "Feedback", false, GeoFenceList.routeName),
                              colItems(Icons.warning, "Alert Settings", false, GeoFenceList.routeName),
                              colItems(Icons.settings, "Settings", true, GeoFenceList.routeName),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  null))
        ],
      )),
    );
  }
}
