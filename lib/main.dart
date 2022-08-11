import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/global/MyColours.dart';
import 'package:flutter_app/maintabs.dart';

import 'package:flutter_app/login/forgot_password.dart';
import 'package:flutter_app/login/login.dart';
import 'package:flutter_app/secondary/playback.dart';
import 'package:flutter_app/settingstab/geofence/geofenceActi.dart';
import 'package:flutter_app/settingstab/geofence/geofenceList.dart';

void main() {
  // setup portrait orientation

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(new MaterialApp(
      theme: ThemeData(primaryColor: MyColours.darkBlue2),
      home: new Login(), // home has implicit route set at '/'
      // Setup routes
      routes: <String, WidgetBuilder>{
        //========= Set named routes
        // login package
        ForgotPassword.routeName: (context) => new ForgotPassword(),

        // main tabs
        MainTabs.routeName: (context) => new MainTabs(),

        // secondary pages
        Playback.routeName: (context) => new Playback(),

        // geofence
        GeoFenceList.routeName: (context) => new GeoFenceList(),
        GeoFenceActi.routeName: (context) => new GeoFenceActi(),
      },
    ));
  });
}
