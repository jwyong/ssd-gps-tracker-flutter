import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_app/global/MyColours.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Playback extends StatefulWidget {
  static const String routeName = "/playback";

  @override
  PlaybackState createState() => new PlaybackState();
}

// Create a tab controller
TabController tabController;
PersistentBottomSheetController bsController;

class PlaybackState extends State<Playback>
    with SingleTickerProviderStateMixin {
  // for gmaps
  GoogleMapController mapController;

  // for bottomsheet row items
  String startDateTime = "-";
  String endDateTime = "-";
  String deviceName = "GPS 1";

  // for playback
  String deviceID;
  Map<String, Marker> markersHM = new HashMap();
  Map<PolylineId, Polyline> polyHM = <PolylineId, Polyline>{};
  bool isPlaying = false;
  double playbackVal = 0;
  String playbackSpeedText = "Medium";
  String playbackDateTime = "-";
  bool needPolyline = true;
  Polyline polyline;
  bool needResetPolyline = false;
  var playbackArray = [];
  int firstTimeStamp = 0;
  int playbackTimeRange = 0;
  int currentIndex = 0;
  int playbackSpeed = 50;
  Timer playbackTimer;

  @override
  void initState() {
    super.initState();

    // Initialize the Tab Controller
    tabController = new TabController(length: 4, vsync: this);
    tabController.addListener(() => onTabChange());
  }

  @override
  void dispose() {
    // Dispose of the Tab Controller
    tabController.removeListener(() => onTabChange());
    tabController.dispose();

    // dispose of timer
    playbackTimer.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    deviceID = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: titleBar(),
      body: Column(children: <Widget>[
        // google maps
        Expanded(
          child: GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: LatLng(3.2378778, 101.6734017),
              zoom: 7.0,
            ),
            markers: Set<Marker>.of(markersHM.values),
            polylines: Set<Polyline>.of(polyHM.values),
          ),
        ),

        // playback items
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            // playback seekerbar row
            Container(
              color: MyColours.grey1,
              padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: playbackSliderRow(),
            ),

            // expandable middle white bg items
            ExpansionTile(
              backgroundColor: Colors.white,
              title: IntrinsicHeight(
                  child: Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // playback info cards
                    playbackInfoCard(0),
                    playbackInfoCard(1),
                    playbackInfoCard(2),

                    // speed
                  ],
                ),
              )),

              // expansion items (start and end point)
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
                  child: Column(
                    children: <Widget>[
                      startEndPointRow(Colors.green,
                          "Northwest 51m, CLM Corp. Ladies Dormitory, G. Lavilles Tinago, Cebu City, 6000 Philippines"),
                      Padding(
                        padding: EdgeInsets.all(5),
                      ),
                      startEndPointRow(
                          Colors.red, "Umapad, Mandaue City, 6014 Philippines"),
                    ],
                  ),
                )
              ],
            ),

            // bottom row (name + action btns)
            Container(
              color: MyColours.grey1,
              padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: playbackActionRow(),
            ),
          ],
        )

        // *bottomsheet (first page) is called from function "showBtmSheet"
      ]),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    this.mapController = controller;

    showBtmSheet(context);
  }

  //========== widget items
  // title bar
  AppBar titleBar() {
    return AppBar(
        title: Text("Playback"),
        centerTitle: true,
        backgroundColor: MyColours.darkBlue1);
  }

  //===== bottomsheet items
  // "Today" "Yesterday" etc
  Text tabBarText(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 12, color: MyColours.lightBlue2),
      textAlign: TextAlign.center,
    );
  }

  // start/end date/time
  Row startEndDateRow(IconData iconData, Color iconColour, String labelTitle,
      String labelText) {
    return Row(
      children: <Widget>[
        Icon(
          iconData,
          color: iconColour,
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
            child: Text(labelTitle),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
          child: Text(labelText),
        ),
        Icon(
          Icons.arrow_forward_ios,
        ),
      ],
    );
  }

  // ok/cancel btns
  RaisedButton btnItem(int btnFunc, String btnLabel, Color btnBgColour) {
    return RaisedButton(
      onPressed: () {
        switch (btnFunc) {
          case 1: // OK
            okBtnFunc();
            break;

          case 0: // CANCEL
            cancelBtnFunc();
            break;
        }
      },
      color: btnBgColour,
      child: Text(
        btnLabel,
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  //====== [END] bottomsheet items

  //====== playback items
  // playback seekerbar row
  Row playbackSliderRow() {
    return Row(
      children: <Widget>[
        // play btn
        InkWell(
          onTap: playbackArray.length > 0 ? playbackBtn : null,
          child: Icon(
            isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
            color: playbackArray.length > 0 ? Colors.red : Colors.grey,
          ),
        ),

        // playback seekerbar
        Expanded(
            child: Column(
          children: <Widget>[
            Slider(
              value: playbackVal,
              onChanged: (double value) => seekerBarOnChange(value),
              inactiveColor: Colors.white,
            ),
            Text(
              playbackDateTime,
              style: TextStyle(color: MyColours.grey2),
            )
          ],
        )),

        // speed btn
        InkWell(
          onTap: playbackArray.length > 0 ? changeSpeed : null,
          child: Column(
            children: <Widget>[
              Icon(Icons.fast_forward),
              Text(
                playbackSpeedText,
                style: TextStyle(fontSize: 10),
              )
            ],
          ),
        )
      ],
    );
  }

  // middle item 3 cards
  Expanded playbackInfoCard(int colIndex) {
    return Expanded(
        child: Card(
      color: MyColours.grey1,
      child: pbInfoCardContent(colIndex),
    ));
  }

  Widget pbInfoCardContent(int colIndex) {
    switch (colIndex) {
      case 0: // 16:29:34 2019-03-15
        return Padding(
          padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                "16:59:34",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "2019-03-15",
                textAlign: TextAlign.center,
                style: TextStyle(color: MyColours.grey2),
              )
            ],
          ),
        );

        break;

      case 1: // 0 km/h
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "0 km/h",
              textAlign: TextAlign.center,
            )
          ],
        );
        break;

      case 2: // 81.83km
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "81.83km",
              textAlign: TextAlign.center,
            )
          ],
        );
        break;
    }
  }

  // middle expanded items (start and end point)
  Row startEndPointRow(Color color, String address) {
    return Row(
      children: <Widget>[
        Icon(
          Icons.brightness_1,
          color: color,
          size: 12,
        ),
        Expanded(
            child: Padding(
          padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
          child: Text(address),
        )),
      ],
    );
  }

  // bottom items (name + 3 btns)
  Row playbackActionRow() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            "Device Name",
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // action btns
        btmActionBtn(Icons.replay, "Replay", () => replayBtn()),
        btmActionBtn(needPolyline ? Icons.visibility : Icons.visibility_off,
            needPolyline ? "Show" : "Hide", () => showHideTrackBtn()),
        btmActionBtn(Icons.autorenew, "Reset", () => resetPlaybackBtn()),
      ],
    );
  }

  // action btns for btm row
  InkWell btmActionBtn(IconData icon, String iconLabel, Function btnFunc) {
    return InkWell(
        onTap: btnFunc,
        child: Padding(
          padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
          child: Column(
            children: <Widget>[
              Icon(
                icon,
                color: MyColours.lightBlue2,
              ),
              Text(
                iconLabel,
                style: TextStyle(fontSize: 10),
              )
            ],
          ),
        ));
  }

  //====== [END] playback items
  //============ widget items end

  //======= functions
  // time period tab bar onchange (yesterday, today, last week, etc)
  void onTabChange() {
    if (tabController.indexIsChanging) {
      setState(() {
        startDateTime = "2019-02-30 20:30";
        endDateTime = "2019-03-04 21:45";
      });
    }
  }

  //===== bottomsheet functions
  // show bottom sheet on start
  void showBtmSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return
