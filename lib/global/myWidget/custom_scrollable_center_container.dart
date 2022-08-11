import 'package:flutter/material.dart';

class CustomScrollableCenterContainer extends StatelessWidget{
  final Widget child;
  final Color color;
  final EdgeInsets padding;

  CustomScrollableCenterContainer(this.color, this.child, this.padding);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      color: this.color,
      padding: this.padding,
      child: Center(
        child: SingleChildScrollView(
          child: this.child,
        ),
      ),
    );
  }

}