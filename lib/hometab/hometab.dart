import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/api/request/deviceCoordsReq.dart';
import 'package:flutter_app/api/resp/deviceCoordsResp.dart';
import 'package:flutter_app/global/MyColours.dart';
import 'package:flutter_app/hometab/htBtmSheet.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class HomeTab extends StatefulWidget {
  final List<String> deviceIDs;

  const HomeTab(this.deviceIDs);

  @override
  HomeTabState createState() => new HomeTabState();
}

typedef Marker MarkerUpdateAction(Marker marker);

class HomeTabState extends State<HomeTab> {
  // basics
  HomeTabState();

  // gmaps
  GoogleMapController mapController;
  Widget _widget;

  // permissions
  bool locationPermission = false;

  // for timer (selected timer interval)
  int selectedInt = 5;
  int timerInt = 5;
  String timerTxt = "5s";
  Timer countdownTimer;

  // for markers
  Timer postCoordsTimer;
  bool isFirstTime = true;
  Map<String, Marker> markersHM = new HashMap();
  LatLngBounds latLngBounds;
  MarkerId selectedMarker;
  String deviceInFocus;

  Widget emptyWidget = new Scaffold(
    backgroundColor: Colors.white,
    body: new Container(
      child: new Center(
        child: new Column(
          // center the children
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Icon(
              Icons.map,
              size: 160.0,
              color: Colors.white,
            ),
            new Text(
              "Map",
              style: new TextStyle(color: Colors.white),
            )
          ],
        ),
      ),
    ),
  );

  void _onMapCreated(GoogleMapController controller) {
    print("JAY onmapcreated = $controller");

    this.mapController = controller;

    // start posting to server periodically
    restartCoordsTimer(false);
  }

  @override
  void deactivate() {
    print("JAY deactivate");

    super.deactivate();
  }

  @override
  void dispose() {
    print("JAY dispose");

    countdownTimer.cancel();
    postCoordsTimer.cancel();

    super.dispose();
  }

  @override
  void initState() {
    print("JAY initState");
    super.initState();

    // start/stop postCoords timer onpause/onresume
    SystemChannels.lifecycle.setMessageHandler((msg) {
      if (msg == AppLifecycleState.paused.toString()) {
        // cancel timer on pause
        if (postCoordsTimer != null) {
          postCoordsTimer.cancel();
          countdownTimer.cancel();
        }

        print("JAY paused");
      } else if (msg == AppLifecycleState.resumed.toString()) {
        restartCoordsTimer(false);

        print("JAY resume");
      }
    });

//    PermissionHandler()
//        .checkServiceStatus(PermissionGroup.locationWhenInUse)
//        .then(_handlePermissions);
  }

  Widget mapWidget;

  @override
  Widget build(BuildContext context) {
//    if (locationPermission == true) {
    mapWidget = Scaffold(
        body: Column(
          children: <Widget>[
            // full screen google maps
            Expanded(
              child: GoogleMap(
//                  myLocationEnabled: true,
                onMapCreated: _onMapCreated,
                initialCameraPosition: const CameraPosition(
                  target: LatLng(3.2378778, 101.6734017),
                  zoom: 7.0,
                ),
                markers: Set<Marker>.of(markersHM.values),
              ),
            ),
          ],
        ),
        floatingActionButton: Stack(
          children: <Widget>[
            // top right buttons (disable for now, no functions on gmaps yet)
            Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 45, 0, 0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        // switch maptype btn
                        actionBtns("mapTypeBtn", Icons.content_copy,
                            () => switchMapType()),

                        // toggle traffic btn
                        actionBtns("trafficBtn", Icons.traffic,
                            () => switchTrafficType())
                      ]),
                )),

            // left column btns
            Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        // countdown timer
                        Card(
                            color: Colors.white,
                            margin: EdgeInsets.fromLTRB(0, 50, 0, 0),
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                              child: Text(timerTxt),
                            )),

                        // btm btns
                        Column(
                          children: <Widget>[
                            // refresh btn
                            actionBtns("refreshBtn", Icons.refresh,
                                () => restartCoordsTimer(true)),

                            // my location btn
                            actionBtns("myLocBtn", Icons.my_location,
                                () => myLocation())
                          ],
                        ),
                      ]),
                )),
          ],
        ));

    _widget = mapWidget;
