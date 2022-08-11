import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_app/alertstab/alertstab.dart';
import 'package:flutter_app/api/resp/accountResp.dart';
import 'package:flutter_app/global/MyColours.dart';
import 'package:flutter_app/hometab/hometab.dart';
import 'package:flutter_app/listtab/listtab.dart';
import 'package:flutter_app/settingstab/settingstab.dart';
import 'package:permission_handler/permission_handler.dart';
// for http POST/GET

class MainTabs extends StatefulWidget {
  static const String routeName = "/maintabs";
  Account account;
  List<String> deviceIDs = new List();

  @override
  MainTabsState createState() => new MainTabsState();
}

// SingleTickerProviderStateMixin is used for animation
class MainTabsState extends State<MainTabs>
    with TickerProviderStateMixin {
  // Create a tab controller
  TabController controller;

  @override
  void initState() {
    super.initState();

    // Initialize the Tab Controller
    controller = new TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    // Dispose of the Tab Controller
//    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // set login resp to variables
    widget.account = ModalRoute.of(context).settings.arguments;

    // add all deviceIDs into list
    for (DeviceGrps deviceGrp in widget.account.device_groups) {
      for (Devices device in deviceGrp.devices) {
        widget.deviceIDs.add(device.device_id);
      }
    }
    // test add dummy data aaa_2
    widget.deviceIDs.add("aaa_2");

    // main UI scaffold
    Widget mainBody = Scaffold(
      // main content body
      body: new TabBarView(
        // disable horizontal scroll
        physics: new NeverScrollableScrollPhysics(),
        // Add tabs as widgets
        children: <Widget>[
          new HomeTab(widget.deviceIDs),
          new ListTab(widget.account),
          new AlertsTab(),
          new SettingsTab()
        ],
        // set the controller
        controller: controller,
      ),

      // bottom tab bars
      bottomNavigationBar: new Material(
        // set the color of the bottom navigation bar
        color: MyColours.darkBlue1,
        // set the tab bar as the child of bottom navigation bar
        child: new TabBar(
          indicator: BoxDecoration(color: MyColours.darkBlue2),

          // hide underline indicator
//          indicator: UnderlineTabIndicator(
//              borderSide: BorderSide(color: MyColours.darkBlue2)),
          tabs: <Tab>[
            new Tab(
              // set icon to the tab
              child: Column(
                children: <Widget>[
                  Icon(
                    Icons.home,
                    color: MyColours.lightBlue1,
                  ),
                  Text(
                    "Home",
                    style:
                    TextStyle(fontSize: 10, color: MyColours.lightBlue1),
                  )
                ],
                mainAxisAlignment: MainAxisAlignment.center,
              ),
            ),
            new Tab(
              // set icon to the tab
              child: Column(
                children: <Widget>[
                  Icon(
                    Icons.list,
                    color: MyColours.lightBlue1,
                  ),
                  Text(
                    "List",
                    style:
                    TextStyle(fontSize: 10, color: MyColours.lightBlue1),
                  )
                ],
                mainAxisAlignment: MainAxisAlignment.center,
              ),
            ),
            new Tab(
              // set icon to the tab
              child: Column(
                children: <Widget>[
                  Icon(
                    Icons.notifications,
                    color: MyColours.lightBlue1,
                  ),
                  Text(
                    "Alerts",
                    style:
                    TextStyle(fontSize: 10, color: MyColours.lightBlue1),
                  )
                ],
                mainAxisAlignment: MainAxisAlignment.center,
              ),
            ),
            new Tab(
              // set icon to the tab
              child: Column(
                children: <Widget>[
                  Icon(
                    Icons.person,
                    color: MyColours.lightBlue1,
                  ),
                  Text(
                    "Profile",
                    style:
                    TextStyle(fontSize: 10, color: MyColours.lightBlue1),
                  )
                ],
                mainAxisAlignment: MainAxisAlignment.center,
              ),
            ),
          ],
          // setup the controller
          controller: controller,
        ),
      ),
    );

    // build main UI
    return mainBody;

//    return WillPopScope(
//      onWillPop: () async {
//        print("BACK PRESSED");
//        return true;
//      },
//
//      child: mainBody,
//    );
  }

  Future<bool> checkPermission() async {
    ServiceStatus serviceStatus =
        await PermissionHandler().checkServiceStatus(PermissionGroup.location);

    if (serviceStatus.value != ServiceStatus.enabled) {
      Map<PermissionGroup, PermissionStatus> permissions =
          await PermissionHandler()
              .requestPermissions([PermissionGroup.contacts]);
      if (permissions[PermissionGroup.location] == PermissionStatus.granted)
        return true;
    }

    return false;
  }

  void _handlePermissions(ServiceStatus status) {
    if (status != ServiceStatus.enabled) {
      PermissionHandler().requestPermissions(
          [PermissionGroup.locationWhenInUse]).then(onRequest);
    }
  }

  void onRequest(Map<PermissionGroup, PermissionStatus> permissions) {
    final status = permissions[PermissionGroup.locationWhenInUse];
    log('status : $status');
    if (status != PermissionStatus.granted) {
      debugPrint(status.toString());
      PermissionHandler().openAppSettings();
    }
  }
}
