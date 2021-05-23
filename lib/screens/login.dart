import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:vocab/services/authenticaation.dart';
import 'package:vocab/util/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:progress_dialog/progress_dialog.dart';

class Login extends StatefulWidget {
  const Login({Key key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  ProgressDialog pr;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Authentication authentication = Authentication();
  bool isLoggedIn = false;
  bool showProgressBar = true;
  bool disableButton = false;

  @override
  void initState() {
    super.initState();
    checkIfAlreadyLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: true);
    styleDialog(pr);
    return Scaffold(
      backgroundColor: primaryColor,
      body: Container(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Center(
                child: TextButton.icon(
                    onPressed: disableButton
                        ? null
                        : () {
                            setState(() {
                              disableButton = true;
                            });
                            proceedGoogleLogin();
                          },
                    style: ButtonStyle(
                        backgroundColor: disableButton
                            ? MaterialStateProperty.all(googleButtonText)
                            : MaterialStateProperty.all(googleButtonBg)),
                    icon: Icon(
                      EvaIcons.google,
                      color: googleButtonText,
                    ),
                    label: Text(
                      'Sign in with Google',
                      style: TextStyle(color: googleButtonText),
                    )),
              ),
              SizedBox(
                height: 10,
              ),
              Center(
                child: SizedBox(
                  width: 50,
                  child: showProgressBar
                      ? LinearProgressIndicator(
                          backgroundColor: primaryColor,
                          minHeight: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(googleButtonText),
                        )
                      : SizedBox(
                          width: 50,
                        ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Center(
                child: Text(
                  'Google sign in is required to store your data',
                  style: TextStyle(
                      fontSize: 14, letterSpacing: 1.5, color: googleButtonBg),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void proceedGoogleLogin() async {
    pr.show();
    bool isUserLogged = await authentication.googleSignIn(_prefs);
    if (isUserLogged) {
      pr.hide();
      Navigator.pushReplacementNamed(context, '/home', arguments: {
        'email': authentication.getEmail(),
        'freshLogin': true,
        'userId': authentication.getUserId()
      });
    }
  }

  void checkIfAlreadyLoggedIn() {
    _prefs.then((SharedPreferences prefs) {
      bool loggedIn = prefs.getBool('isLoggedIn') ?? false;
      String displayName = prefs.getString('displayName' ?? '');
      String email = prefs.getString('email' ?? '');
      String userId = prefs.getString('userId' ?? '');
      print("isLoggedIn? $loggedIn");
      print("email? $email");
      print("displayName? $displayName");
      print("userId? $userId");

      if (loggedIn) {
        Navigator.pushReplacementNamed(context, '/home',
            arguments: {'email': email, 'freshLogin': false, 'userId': userId});
      } else {
        setState(() {
          showProgressBar = false;
        });
      }
    });
  }

  styleDialog(ProgressDialog pr) {
    pr.style(message: 'Processing...');
  }
}
