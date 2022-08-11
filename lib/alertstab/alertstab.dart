import 'package:flutter/material.dart';
import 'package:flutter_app/global/MyColours.dart';

const double _ITEM_HEIGHT = 200.0;

class AlertsTab extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _AlertsTab();
  }
}

class Alert {
  bool selected = false;
  String id;

  Alert(this.id);
}

class _AlertsTab extends State<AlertsTab> {
  final _scrollController = new ScrollController();
  List<Alert> list = [
    Alert("111111111"),
    Alert("122121212"),
    Alert("12345672"),
    Alert("2222222")
  ];
  List<Alert> tempList = new List();
  List<Alert> removeList = new List();

  bool inputOnclick = false;
  final _searchNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    List<String> getDateTime() {
      var now = new DateTime.now();
      String date = "${now.year}-${now.month}-${now.day}";
      String time = "${now.hour}:${now.minute}:${now.second}";
      return [date, time];
    }

    void scrollToPosition() {
      for (int i = 0; i < this.list.length; i++) {
        for (int j = 0; j < this.removeList.length; j++) {
          if (this.list[i] == this.removeList[j]) {
            this.list.remove(this.list[i]);
          }
        }
      }
      setState(() {});
//      _scrollController.animateTo(5 * _ITEM_HEIGHT, duration: Duration(seconds: 1), curve: Curves.ease);
    }

    void changeIcon(Alert alert) {
      alert.selected = !alert.selected;
      if (alert.selected) {
        removeList.add(alert);
      } else {
        removeList.remove(alert);
      }
      setState(() {});
    }

    Widget item(Alert alert, String date, String time, bool last) {
      double marginBtm = last ? 20 : 0;
      List<String> dateTime = getDateTime();
      return Stack(
        children: <Widget>[
          Container(
//          height: _ITEM_HEIGHT,
              padding: EdgeInsets.fromLTRB(20, 20, 20, marginBtm),
              child: Material(
                color: Colors.grey[200],
                child: InkWell(
                  onLongPress: () => changeIcon(alert),
                  onTap: () {},
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.fromLTRB(20, 20, 20, 20),
                        child: Row(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.fromLTRB(0, 0, 20, 0),
                              child: Icon(
                                alert.selected
                                    ? Icons.desktop_windows
                                    : Icons.warning,
                                color: Colors.red,
                                size: 36,
                              ),
                            ),
                            Text(
                              "Geofence Alert",
                              style: TextStyle(color: Colors.red, fontSize: 25),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
                        padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                        color: Colors.white,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                Text(
                                  "Tracksolid Platform",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(alert.id),
                              ],
                            ),
                            Container(
                              padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                              decoration: BoxDecoration(
                                  border: BorderDirectional(
                                      start:
                                          BorderSide(color: Colors.grey[300]))),
                              child: Column(
                                children: <Widget>[
                                  Text(
                                    dateTime[1],
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(dateTime[0]),
                                ],
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )),
          alert.selected
              ? InkWell(
                  onTap: () => changeIcon(alert),
                  child: Container(
                    color: Colors.blue.withOpacity(0.5),
                    height: _ITEM_HEIGHT,
                  ),
                )
              : Container()
        ],
      );
    }

    buildItemList(String val) {
      List<Alert> _list = new List();
      for (int i = 0; i < this.list.length; i++) {
        if (this.list[i].id.contains(val)) {
          _list.add(this.list[i]);
        }
      }
      tempList = _list;
      print(_list.length);
      setState(() {});
    }

    Widget getTextField() {
      FocusScope.of(context).requestFocus(_searchNode);
      return Container(
        padding: EdgeInsets.fromLTRB(10, 5, 5, 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: Colors.white,
        ),
        child: TextField(
          onChanged: (val) {
            buildItemList(val);
          },
          onEditingComplete: () {
            FocusScope.of(context).requestFocus(new FocusNode());
            tempList.clear();
            setState(() {
              inputOnclick = !inputOnclick;
            });
          },
          focusNode: _searchNode,
          decoration: InputDecoration.collapsed(
            hintText: '',
          ),
        ),
      );
    }

    Widget state1 = InkWell(
      onTap: () {
        setState(() {
          inputOnclick = !inputOnclick;
        });
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: Colors.white,
        ),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: Icon(
                Icons.search,
                color: Colors.grey,
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: Text(
                "IMEI / Device Name",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            )
          ],
        ),
      ),
    );

    return Scaffold(
        appBar: AppBar(
          backgroundColor: MyColours.darkBlue1,
          automaticallyImplyLeading: false,
          title: inputOnclick ? getTextField() : state1,
          leading: Container(),
          actions: <Widget>[
            IconButton(
              onPressed: scrollToPosition,
              icon: Icon(Icons.delete),
            ),
          ],
        ),
        body: Container(
          child: ListView.builder(
              controller: _scrollController,
              itemCount: this.tempList.length == 0
                  ? this.list.length
                  : this.tempList.length,
              itemBuilder: (context, positon) {
                Alert alert = this.tempList.length == 0
                    ? this.list[positon]
                    : this.tempList[positon];
                return item(alert, "1", "1", (positon == this.list.length - 1));
              }),
        ));
  }
}
