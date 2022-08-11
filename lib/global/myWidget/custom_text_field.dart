import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final FocusNode node;
  final Function onFieldSubmitted;
  final TextInputAction textInputAction;
  final Function validator;
  final TextEditingController controller;
  final TextInputType textInputType;
  final bool obscureText;

  CustomTextField(this.hintText, this.icon, this.node, this.onFieldSubmitted,
      this.textInputAction, this.validator, this.controller, this.textInputType,
      this.obscureText);

  @override
  Widget build(BuildContext context) {
    return
    Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50.0),
          color: Colors.white
      ),
      child: TextFormField(
        obscureText: this.obscureText,
        keyboardType: this.textInputType,
        controller: this.controller,
        validator: this.validator,
        textInputAction: this.textInputAction,
        onFieldSubmitted: this.onFieldSubmitted,
        focusNode: this.node,
        decoration: InputDecoration(
          prefixIcon: Icon(this.icon),
          hintText: this.hintText,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50.0)
          ),
        ),
      ),
    );
  }
}