//            WillPopScope(
//            onWillPop: () async {
//              // need to fix back btn ux later
////              cancelBtnFunc();
//              return true;
//            },
//            child:

              GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {},
            child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  new TabBar(
                      controller: tabController,
                      onTap: (int index) {
                        tabController.index = index;
                      },
                      tabs: <Tab>[
                        new Tab(
                          child: tabBarText("Today"),
                        ),
                        new Tab(
                          child: tabBarText("Yesterday"),
                        ),
                        new Tab(
                          child: tabBarText("This Week"),
                        ),
                        new Tab(
                          child: tabBarText("Last Week"),
                        ),
                      ]),
                  Container(
                    color: Colors.white,
                    child: Column(
                      children: <Widget>[
                        // top card (time/date)
                        Card(
                          elevation: 0,
                          color: MyColours.grey1,
                          margin: EdgeInsets.fromLTRB(10, 10, 10, 5),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
                            child: Column(
                              children: <Widget>[
                                startEndDateRow(Icons.brightness_1,
                                    Colors.green, "Start Time", startDateTime),
                                Padding(padding: EdgeInsets.all(10)),
                                startEndDateRow(Icons.brightness_1, Colors.red,
                                    "End Time", endDateTime),
                              ],
                            ),
                          ),
                        ),

                        // btm card
                        Card(
                          elevation: 0,
                          color: MyColours.grey1,
                          margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
                            child: Column(
                              children: <Widget>[
                                startEndDateRow(Icons.directions_car,
                                    Colors.blue, "Device", deviceName),
                              ],
                            ),
                          ),
                        ),

                        // buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            btnItem(1, "OK", Colors.green),
                            Padding(
                              padding: EdgeInsets.all(5),
                            ),
                            btnItem(0, "CANCEL", Colors.red),
                          ],
                        ),

                        // space on btm
                        Padding(
                          padding: EdgeInsets.all(10),
                        )
                      ],
                    ),
                  )
                ]),
          );
        });
