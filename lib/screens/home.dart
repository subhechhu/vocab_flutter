import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocab/services/authenticaation.dart';
import 'package:vocab/services/words.dart';
import 'package:vocab/util/colors.dart';

import 'package:vocab/services/db_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Authentication authentication = Authentication();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String _email = '';
  String _userId;
  int _totalWords = 0;
  bool _isAddingToDBfromFB = false;

  DbHelper dbHelper = DbHelper();

  @override
  void initState() {
    super.initState();
    dbHelper.getDbInstance().then((value) => getTotalRows());
    _prefs.then((SharedPreferences prefs) {
      _email = prefs.getString('email');
      _userId = prefs.getString('userId');

      if (prefs.getBool('isFreshLogin')) getDataFromFirebase(_userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, '/add',
              arguments: {'action': 'Add Word', 'userId': _userId});
          getTotalRows();
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
            Align(
              alignment: Alignment.center,
              child: Text(
                _email,
                style: TextStyle(
                    color: googleButtonTextLight,
                    letterSpacing: 1.5,
                    fontSize: 15),
              ),
            ),
            SizedBox(
              height: 25,
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
                          if (_totalWords == 0) {
                            showToast('Add some words first');
                          } else {
                            Navigator.pushNamed(context, '/random_word');
                          }
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
                          if (_totalWords == 0) {
                            showToast('Add some words first');
                          } else {
                            Navigator.pushNamed(context, '/random_sentence');
                          }
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
                        onTap: () async {
                          dynamic result = await Navigator.pushNamed(
                              context, '/view_recent');
                          if (result['shouldRefresh']) {
                            setState(() {
                              _totalWords = _totalWords - 1;
                            });
                          }
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
                        onTap: () async {
                          dynamic result =
                              await Navigator.pushNamed(context, '/view_all');
                          if (result['shouldRefresh']) {
                            setState(() {
                              _totalWords = _totalWords - 1;
                            });
                          }
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
                'Total Words: $_totalWords',
                style: TextStyle(
                    color: googleButtonTextLight,
                    letterSpacing: 1.5,
                    fontSize: 18),
              ),
            ),
            SizedBox(height: 10),
            _isAddingToDBfromFB
                ? LinearProgressIndicator(
                    backgroundColor: primaryColor,
                    minHeight: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(googleButtonText),
                  )
                : Container()
          ],
        ),
      ),
    );
  }

  getDataFromFirebase(_userId) {
    firestore
        .collection(_userId)
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> value) {
      List<QueryDocumentSnapshot<Map<String, dynamic>>> list = value.docs;
      if (list.isNotEmpty) {
        showToast('Downloading your list...');
        setState(() {
          _isAddingToDBfromFB = true;
        });
        for (int i = 0; i < list.length; i++) {
          Words words = Words();
          words.word = list[i].get('word');
          words.meaning = list[i].get('meaning');
          words.sentence = list[i].get('sentence');
          words.pronunciation = list[i].get('pronunciation');
          words.time = list[i].get('time');
          words.incorrect = 0;
          words.correct = 0;
          dbHelper.insertWord(words);
        }
        getTotalRows();
        setState(() {
          _isAddingToDBfromFB = false;
        });
      } else {
        print('empty firebase');
      }
    });
  }

  showToast(message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: googleButtonBg,
        textColor: googleButtonTextLight,
        fontSize: 16.0);
  }

  getTotalRows() {
    dbHelper.getTotalRows().then((int count) {
      setState(() {
        _totalWords = count;
      });
    });
  }
}
