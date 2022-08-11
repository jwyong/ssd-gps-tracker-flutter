import 'dart:collection';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/global/MyColours.dart';
import 'package:flutter_app/global/strings.dart' as Globals;

// gmaps
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_google_places/flutter_google_places.dart';

// for calculations of geofence
import 'dart:math';

import 'package:google_maps_webservice/places.dart';

class GeoFenceActi extends StatefulWidget {
  static const String routeName = "/geofenceacti";

  @override
  GeoFenceActiState createState() => new GeoFenceActiState();
}

class GeoFenceActiState extends State<GeoFenceActi> {
  // for gmaps
  GoogleMapController mapController;
  final homeScaffoldKey = GlobalKey<ScaffoldState>();
  GoogleMapsPlaces gPlaces = GoogleMapsPlaces(apiKey: Globals.gMapsAPIKey);
  Map<String, Marker> markersHM = new HashMap();

  //--- for radius seeker bar
  // seekerbar value from 0 to 100
  double radiusSeekbarVal = 0;

  // actual radius in m to be send to sever (e.g. 200m, 500m, 3000m, etc)
  double radiusMeterVal = 200;

  // radius on map based on zoom level of user
  double radiusMapVal = 0;

  // map zoom distance based on zoom level (meters per pixel)
  double mapZoomRatio;

//  double metersPerPixel = (pow(0.5, 7.0) * 1183315101);

  //--- [END] for radius seeker bar

  //enter/exit checkbox
  bool enterChecked = false;
  bool exitChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColours.darkBlue1,
        title: searchBar(),
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          // main map bg with controls below
          mainMapBG(),

