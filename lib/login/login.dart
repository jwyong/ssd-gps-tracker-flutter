import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/api/resp/accountResp.dart';
import 'package:flutter_app/global/MyColours.dart';
import 'package:flutter_app/global/myWidget/custom_raised_button.dart';
import 'package:flutter_app/global/myWidget/custom_scrollable_center_container.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/maintabs.dart';
import 'package:flutter_app/login/forgot_password.dart';
import 'package:flutter_app/global/myWidget/custom_text_field.dart';

// http posting
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginState();
  }
}

class _LoginState extends State<Login> {
  bool isLoginBtnEnabled = true;
  bool _isChecked;
  final emailNode = FocusNode();
  final passwordNode = FocusNode();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _emailCheck;
  String emailErrorMessage;

  bool _passwordCheck;
  String passwordErrorMessage;

  @override
  void initState() {
    super.initState();
    _isChecked = false;
    _emailCheck = false;
    _passwordCheck = false;
  }

  @override
  Widget build(BuildContext context) {
    Widget rememberMe = Container(
        child: Row(
      children: <Widget>[
        Checkbox(
          value: _isChecked,
          onChanged: (bool newValue) {
            setState(() {
              _isChecked = !_isChecked;
            });
          },
        ),
        AutoSizeText('Remember me', style: TextStyle(color: Colors.white))
      ],
    ));

    bool isEmailAddressValid(String email) {
      RegExp exp = new RegExp(
        r"^[\w-.]+@([\w-]+.)+[\w-]{2,4}$",
        caseSensitive: false,
        multiLine: false,
      );
      return exp.hasMatch(email.trim());
      // we trim to remove trailing white spaces
    }

    void goToPasswordField(val) {
      FocusScope.of(context).requestFocus(passwordNode);
    }

    bool emailValidate() {
      bool vaildate = false;
      String email = _emailController.text;
      if (email.isEmpty) {
        emailErrorMessage = "Email is required";
        vaildate = true;
      } else {
        if (isEmailAddressValid(email)) {
          vaildate = false;
        } else {
          emailErrorMessage = "Invalid email format";
          vaildate = true;
        }
      }

      setState(() {
        _emailCheck = vaildate;
      });
      return vaildate;
    }

    bool passwordValidate() {
      bool vaildate = false;
      if (_passwordController.text.isEmpty) {
        passwordErrorMessage = "Password is required";
        vaildate = true;
      } else {
        vaildate = false;
      }

      setState(() {
        _passwordCheck = vaildate;
      });

      return vaildate;
    }

    // when click on login btn, validate input fields then login
    void loginFunc() {
      print("JAY loginFunc");

      // disable login btn first
      setState(() {
        isLoginBtnEnabled = false;
      });

      // post to login end-point
      this.postToLogin().then(loginResp);
    }

    return Scaffold(
      body: CustomScrollableCenterContainer(
          MyColours.darkBlue1,
          Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(30),
                child: Image(
                  image: AssetImage('assets/images/logo_512.png'),
                ),
              ),

              CustomTextField(
                  "EMAIL / USERNAME",
                  Icons.email,
                  emailNode,
                  goToPasswordField,
                  TextInputAction.next,
                  null,
                  _emailController,
                  TextInputType.emailAddress,
                  false),
              _emailCheck
                  ? Text(
                      emailErrorMessage,
                      style: TextStyle(color: Colors.red),
                    )
                  : Container(),
              Divider(
                color: Colors.transparent,
              ),

              CustomTextField(
                  "PASSWORD",
                  Icons.lock,
                  passwordNode,
                  null,
                  TextInputAction.done,
                  null,
                  _passwordController,
                  TextInputType.text,
                  true),
              _passwordCheck
                  ? Text(
                      passwordErrorMessage,
                      style: TextStyle(color: Colors.red),
                    )
                  : Container(),

              // remember me/ forgot pword
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  rememberMe,
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, ForgotPassword.routeName);
                    },
                    child: AutoSizeText(
                      "Forgot Password",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
              Divider(
                color: Colors.transparent,
              ),

              // login
              CustomRaisedButton(
                  isLoginBtnEnabled ? loginFunc : null,
                  Center(
                    heightFactor: 1.5,
                    child: Text(
                      'LOGIN',
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ),
                  ),
                  isLoginBtnEnabled ? MyColours.lightBlue2 : MyColours.grey1)
            ],
          ),
          EdgeInsets.fromLTRB(40, 0, 40, 0)),
    );
  }

  //function for getting devices from server
  Future<http.Response> postToLogin() async {
    String url = 'https://gps2.soappchat.com/api/test_1b';

    try {
      print("JAY postToLogin");

      var response = await http
          .get(Uri.encodeFull(url), headers: {"Accept": "application/json"});

      return response;
    } catch (e) {
      print("JAY e = $e");
    }
  }

  void loginResp(http.Response resp) async {
    if (resp.statusCode == 200) {
      // success
      print("JAY success");
      final respStr = json.decode(resp.body);

      // pass variables to next screen (close current screen)
      Account account = new Account.fromJson(respStr);
      Navigator.of(context).pushNamedAndRemoveUntil(
          MainTabs.routeName, (Route<dynamic> route) => false,
          arguments: account);
    } else {
      // failed
      print("JAY failed");

      // re-enable login btn
      setState(() {
        isLoginBtnEnabled = true;
      });
    }
  }

  void loginError(Exception e) {
    print("JAY ex = $e");
  }
}
