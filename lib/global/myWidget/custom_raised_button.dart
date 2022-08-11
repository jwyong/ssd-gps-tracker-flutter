import 'package:flutter/material.dart';
import 'package:flutter_app/global/MyColours.dart';

class CustomRaisedButton extends StatelessWidget{
  final Function onPress;
  final Widget child;
  Color colour;

  CustomRaisedButton(this.onPress, this.child, this.colour);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SizedBox(
      width: double.infinity,
      child:
      RaisedButton(
        color: colour,
        shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(30.0),
        ),
        onPressed: this.onPress,
        child: this.child,
      ),
    );
  }

}