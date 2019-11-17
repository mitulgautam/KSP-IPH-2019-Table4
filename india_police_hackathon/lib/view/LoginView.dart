import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:india_police_hackathon/core/provider/LoginProvider.dart';
import 'package:india_police_hackathon/resources/ConstantData.dart';
import 'package:india_police_hackathon/view/shared/CustomSpacer.dart';
import 'package:provider/provider.dart';

class LoginView extends StatefulWidget {
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ChangeNotifierProvider.value(
      value: ConstantData.loginProvider,
      child: Consumer<LoginProvider>(
        builder: (_, model, __) => Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xffc850c0), Color(0xff4158d0)],
              ),
            ),
            child: Center(
              child: Container(
                padding: EdgeInsets.all(16.0),
                margin: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  color: Colors.white,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        SizedBox(
                          width: size.width * .3,
                          child: Image.asset('assets/images/logo.png'),
                        ),
                        Text(
                          "Karnataka Police",
                          style: TextStyle(
                              fontSize: size.width / 18,
                              fontWeight: FontWeight.bold),
                        ),
                        CustomSpacer.verySmallSpace(),
                      ],
                    ),
                    Form(
                      key: model.loginKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          TextFormField(
                            controller: model.userID,
                            maxLength: 10,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              WhitelistingTextInputFormatter.digitsOnly
                            ],
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(32.0)),
                              labelText: 'Enter your ID',
                              icon: Icon(
                                Icons.person_outline,
                                color: Colors.brown,
                              ),
                            ),
                            autovalidate: model.isLoginClicked,
                            validator: (_) {
                              if (_.length < 10) return 'Enter a valid ID';
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 8.0,
                          ),
                          TextFormField(
                            controller: model.userPIN,
                            maxLength: 4,
                            autovalidate: model.isLoginClicked,
                            validator: (_) {
                              if (_.length < 4)
                                return 'Please enter a valid PIN';
                              return null;
                            },
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              WhitelistingTextInputFormatter.digitsOnly
                            ],
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(32.0)),
                              labelText: 'Enter PIN',
                              icon: Icon(
                                Icons.security,
                                color: Colors.brown,
                              ),
                            ),
                          ),
                          MaterialButton(
                            minWidth: size.width / 4,
                            height: size.width / 12,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32.0)),
                            onPressed: () {
                              model.isLoginClicked = true;
                              print(model.userPIN.text);
                              print(model.userID.text);
                              if (model.userID.text == '1111111111' &&
                                  model.userPIN.text == '1111')
                                Navigator.of(context)
                                    .pushReplacementNamed('/dashboard');
                            },
                            child: Text(
                              "Login",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 20.0),
                            ),
                            color: Colors.brown,
                            elevation: 0.0,
                          ),
                          FlatButton(
                              onPressed: () {
                                print(
                                    "PIN has been send to your registered mobile number.");
                                showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                          title: Text("Forgot Password"),
                                          content: TextFormField(
                                            decoration: InputDecoration(
                                                hintText:
                                                    "Please enter your ID"),
                                          ),
                                          actions: <Widget>[
                                            FlatButton(
                                              child: Text("Confirm"),
                                              onPressed: () {
                                                Navigator.pop(context);
                                                showDialog(
                                                    context: context,
                                                    builder: (_) => AlertDialog(
                                                          title: Text(
                                                              "Notification"),
                                                          content: Text(
                                                              "PIN has been send to your registered mobile number."),
                                                          actions: <Widget>[
                                                            FlatButton(
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                      context),
                                                              child: Text("OK"),
                                                            )
                                                          ],
                                                        ));
                                              },
                                            )
                                          ],
                                        ));
                              },
                              child: Text("Forogt your password!"))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