          // seekbar for geofence radius
          radiusSeekBar(),
        ],
      ),
    );
  }

  //===== for search bar
  // search bar widget in titlebar
  InkWell searchBar() {
    return InkWell(
        onTap: showGMapsSearchBar,
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.only(right: 20),
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20), color: Colors.white),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.search,
                color: MyColours.grey2,
              ),
              Text(
                "Search Location",
                style: TextStyle(color: MyColours.grey2, fontSize: 16),
              )
            ],
          ),
        ));
  }

  // go to new page with google search func
  Future<void> showGMapsSearchBar() async {
    try {
      Prediction p = await PlacesAutocomplete.show(
        context: context,
        apiKey: Globals.gMapsAPIKey,
        onError: onSearchError,
        mode: Mode.fullscreen,
        language: "en",
        components: [Component(Component.country, "my")],
      );

      getPlaceDetails(p.placeId);
    } catch (e) {
      SnackBar(content: Text(e.errorMessage));
      return;
    }
  }

  void onSearchError(PlacesAutocompleteResponse response) {
    homeScaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text(response.errorMessage)),
    );
  }

  // get place details based on placeID chosen from autocomplete list
  Future<Null> getPlaceDetails(String placeId) async {
    if (placeId != null) {
      PlacesDetailsResponse place = await gPlaces.getDetailsByPlaceId(placeId);

      if (place.status == "OK") {
        setState(() {
          // delete old marker
          markersHM.clear();

          // create new marker
          double lat = place.result.geometry.location.lat;
          double lng = place.result.geometry.location.lng;
          LatLng position = LatLng(lat, lng);

          markersHM[placeId] = Marker(
            markerId: MarkerId(placeId),
            position: position,
            infoWindow: InfoWindow(title: place.result.formattedAddress),
          );

          // zoom to new marker
          CameraUpdate cameraUpdate = CameraUpdate.newLatLngZoom(position, 15);
          mapController.animateCamera(cameraUpdate);
        });
      } else {
        print("JAY gPlace error");
      }
    }
  }

  //===== [END] for search bar

  // main map bg
  Column mainMapBG() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        //gmaps
        Expanded(
          child: Stack(
            children: <Widget>[
              GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: const CameraPosition(
                  target: LatLng(3.2378778, 101.6734017),
                  zoom: 7.0,
                ),
                onCameraMove: onMapCamMove,
                markers: Set<Marker>.of(markersHM.values),
              ),

              // circle in middle of map
              IgnorePointer(
                child: Center(
                  child: Container(
                    width: 2 * radiusMapVal,
                    height: 2 * radiusMapVal,
                    decoration: BoxDecoration(
                      color: MyColours.redA70,
                      border: Border.all(color: MyColours.red),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),

              // car icon in middle of map
              Center(
                child: Icon(
                  Icons.brightness_1,
                  color: MyColours.lightGreen1,
                ),
              ),
            ],
          ),
        ),

        // btm controls
        Card(
          elevation: 0,
          margin: EdgeInsets.fromLTRB(15, 15, 15, 0),
          color: MyColours.grey1,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: btmGreyCard(),
          ),
        ),

        // save btn
        Container(
            margin: EdgeInsets.symmetric(horizontal: 50, vertical: 5),
            child: RaisedButton(
              onPressed: () {},
              child: Text(
                "SAVE",
                style: TextStyle(color: Colors.white),
              ),
              color: MyColours.lightBlue2,
            )),
      ],
    );
  }

  //btm control card
  Column btmGreyCard() {
    return Column(
      children: <Widget>[
        // geofence name
        Row(
          children: <Widget>[
            Icon(
              Icons.public,
              color: MyColours.lightBlue2,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
              child: AutoSizeText("GeoFence Name"),
            )
          ],
        ),

        // add/edit btns
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: <Widget>[
              addEditBtns("Edit", ""),
              addEditBtns("Add Device", "")
            ],
          ),
        ),

        // alert settings row
        Container(
          margin: EdgeInsets.symmetric(horizontal: 5),
          color: Colors.white,
          child: Table(
            columnWidths: {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(1.4),
              2: FlexColumnWidth(1.4)
            },
//            defaultColumnWidth: IntrinsicColumnWidth(),
            border: TableBorder.all(),
            children: [
              TableRow(children: [
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Text(
                    "Alert Settings",
                    textAlign: TextAlign.center,
                  ),
                ),
                TableCell(
                  child: enterExitRow("Enter", 1),
                ),
                TableCell(
                  child: enterExitRow("Exit", 2),
                ),
              ])
            ],
          ),
        )
      ],
    );
  }

  // add/edit btns
  Expanded addEditBtns(String btnLabel, String btnRouteName) {
    return Expanded(
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, btnRouteName);
        },
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
          alignment: Alignment(0, 0),
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: MyColours.grey2),
              borderRadius: BorderRadius.circular(3)),
          child: Padding(
            padding: EdgeInsets.all(5),
            child: AutoSizeText(btnLabel),
          ),
        ),
      ),
    );
  }

  // enter/exit btns
  InkWell enterExitRow(String label, int type) {
    return InkWell(
      onTap: () {
        setState(() {
          type == 1 ? enterChecked = !enterChecked : exitChecked = !exitChecked;
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // round checkbox
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: type == 1
                  ? enterChecked
                      ? Icon(Icons.check_circle_outline)
                      : Icon(Icons.radio_button_unchecked)
                  : exitChecked
                      ? Icon(Icons.check_circle_outline)
                      : Icon(Icons.radio_button_unchecked)),

          // text
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: AutoSizeText(label),
          )
        ],
      ),
    );
  }

  // geofence seekerbar
  Column radiusSeekBar() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          margin: EdgeInsets.all(10),
          color: Colors.white,
          padding: EdgeInsets.all(10),
          child: Row(
            children: <Widget>[
              // minus btn
              seekbarBtn(Icons.remove_circle, radiusMinusBtn),

              // 200m text
              seekbarText(radiusMeterVal.round().toString() + "m", true),

              // playback seekerbar
              Expanded(
                child: Slider(
                  value: radiusSeekbarVal,
                  onChanged: (double value) => radiusSeekbarOnChange(value),
                  inactiveColor: MyColours.grey1,
                ),
              ),

              // 200m text
              seekbarText("5km", false),

              // add btn
              seekbarBtn(Icons.add_circle, radiusPlusBtn),
            ],
          ),
        )
      ],
    );
  }

  // seekbar btn
  InkWell seekbarBtn(IconData icon, Function onTap) {
    return InkWell(
      onTap: onTap,
      child: Icon(
        icon,
        color: MyColours.lightBlue2,
        size: 25,
      ),
    );
  }

  // seekbar text
  Padding seekbarText(String text, bool leftOnly) {
    return Padding(
      padding: leftOnly ? EdgeInsets.only(left: 5) : EdgeInsets.only(right: 5),
      child: AutoSizeText(text),
    );
  }

  //===== functions
  void _onMapCreated(GoogleMapController controller) {
    this.mapController = controller;

    // set map zoom ratio
    mapZoomRatio = 156543.03392 * cos(3.2378778 * pi / 180) / pow(2, 7.0);
  }

  void onMapCamMove(CameraPosition camPos) {
    setState(() {
      // y = 118...(0.5^x)
//      mapZoomDist = (pow(0.5, camPos.zoom) * 1183315101);

      // set map zoom ratio (meter / pixel)
      mapZoomRatio = 156543.03392 *
          cos(camPos.target.latitude * (pi / 180)) /
          pow(2, camPos.zoom);

      // set map radius val
      radiusMapVal = radiusMeterVal / mapZoomRatio;
    });
  }

  //----- for radius seekbar
  // radius minus/plus btns
  void radiusMinusBtn() {
    print("JAY minus");
  }

  void radiusPlusBtn() {
    print("JAY plus");
  }

  void radiusSeekbarOnChange(double value) {
    setState(() {
      // set seeker bar
      radiusSeekbarVal = value;

      // set server value in m (seeker 1 step = 48m, 1 step = 0.01, initial = 200m)
      radiusMeterVal = value * 4800 + 200;

      //=== set map radius val
      // get pixels based on radius set in m and mapZoomRatio
      radiusMapVal = radiusMeterVal / mapZoomRatio;
    });
  }
}
