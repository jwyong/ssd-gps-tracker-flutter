import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/api/resp/accountResp.dart';
import 'package:flutter_app/customUI/MyExpansionTile.dart';
import 'package:flutter_app/global/MyColours.dart';
import 'package:flutter_app/secondary/playback.dart';

class ListAll extends StatefulWidget {
  final List<DeviceGrps> deviceGrps;

  // for getting params
  const ListAll(this.deviceGrps);

  @override
  ListAllState createState() => new ListAllState();
}

class ListAllState extends State<ListAll> {
  @override
  Widget build(BuildContext context) {
    var data = widget.deviceGrps;
    return new Scaffold(
        backgroundColor: Colors.white,
        body: new ListView.builder(
            itemCount: data == null ? 0 : data.length,
            itemBuilder: (BuildContext context, i) {
              // grp title + number of devices (Default Grp (3))
              var grpTitleStr = new Text(data[i].device_group_name +
                  " (" +
                  data[i].devices.length.toString() +
                  ")");

              return new MyExpansionTile(
                title: grpTitleStr,
                children: <Widget>[
                  new Column(
                    children: _buildExpandableContent(data[i].devices),
                  ),
                ],
                initiallyExpanded: i == 0,
              );
            }));
  }

  // for showing list in expandable tiles
  _buildExpandableContent(List<Devices> devicesList) {
    List<Widget> columnContent = [];

    for (Devices device in devicesList)
      columnContent.add(Padding(
          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Card(
              elevation: 0,
              color: MyColours.grey1,
              child: Padding(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Column(
                  children: <Widget>[
                    // top row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            // car icon
                            Icon(
                              const IconData(58673,
                                  fontFamily: 'MaterialIcons'),
                              color: MyColours.lightGreen1,
                              size: 35,
                            ),

                            // middle items
                            Padding(
                              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    device.device_name,
                                    style:
                                        TextStyle(color: MyColours.lightGreen1),
                                    textAlign: TextAlign.start,
                                  ),
                                  Text(
                                    device.imei,
                                    style: TextStyle(color: MyColours.grey2),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),

                        // right items
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 5, 5, 0),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: MyColours.lightGreen1,
                            ),
                          ),
                          child: Column(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                                color: MyColours.lightGreen1,
                                child: Text(
                                  "57 min",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                                child: Text(
                                  "ONLINE",
//                                      device.status.toString(),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),

                    // btm row
                    Padding(
                        padding: EdgeInsets.fromLTRB(0, 20, 0, 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            // buttons
                            rowBtns("Details", Playback.routeName, device.device_id),
                            rowBtns("Tracking", Playback.routeName, device.device_id),
                            rowBtns("Playback", Playback.routeName, device.device_id),

                            new Icon(const IconData(58836,
                                fontFamily: 'MaterialIcons'))
                          ],
                        ))
                  ],
                ),
              ))));

    return columnContent;
  }

  //===== widgets
  Expanded rowBtns(String btnLabel, String btnRouteName, String deviceID) {
    return Expanded(
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, btnRouteName, arguments: deviceID);
        },
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 0, horizontal: 2),
          alignment: Alignment(0, 0),
          decoration: BoxDecoration(
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

//===== [END] widgets
}
