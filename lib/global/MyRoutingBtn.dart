import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class MyRoutingBtn extends StatelessWidget{
  final String btnRouteName;
  final String btnLabel;
  final Color bgColour;
  final Color btnLabelColor;
  final String id;

  MyRoutingBtn(this.btnRouteName, this.btnLabel, this.bgColour, this.btnLabelColor, this.id);

  @override
  Widget build(BuildContext context) {
      return RaisedButton(
        onPressed: () {
          Navigator.pushNamed(context, btnRouteName, arguments: id);
        },
        color: bgColour,
        child: AutoSizeText(btnLabel, style: TextStyle(color: btnLabelColor),),
      );
  }
}