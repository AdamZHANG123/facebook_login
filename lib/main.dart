import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(title: 'Facebook Login'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isLoggedIn = false;
  dynamic _data;

  void onLoginStatusChanged(bool isLoggedIn, {dynamic data}) {
    setState(() {
      _isLoggedIn = isLoggedIn;
      _data = data;
    });
  }

  void _initialFacebookLogin() async {
    var facebookLogin = FacebookLogin();
    var facebookLoginResult =
        await facebookLogin.logInWithReadPermissions(['email']);
    switch (facebookLoginResult.status) {
      case FacebookLoginStatus.error:
        print("Error");
        onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.cancelledByUser:
        print("CancelledByUser");
        onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.loggedIn:
        print("LoggedIn");

        var graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,picture&access_token=${facebookLoginResult.accessToken.token}');

        var profile = json.decode(graphResponse.body);
        print(profile.toString());

        onLoginStatusChanged(true, data: profile);
        break;
    }
  }

  Widget _showPicture() {
    if (_isLoggedIn && (_data != null)) {
      return Container(
        height: 200.0,
        width: 200.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            fit: BoxFit.fill,
            image: NetworkImage(
              _data['picture']['data']['url'],
            ),
          ),
        ),
      );
    } else {
      return Text('');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _isLoggedIn
                  ? Text('Logged In ${_data == null ? '' : _data['name']}')
                  : RaisedButton(
                      child: Text('Login with Facebook'),
                      onPressed: () {
                        _initialFacebookLogin();
                      },
                    ),
              SizedBox(
                height: 40,
              ),
              _showPicture(),
            ],
          ),
        ),
      ),
    );
  }
}
