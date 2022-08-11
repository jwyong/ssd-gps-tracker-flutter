import 'package:flutter/material.dart';
import 'package:flutter_app/api/resp/accountResp.dart';
import 'package:flutter_app/global/MyColours.dart';
import 'package:flutter_app/listtab/listAll.dart';

class ListTab extends StatefulWidget {
  final Account account;

  const ListTab(this.account);

  @override
  ListTabState createState() => new ListTabState();
}

// Create a tab controller
TabController controller;

class ListTabState extends State<ListTab> with SingleTickerProviderStateMixin {
  // for swipe down refresh
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

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
    List<DeviceGrps> deviceGrps = new List();
    if (widget.account != null) {
      deviceGrps = widget.account.device_groups;
    }

    return RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: refreshAction,
        child: new Scaffold(
          appBar: new AppBar(
              title: Text(widget.account == null
                  ? "Account Name"
                  : widget.account.account_name),
              centerTitle: true,
              backgroundColor: MyColours.darkBlue1,
              bottom: new TabBar(controller: controller, tabs: <Tab>[
                new Tab(
                  child: Text(
                    "All (3)",
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
                new Tab(
                  child: Text(
                    "Online (3)",
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
                new Tab(
                  child: Text(
                    "Offline (3)",
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
                new Tab(
                  child: Text(
                    "Inactive (3)",
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              ])),
          body: new TabBarView(controller: controller, children: <Widget>[
            new ListAll(
//            widget.account.device_groups,
              deviceGrps,
            ),
            new ListAll(
              deviceGrps,
            ),
            new ListAll(
              deviceGrps,
            ),
            new ListAll(
              deviceGrps,
            ),
          ]),
        ));
  }

  // function for on refresh
  Future<Null> refreshAction() {
    print("JAY refresh");
  }
}
