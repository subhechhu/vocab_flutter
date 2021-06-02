import 'package:flutter/material.dart';
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
      floatingActionButton: getFloatingActionButton(),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
                alignment: Alignment.center, child: getRegularText('$_email')),
            getSizedBox(25.0, 0.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                getOptionCard('Word', Icons.psychology),
                getSizedBox(0.0, 2.0),
                getOptionCard('Meaning', Icons.psychology),
              ],
            ),
            getSizedBox(2.0, 0.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                getOptionCard('Recent Words', Icons.description),
                getSizedBox(0.0, 2.0),
                getOptionCard('All Words', Icons.description),
              ],
            ),
            getSizedBox(2.0, 0.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                getOptionCard('Idoms & Phrasals', Icons.whatshot_rounded),
              ],
            ),
            getSizedBox(25.0, 0),
            Align(
              alignment: Alignment.center,
              child: getRegularText('Total Words: $_totalWords'),
            ),
            getSizedBox(10, 0.0),
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

//method to get SizedBox()
  SizedBox getSizedBox(double hightValue, double widthValue) {
    return SizedBox(
      height: hightValue,
      width: widthValue,
    );
  }

  // methods to create floating action button
  FloatingActionButton getFloatingActionButton() {
    return FloatingActionButton(
      elevation: 2,
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
    );
  }

// method to render regular infomation
  Text getRegularText(message) {
    return Text(
      '$message',
      style: TextStyle(
          color: googleButtonTextLight, letterSpacing: 1.5, fontSize: 18),
    );
  }

  // methods to create Word Card, Meaning Card, Recent Words Card, All Words Card
  Widget getOptionCard(cardLabel, cardIcon) {
    return Expanded(
      child: Card(
        elevation: 2,
        color: googleButtonBg,
        child: InkWell(
            splashColor: googleButtonBg,
            onTap: () {
              if (_totalWords == 0) {
                showSnackbar('Add some words first', lightRed);
              } else {
                performClick(cardLabel);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    cardIcon,
                    color: googleButtonText,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    '$cardLabel',
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
    );
  }

  // on click for word, meaning, recent & all cards
  performClick(cardlabel) async {
    switch (cardlabel) {
      case 'Word':
        Navigator.pushNamed(context, '/random_word');
        break;
      case 'Meaning':
        Navigator.pushNamed(context, '/random_sentence');
        break;
      case 'Recent Words':
        dynamic result = await Navigator.pushNamed(context, '/view_recent');
        print('${result['shouldRefresh']}');
        if (result['shouldRefresh']) {
          setState(() {
            _totalWords = _totalWords - 1;
          });
        }
        break;
      case 'All Words':
        dynamic result = await Navigator.pushNamed(context, '/view_all');
        print('${result['shouldRefresh']}');
        if (result['shouldRefresh']) {
          setState(() {
            _totalWords = _totalWords - 1;
          });
        }
        break;
      case 'Idoms & Phrasals':
        Navigator.pushNamed(context, '/idoms');
        break;
    }
  }

  // Snackbar to show information
  showSnackbar(message, textColor) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        '$message',
        style: TextStyle(letterSpacing: 1, color: textColor),
      ),
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: 3),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5))),
      backgroundColor: snackbarColor,
    ));
  }

// fetch data from Firebase if user is app is new
  getDataFromFirebase(_userId) {
    firestore
        .collection(_userId)
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> value) {
      List<QueryDocumentSnapshot<Map<String, dynamic>>> list = value.docs;
      if (list.isNotEmpty) {
        showSnackbar('Downloading your list...', googleButtonText);
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

  // get the total number of rows from local DB
  getTotalRows() {
    dbHelper.getTotalRows().then((int count) {
      setState(() {
        _totalWords = count;
      });
    });
  }
}
