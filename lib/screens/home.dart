import 'package:flutter/material.dart';
import 'package:vocab/services/authenticaation.dart';
import 'package:vocab/util/colors.dart';

import 'package:vocab/services/db_helper.dart';
import 'package:vocab/services/words.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Authentication authentication = Authentication();
  String _email = '';
  String _userId = '';

  bool _freshLogin =
      false; // is true read data from firebase and store locally or do nothing

  DbHelper dbHelper = DbHelper();

  @override
  void initState() {
    super.initState();
    dbHelper.getDbInstance();
  }

  @override
  Widget build(BuildContext context) {
    Map data = ModalRoute.of(context).settings.arguments;
    _email = data['email'];
    _freshLogin = data['freshLogin'];
    _userId = data['userId'];
    return Scaffold(
      backgroundColor: primaryColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add',
              arguments: {'action': 'Add Word', 'userId': _userId});
        },
        backgroundColor: googleButtonBg,
        splashColor: googleButtonBg,
        child: Icon(
          Icons.add,
          color: googleButtonText,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Card(
                    elevation: 0,
                    color: googleButtonBg,
                    child: InkWell(
                        splashColor: googleButtonBg,
                        onTap: () {
                          dbHelper.getRandomData().then((value) {
                            print(value.toString());
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.psychology,
                                color: googleButtonText,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                'Word',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: googleButtonText,
                                    letterSpacing: 1.5,
                                    fontSize: 18),
                              ),
                            ],
                          ),
                        )),
                  ),
                ),
                SizedBox(
                  width: 2,
                ),
                Expanded(
                  child: Card(
                    elevation: 0,
                    color: googleButtonBg,
                    child: InkWell(
                        splashColor: googleButtonBg,
                        onTap: () {
                          dbHelper.getRandomData().then((value) {
                            print(value.toString());
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.psychology,
                                color: googleButtonText,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                'Meaning',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: googleButtonText,
                                    letterSpacing: 1.5,
                                    fontSize: 18),
                              ),
                            ],
                          ),
                        )),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Card(
                    elevation: 0,
                    color: googleButtonBg,
                    child: InkWell(
                        splashColor: googleButtonBg,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/view_recent',
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.description,
                                color: googleButtonText,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                'Recent Words',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: googleButtonText,
                                    letterSpacing: 1.5,
                                    fontSize: 18),
                              ),
                            ],
                          ),
                        )),
                  ),
                ),
                SizedBox(
                  width: 2,
                ),
                Expanded(
                  child: Card(
                    elevation: 0,
                    color: googleButtonBg,
                    child: InkWell(
                        splashColor: googleButtonBg,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/view_all',
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.description,
                                color: googleButtonText,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                'All Words',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: googleButtonText,
                                    letterSpacing: 1.5,
                                    fontSize: 18),
                              ),
                            ],
                          ),
                        )),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 25,
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                _email,
                style: TextStyle(
                    color: googleButtonBg, letterSpacing: 1.5, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
