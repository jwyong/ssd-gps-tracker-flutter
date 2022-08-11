import 'package:flutter/material.dart';
import 'package:flutter_app/global/MyColours.dart';
import 'package:flutter_app/global/myWidget/custom_raised_button.dart';
import 'package:flutter_app/global/myWidget/custom_scrollable_center_container.dart';
import 'package:flutter_app/global/myWidget/custom_text_field.dart';
import 'package:flutter_app/global/strings.dart' as globals;

class ForgotPassword extends StatefulWidget {
  static const String routeName = "/forgot_password";

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ForgotPassword();
  }
}

class _ForgotPassword extends State<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: MyColours.darkBlue1,
        title: Text('Forgot Password'),
      ),
      body: CustomScrollableCenterContainer(
          MyColours.darkBlue1,
          Column(
            children: <Widget>[
              Divider(
                color: Colors.transparent,
              ),
              CustomTextField(
                  "EMAIL",
                  Icons.email,
                  null,
                  null,
                  TextInputAction.next,
                  null,
                  null,
                  TextInputType.emailAddress,
                  false),
              Divider(
                color: Colors.transparent,
              ),
              CustomTextField(
                  "VERIFICATION CODE",
                  Icons.security,
                  null,
                  null,
                  TextInputAction.next,
                  null,
                  null,
                  TextInputType.number,
                  false),
              Divider(
                color: Colors.transparent,
              ),
              CustomTextField("PASSWORD", Icons.lock, null, null,
                  TextInputAction.next, null, null, TextInputType.text, true),
              Divider(
                color: Colors.transparent,
              ),
              CustomTextField("CONFIRM PASSWORD", Icons.check_box, null, null,
                  TextInputAction.next, null, null, TextInputType.text, true),
              Divider(
                color: Colors.transparent,
              ),
              Divider(
                color: Colors.transparent,
              ),
              CustomRaisedButton(
                  () {},
                  Center(
                    heightFactor: 1.5,
                    child: Text(
                      'SUBMIT',
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ),
                  ),
                  MyColours.lightBlue2),
              Divider(
                color: Colors.transparent,
              ),
              Divider(
                color: Colors.transparent,
              ),
              SizedBox(
                width: double.infinity,
                child: Text(
                  globals.forgotPasswordDescription,
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              Divider(
                color: Colors.transparent,
              ),
            ],
          ),
          EdgeInsets.fromLTRB(40, 0, 40, 0)),
    );
  }
}