//    } else {
//      _widget = emptyWidget;
//    }

    return _widget;
  }

  //====== widgets
  FloatingActionButton actionBtns(
      String btnHeroTag, IconData icon, Function btnFunc) {
    return FloatingActionButton(
      heroTag: btnHeroTag,
      onPressed: btnFunc,
      child: Icon(
        icon,
        color: MyColours.lightBlue2,
      ),
      mini: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5.0))),
    );
  }

  //====== [END] widgets

  //========== [START] for permisisons
  void _handlePermissions(ServiceStatus value) {
    debugPrint('status1 : $value');
    log('status1 : $value');
//    if (value != ServiceStatus.enabled) {
    PermissionHandler().requestPermissions(
        [PermissionGroup.locationWhenInUse]).then(_onRequest);
//    } else {
//      setState(() {
//        locationPermission = true;
//        _widget = mapWidget;
//      });
//      PermissionHandler().openAppSettings();
//    }
  }

  // on request location permissions
  void _onRequest(Map<PermissionGroup, PermissionStatus> value) {
    final status = value[PermissionGroup.locationWhenInUse];
    log('status2 : $status');
    if (status != PermissionStatus.granted) {
      debugPrint(status.toString());

      if (status == PermissionStatus.disabled) {
        _showDialog();
        PermissionHandler().shouldShowRequestPermissionRationale(
            PermissionGroup.locationWhenInUse);
      } else {
        PermissionHandler().openAppSettings();
      }
    } else {
      setState(() {
        locationPermission = true;
        _widget = mapWidget;
      });
    }
  }

  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Location Settings Disabled"),
          content:
              new Text("Please enable location so that map function properly"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  //========== [END] for permisisons

  //====== action btn functions
  // cancel and restart timer (refresh btn)
  void restartCoordsTimer(isRefresh) {
    // zoom to initial marker and get deviceIDs again if isRefresh
    if (isRefresh) {
      CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(latLngBounds, 5);
      mapController.animateCamera(cameraUpdate);
    }

    // reset timer
    if (postCoordsTimer != null) {
      postCoordsTimer.cancel();
      countdownTimer.cancel();
    }

    if (widget.deviceIDs.isNotEmpty) {
      getDeviceCoords().then(loopResp);
    }

    // start posting interval
    postToGetCoords(null);
    postCoordsTimer =
        Timer.periodic(Duration(seconds: selectedInt), postToGetCoords);

    // start countdown timer interval
    setCountDownTxt(null);
    countdownTimer = Timer.periodic(Duration(seconds: 1), setCountDownTxt);
  }

  void myLocation() {
    print("JAY myLocation");
  }

  void switchMapType() {
    print("JAY switchMapType");
  }

  void switchTrafficType() {
    print("JAY switchTrafficType");
  }

  //====== [END] action btn functions

  //====== marker functions (onclick, etc)
  // show btm sheet (device info) when click on marker

//====== [END] marker functions

//===== marker/countdown functions
// countdown timer
  void setCountDownTxt(Timer timer) {
    timerTxt;

    if (timerInt < 1) {
      setState(() {
        timerTxt = "5s";
      });
      timerInt = 5;
    } else {
      setState(() {
        timerTxt = timerInt.toString() + "s";
      });
    }
    timerInt--;
  }

// function to get coords of devices from server
  Future<String> getDeviceCoords() async {
    String url = 'https://gps2.soappchat.com/api/test_2';

    var request =
        deviceCoordsJSON(DeviceCoordsReq(deviceIds: widget.deviceIDs));

    var response = await http.post(Uri.encodeFull(url),
        headers: {"Content-Type": "application/json"}, body: request);
//    response.statusCode

    return response.body;
  }

// add markers to map on response
  void loopResp(String resp) async {
    print("JAY loopResp");

    // stop if not mounted (disposed)
    if (!mounted) {
      return;
    }

    // convert response to list
    var list = json.decode(resp) as List;
    List<DeviceCoords> deviceCoordsList =
        list.map((i) => DeviceCoords.fromJson(i)).toList();

    // start looping each and update marker
    deviceCoordsList.forEach(createOrUpdateMarkers);

    // zoom to bounds if is first time
    if (isFirstTime) {
      CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(latLngBounds, 5);
      mapController.animateCamera(cameraUpdate);

      isFirstTime = false;
    }
  }

// post device IDs to get coords
  void postToGetCoords(Timer timer) {
    // get device coords then create/update markers
    getDeviceCoords().then(loopResp);
  }

// create or update marker to map based on exist or not
  void createOrUpdateMarkers(DeviceCoords deviceCoords) {
    // get device info from resp
    String deviceID = deviceCoords.deviceId;
    String deviceName = deviceCoords.deviceName;
    String speed = deviceCoords.speed.toString();
    String bearing = deviceCoords.course.toString();
    LatLng latLng = LatLng(double.parse(deviceCoords.latitude),
        double.parse(deviceCoords.longitude));
    Marker marker;

    // extend bounds if first time
    if (isFirstTime) {
      // [Flutter unavailable] use first marker for now
      latLngBounds = LatLngBounds(southwest: latLng, northeast: latLng);
    }

    // check if marker exists already
    if (!markersHM.containsKey(deviceID)) {
      // marker does NOT exist, create
      // create new marker
      marker = Marker(
        markerId: MarkerId(deviceID),
        position: latLng,
        infoWindow: InfoWindow(title: deviceName),
        onTap: () {
          onMarkerTapped(deviceID);
        },
        icon: BitmapDescriptor.fromAsset('images/redcar.png'),
        rotation: 0,
      );

      // show marker infowindow

      // add marker to hashmap
      setState(() {
        markersHM[deviceID] = marker;
      });
    } else {
      // marker already exists, update
      // get existing marker
      marker = markersHM[deviceID];
      // update detailed info if opened

      // get old latLng first
      LatLng oldLatLng = marker.position;

      // only update marker position if got positional difference
      if (oldLatLng.latitude != latLng.latitude ||
          oldLatLng.longitude != latLng.longitude) {
        // update marker rotation

        // animate new marker position
        animateMarker(
            oldLatLng, latLng, marker, getRotationAngle(oldLatLng, latLng));

        // zoom to new position if marker in focus
        if (deviceInFocus == deviceID) {
          zoomToMarker(latLng, 0);
        }
      }
    }
  }

  // get rotation angle based on 2 coords
  getRotationAngle(LatLng latlng1, LatLng latlng2) {
    var dLon = latlng2.longitude - latlng1.longitude;

    var y = math.sin(dLon) * math.cos(latlng2.latitude);
    var x = math.cos(latlng1.latitude) * math.sin(latlng2.latitude) -
        (math.sin(latlng1.latitude) *
            math.cos(latlng2.latitude) *
            math.cos(dLon));

    var brng = math.atan2(y, x);
    brng = brng * 180.0 / math.pi;
    brng = (brng + 360) % 360;
    // count degrees counter-clockwise - remove to make clockwise
    brng = (360) - brng;

    return brng;
  }

  // for marker position animation
  int i = 0;

  void animateMarker(
      LatLng oldLatLng, LatLng latLng, Marker marker, double rotationAngle) {
    // prepare variables
    var latLngs = [];
    double fromLat = oldLatLng.latitude;
    double fromLng = oldLatLng.longitude;
    double toLat = latLng.latitude;
    double toLng = latLng.longitude;

    // loop animation from 0 to 100 percent
    for (double percent = 0; percent <= 1; percent += 0.01) {
      double curLat = fromLat + percent * (toLat - fromLat);
      double curLng = fromLng + percent * (toLng - fromLng);
      LatLng latLng = LatLng(curLat, curLng);

      latLngs.add(latLng);
    }

    // animate with timer
    move(marker, latLngs, marker.markerId.value, rotationAngle);
  }

  void move(Marker marker, latLngs, deviceID, double rotationAngle) {
    // update marker position first
    setState(() {
      markersHM[deviceID] = marker.copyWith(
        positionParam: latLngs[i],
        rotationParam: rotationAngle,
      );
    });

    // check if last index
    if (i < latLngs.length - 1) {
      // not last, make new timer for next animation
      i++;
      new Timer(Duration(milliseconds: 10),
          () => move(marker, latLngs, deviceID, rotationAngle));
    } else {
      // last index, reset index and don't animate further
      i = 0;
    }
  }

// [END] marker position animation

// when click on a marker
  void onMarkerTapped(String deviceID) {
    // set device in focus
    deviceInFocus = deviceID;

    // get tapped marker
    final Marker tappedMarker = markersHM[deviceID];

    if (tappedMarker != null) {
      // zoom to marker if got marker
      zoomToMarker(tappedMarker.position, 15);
    }

    // show marker btm sheet info
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return HTBtmSheet(deviceID);
        });
  }

// zoom to marker position with zoom level
  void zoomToMarker(LatLng latLng, double zoomLevel) {
    CameraUpdate cameraUpdate;
    if (zoomLevel > 0) {
      cameraUpdate = CameraUpdate.newLatLngZoom(latLng, zoomLevel);
    } else {
      cameraUpdate = CameraUpdate.newLatLng(latLng);
    }
    mapController.animateCamera(cameraUpdate);
  }

  @override
// this will keep map from refreshing
  bool get wantKeepAlive => true;
}