//        });
  }

  //----- ok btn functions
  void okBtnFunc() {
    // get playback array from server
    getPlaybackArray().then(playbackResp);
  }

  // POST to get playback array
  Future<http.Response> getPlaybackArray() async {
    String url = 'https://gps2.soappchat.com/api/test_3';

    var request = jsonEncode({'device_id': deviceID});

    var response = await http.post(Uri.encodeFull(url),
        headers: {"Content-Type": "application/json"}, body: request);

    return response;
  }

  // process playback response
  void playbackResp(http.Response resp) async {
    if (resp.statusCode == 200) {
      // success

      // set response array to data
      var list = json.decode(resp.body) as List;
      playbackArray = list.map((i) => (i)).toList();

      // set first time stamp
      firstTimeStamp = playbackArray[0][0];

      // set playback time range (last timestamp - first timestamp)
      playbackTimeRange = playbackArray.last[0] - playbackArray.first[0];

      // set initial marker (car)
      double lat = playbackArray.first[1];
      double lng = playbackArray.first[2];
      setPlaybackMarker(lat, lng);

      // set initial polyline
      LatLng latLng = LatLng(lat, lng);
      drawNextPolyline(latLng);

      // zoom to initial marker position
      moveCamera(latLng, 15);

      Navigator.pop(context);
    } else {
      // failed
      print("JAY playback failed = $resp");
    }
  }

  // function to for markers playback
  void setPlaybackMarker(double latitude, double longitude) {
    LatLng latLng = LatLng(latitude, longitude);
    var marker;

    //add/update marker to markersHM hashMap
    if (!markersHM.containsKey(deviceID)) {
      // create new marker
      marker = Marker(
        markerId: MarkerId(deviceID),
        position: latLng,
        infoWindow: InfoWindow(title: deviceName),
        onTap: () {},
        icon: BitmapDescriptor.fromAsset('images/redcar.png'),
        rotation: 0,
      );

      //add new marker to HM
      setState(() {
        markersHM[deviceID] = marker;
      });
    } else {
      //marker exists
      // get marker based on deviceID
      marker = markersHM[deviceID];

      // get old latLng first
      LatLng oldLatLng = marker.position;

      // only update marker position if got positional difference
      if (oldLatLng.latitude != latLng.latitude ||
          oldLatLng.longitude != latLng.longitude) {
        // update marker location and rotation (no animation)
        setState(() {
          markersHM[deviceID] = marker.copyWith(
            positionParam: latLng,
            rotationParam: getRotationAngle(oldLatLng, latLng),
          );
        });

        // camera follow marker if out of bounds
//        if (needAutoPan) {
//        moveCamera(latLng, 0);
        //        }
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

  //----- [END] ok btn function

  void cancelBtnFunc() {
    Navigator.pop(context);
    Navigator.pop(context);
  }

  //=====[END] btmsheet functions

  //===== playback functions
  void playbackBtn() {
    if (isPlaying) {
      // playing, pause
      pauseFunction();
    } else {
      // not playing, play
      startPlayback(true);
    }

    // update btn UI
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  // start playback function
  void startPlayback(bool needMoveCam) {
    // clear polyline if needed (replay)
    if (needResetPolyline) {
      polyHM.clear();
      needResetPolyline = false;
    }

    // get playback interval based on selected playback speed
    double interval = (1 - (playbackSpeed * 0.009)) * 1000;

    // start playback based on interval
    // this.playbackFunction();
    playbackTimer = Timer.periodic(
        Duration(milliseconds: interval.toInt()), playbackFunction);

    // zoom map to position if needed
    if (needMoveCam) {
      moveCamera(
          LatLng(
              playbackArray[currentIndex][1], playbackArray[currentIndex][2]),
          0);
    }
  }

  // play function
  void playbackFunction(Timer timer) {
    // reached end of playback
    if (currentIndex == playbackArray.length - 1) {
      stopPlayback();
      return;
    }

    // update input range value UI
    int nextTimestamp = playbackArray[currentIndex + 1][0];
    setState(() {
      playbackVal = (nextTimestamp - firstTimeStamp) / playbackTimeRange;
    });

    // update marker to map
    setPlaybackMarker(
      playbackArray[currentIndex][1],
      playbackArray[currentIndex][2],
    );

    // draw polyline if need
    if (needPolyline) {
      LatLng latlng = LatLng(
          playbackArray[currentIndex][1], playbackArray[currentIndex][2]);
      drawNextPolyline(latlng);
    }

    currentIndex++;
  }

  // pause function
  void pauseFunction() {
    playbackTimer.cancel();
  }

  // stop function
  void stopPlayback() {}

  void seekerBarOnChange(double value) {
    // don't do anything if no results yet
    if (playbackArray.length == 0) {
      return;
    }

    // pause playback first if playing
    if (isPlaying) {
      pauseFunction();
    }

    // update seekbar UI
    setState(() {
      playbackVal = value;
    });

    // set index based on playback value
    int firstTimestamp = playbackArray[0][0];
    double nextTimestamp =
        (playbackVal * playbackTimeRange + firstTimestamp);

    // loop playbackArray to get current position
    int currentTimeStamp;
    for (var i = 0; i < playbackArray.length - 1; i++) {
      currentTimeStamp = playbackArray[i][0];

      if (nextTimestamp <= currentTimeStamp.toDouble()) {
        //iteration reached index
        currentIndex = i;
        break;
      }
    }

    // start new polyline for skipped if need (show polyline btn selected)
    if (needPolyline) {
      drawSkipPolyline(currentIndex);
    }

    if (isPlaying) {
      startPlayback(true);
    }
  }

  // draw polyline (works for both new and next dot)
  void drawNextPolyline(LatLng latLng) {
    if (polyline == null) {
      // new polyline
      polyline = Polyline(
        polylineId: PolylineId(deviceID),
        color: MyColours.red,
        geodesic: true,
        width: 3,
        points: [latLng],
      );

      setState(() {
        polyHM[PolylineId(deviceID)] = polyline;
      });
    } else {
      // add to current polyline
      polyline = polyHM[PolylineId(deviceID)];
      polyline.points.add(latLng);

      setState(() {
        polyHM[PolylineId(deviceID)] = polyline;
      });
    }
  }

  // draw polyline for playback (skipped dots)
  void drawSkipPolyline(int index) {
    // remove all index after current index first
    var polylineArray = List.from(playbackArray);
    polylineArray.length = index + 1;
//    polylineArray.removeRange(index + 1, playbackArray.length - 1);

    // map array into list of latlngs only
    polylineArray =
        polylineArray.map((item) => LatLng(item[1], item[2])).toList();

    // make new polyline based on new array
    polyline = polyHM[PolylineId(deviceID)];

    setState(() {
        polyHM[PolylineId(deviceID)] =
            polyline.copyWith(pointsParam: polylineArray);
    });
  }

  void changeSpeed() {
    // pause playback if is playing
    if (isPlaying) {
      pauseFunction();
    }

    setState(() {
      // slow = 0
      // medium = 50 (default)
      // fast = 100
      switch (playbackSpeedText) {
        case "Slow":
          playbackSpeedText = "Medium";
          playbackSpeed = 50;
          break;

        case "Medium":
          playbackSpeedText = "Fast";
          playbackSpeed = 100;
          break;

        case "Fast":
          playbackSpeedText = "Slow";
          playbackSpeed = 0;
          break;
      }
    });

    // resume playback if was playing
    if (isPlaying) {
      startPlayback(false);
    }
  }

  // btm action btns (replay, hide, reset)
  void replayBtn() {
  }

  void showHideTrackBtn() {
    setState(() {
      needPolyline = !needPolyline;

      if (needPolyline) { // need draw polyline means tracks not shown yet
        drawSkipPolyline(currentIndex);
      } else { // no need draw polyline means tracks already showing
        drawSkipPolyline(playbackArray.length-1);
      }
    });
  }

  void resetPlaybackBtn() {
    showBtmSheet(context);
  }

  // zoom to latlng
  void moveCamera(LatLng latLng, double zoomLevel) {
    CameraUpdate cameraUpdate;
    if (zoomLevel > 0) {
      cameraUpdate = CameraUpdate.newLatLngZoom(latLng, zoomLevel);
    } else {
      cameraUpdate = CameraUpdate.newLatLng(latLng);
    }
    mapController.animateCamera(cameraUpdate);
  }
}
