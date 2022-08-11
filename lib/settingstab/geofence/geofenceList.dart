import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/api/resp/geoFenceResp.dart';
import 'package:flutter_app/global/MyColours.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_app/settingstab/geofence/geofenceActi.dart';

class GeoFenceList extends StatefulWidget {
  static const String routeName = "/geofencelist";

  @override
  GeoFenceState createState() => new GeoFenceState();
}

class GeoFenceState extends State<GeoFenceList> {
  final scrollController = ScrollController();
  List<GeoFence> geoFenceList = [
    GeoFence.fromJson({"name": "gf_1", "radius": "100km"}),
    GeoFence.fromJson({"name": "gf_2", "radius": "130km"}),
    GeoFence.fromJson({"name": "gf_3", "radius": "150km"}),
    GeoFence.fromJson({"name": "gf_4", "radius": "1040km"}),
    GeoFence.fromJson({"name": "gf_4", "radius": "1040km"}),
    GeoFence.fromJson({"name": "gf_4", "radius": "1040km"}),
    GeoFence.fromJson({"name": "gf_4", "radius": "1040km"}),
    GeoFence.fromJson({"name": "gf_4", "radius": "1040km"}),
    GeoFence.fromJson({"name": "gf_4", "radius": "1040km"}),
    GeoFence.fromJson({"name": "gf_4", "radius": "1040km"}),
    GeoFence.fromJson({"name": "gf_4", "radius": "1040km"}),
    GeoFence.fromJson({"name": "gf_4", "radius": "1040km"}),
    GeoFence.fromJson({"name": "gf_4", "radius": "1040km"}),
    GeoFence.fromJson({"name": "gf_4", "radius": "1040km"}),
    GeoFence.fromJson({"name": "gf_4", "radius": "1040km"}),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColours.darkBlue1,
        title: Text(
          "Geo Fence",
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, GeoFenceActi.routeName);
            },
            color: Colors.white,
          )
        ],
        centerTitle: true,
      ),
      body: listView(),
    );
  }

  // list of geofences (get from server)
  ListView listView() {
    return ListView.builder(
        padding: EdgeInsets.fromLTRB(15, 20, 15, 10),
        controller: scrollController,
        itemCount: geoFenceList.length,
        itemBuilder: (context, i) {
          return listItem(geoFenceList[i].name, geoFenceList[i].radius);
        });
  }

  // list items
  Container listItem(String name, String radius) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
      decoration: BoxDecoration(
        border: Border.all(color: MyColours.grey2),
        color: Colors.white,
      ),
      child: Column(
        children: <Widget>[
          listViewTopRow(name, radius),
          listViewBtmRow(),
        ],
      ),
    );
  }

  // top white box in listItem
  Column listViewTopRow(String name, String radius) {
    return Column(children: <Widget>[
      Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(15, 15, 15, 30),
              child: Row(
                children: <Widget>[
                  Icon(Icons.public),
                  Padding(
                    padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                    child: Text(name),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
            child: Column(
              children: <Widget>[Icon(Icons.pie_chart_outlined), Text(radius)],
            ),
          )
        ],
      ),
    ]);
  }

  // btm grey box in listitem
  Row listViewBtmRow() {
    return Row(
      children: <Widget>[
        btmRowBtns(false, Icons.edit, "Edit"),
        btmRowBtns(false, Icons.directions_car, "Add Device"),
        btmRowBtns(true, Icons.delete, "Remove"),
      ],
    );
  }

  // borderside
  BorderSide borderSide() {
    return BorderSide(color: MyColours.grey2);
  }

  // enter/exit
  Expanded btmRowBtns(bool isLast, IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
        decoration: BoxDecoration(
            color: MyColours.grey1,
            border: Border(
                top: borderSide(),
                left: BorderSide.none,
                bottom: BorderSide.none,
                right: isLast ? BorderSide.none : borderSide())),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              color: MyColours.lightBlue2,
              size: 18,
            ),
//            Padding(
//              padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
//              child:
            Flexible(
              child: Padding(
                padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                child: AutoSizeText(
                  label,
                  maxLines: 1,
                ),
              ),
            ),
//            )
          ],
        ),
      ),
    );
  }
}
