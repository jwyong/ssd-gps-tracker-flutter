import 'package:configurable_expansion_tile/configurable_expansion_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/global/MyBanner.dart';
import 'package:flutter_app/global/MyColours.dart';
import 'package:flutter_app/global/MyRoutingBtn.dart';
import 'package:flutter_app/hometab/hometab.dart';
import 'package:flutter_app/secondary/playback.dart';

class HTBtmSheet extends StatefulWidget {
  final String deviceID;

  const HTBtmSheet(this.deviceID);

  @override
  State<StatefulWidget> createState() {
    return HTBtmSheetState();
  }
}

class HTBtmSheetState extends State<HTBtmSheet> {
  HTBtmSheetState();

  // UI states
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {},
        child: Container(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // green bg
              Container(
                child: devInfoTopRow(),
                color: MyColours.lightGreen1,
              ),

              // expandable devInfo
              ConfigurableExpansionTile(
                header: devInfoTopCard(),
                children: <Widget>[devInfoMidCard(), devUpdateCard()],
                onExpansionChanged: (bool expanded) {
                  setState(() {
                    isExpanded = expanded;
                  });
                },
              )
            ],
          ),
        ));
  }

  //--- Top row
  Row devInfoTopRow() {
    return Row(
      children: <Widget>[
        // left dev btn
        IconButton(
          icon: Icon(
            Icons.chevron_left,
            color: Colors.white,
          ),
          onPressed: leftDeviceBtn,
        ),

        // current device info
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "DEVICE NAME",
                style: TextStyle(color: Colors.white),
              ),
              Text(
                "DEVICE IMEI",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),

        // right dev btn
        IconButton(
          icon: Icon(Icons.chevron_right, color: Colors.white),
          onPressed: rightDeviceBtn,
        ),
      ],
    );
  }

  // left device btn
  void leftDeviceBtn() {
    print("LEFT DEV");
  }

  // right device btn
  void rightDeviceBtn() {
    print("RIGHT DEV");
  }

//--- [END] top row

  // first card
  Expanded devInfoTopCard() {
    return Expanded(
      child: Card(
        elevation: 0,
        color: MyColours.grey1,
        margin: EdgeInsets.fromLTRB(15, 5, 15, 5),
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              // box with diagonal banner
              bannerBox(),

              // right side infos
              Padding(
                padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    //top row
                    Row(
                      children: <Widget>[
                        devStatus(Icons.power_settings_new, "ON"),
                        isExpanded
                            ? Icon(Icons.keyboard_arrow_up)
                            : Icon(Icons.keyboard_arrow_down),
                      ],
                    ),

                    // btm row (expandable)
                    Row(
                      children: <Widget>[
                        // action btns
                        MyRoutingBtn(
                            Playback.routeName,
                            "Tracking",
                            MyColours.lightGreen1,
                            Colors.white,
                            widget.deviceID),
                        Padding(
                          padding: EdgeInsets.all(5),
                        ),
                        MyRoutingBtn(Playback.routeName, "Playback",
                            MyColours.darkBlue2, Colors.white, widget.deviceID),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // second card
  Card devInfoMidCard() {
    return Card(
      color: MyColours.grey1,
      elevation: 0,
      margin: EdgeInsets.fromLTRB(15, 0, 15, 5),
      child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // first row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  devInfoIcons(Icons.description, "Detail"),
                  devInfoIcons(Icons.warning, "Alerts"),
                  devInfoIcons(Icons.public, "Geo Fence"),
                  devInfoIcons(Icons.navigation, "Navigate"),
                ],
              ),

              Padding(
                padding: EdgeInsets.all(3),
              ),
              // 2nd row
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  devInfoIcons(Icons.share, "Share"),
                  Expanded(
                    child: Text(""),
                  ),
                  Expanded(
                    child: Text(""),
                  ),
                  Expanded(
                    child: Text(""),
                  ),

//                  Column(
//                    children: <Widget>[
//                      Icon(Icons.share),
//                      Text("Share"),
//                    ],
//                  ),
                ],
              )
            ],
          )),
    );
  }

  // third card
  Card devUpdateCard() {
    return Card(
      color: MyColours.grey1,
      elevation: 0,
      margin: EdgeInsets.fromLTRB(15, 0, 15, 5),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Row(
          children: <Widget>[
            devUpdateItem(Icons.location_on, "2019-01-08 15:03:28",
                "Last Positioning", true),
            devUpdateItem(
                Icons.sync, "2019-02-07 15:34:22", "Last Update", false),
          ],
        ),
      ),
    );
  }

  // third card items
  Expanded devUpdateItem(
      IconData icon, String topText, String btmText, bool gotAddress) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            icon,
            color: MyColours.lightBlue2,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                devUpdateItmTxt(topText),
                devUpdateItmTxt(btmText),
                Visibility(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                    child: Text(
                      "View Address",
                      style:
                          TextStyle(color: MyColours.lightBlue2, fontSize: 10),
                    ),
                  ),
                  visible: gotAddress,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // third card text
  Text devUpdateItmTxt(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 12, color: MyColours.grey2),
    );
  }

  //banner box
  Container bannerBox() {
//    return MyBanner(
//      textDirection: TextDirection.ltr,
//      location: BannerLocation.topEnd,
//      message: "GPS",
//      child:

    return Container(
      width: 80,
      height: 80,
      child: Center(
        child: Text("40 km/h"),
      ),
      decoration:
          BoxDecoration(border: Border.all(color: MyColours.lightGreen1)),
    );
//      color: MyColours.lightGreen1,
//    );
  }

  // device status
  Row devStatus(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          icon,
          color: MyColours.grey3,
        ),
        Padding(
          padding: EdgeInsets.all(2),
        ),
        Text(
          label,
          style: TextStyle(color: MyColours.grey3),
        ),
      ],
    );
  }

  //--- [END] first card

  //--- second card
  Expanded devInfoIcons(IconData icon, String iconLabel) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Icon(
            icon,
            size: 25,
            color: MyColours.grey2,
          ),
          Text(
            iconLabel,
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

//--- [END] second card

//=== widgets for marker btm sheet
}
