import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vocab/services/db_helper.dart';
import 'package:vocab/services/words.dart';
import 'package:vocab/util/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocab/util/playWord.dart';

class RecentWords extends StatefulWidget {
  @override
  _RecentWordsState createState() => _RecentWordsState();
}

class _RecentWordsState extends State<RecentWords> {
  PlayWord playWord = PlayWord();
  DbHelper dbHelper = DbHelper();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<Words> wordList;
  int listSize = 0;
  String _userId = '';
  int _defaultRecentSize = 15;
  bool _shouldRefresh = false;
  bool _isSnackbarActive = false;
  String orderType = 'time DESC';
  TextEditingController _controllerListSize = TextEditingController();

  @override
  void initState() {
    super.initState();
    playWord.initTTS();
    _prefs.then((SharedPreferences prefs) {
      _userId = prefs.getString('userId') ?? '';
      print('userID: $_userId');
      _defaultRecentSize = prefs.getInt('defaultRecentList') ?? 15;
      dbHelper
          .getDbInstance()
          .then((value) => fetchRecent(_defaultRecentSize, orderType));
    });
  }

  @override
  void dispose() {
    playWord.stopTTS();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        actions: [
          Tooltip(
            message: 'Edit List Size',
            child: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                _controllerListSize.text = _defaultRecentSize.toString();
                _displayTextInputDialog(context);
              },
              color: googleButtonTextLight,
            ),
          )
        ],
        title: Text(
          'Recent Words',
          style: TextStyle(color: googleButtonTextLight, letterSpacing: 1.5),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(
          color: googleButtonTextLight,
        ),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: WillPopScope(
        onWillPop: () async {
          if (_isSnackbarActive) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            _shouldRefresh = true;
          }
          Navigator.pop(context, {'shouldRefresh': _shouldRefresh});
          return false;
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            listSize > 0
                ? Expanded(
                    child: ListView.builder(
                      itemCount: wordList.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 0,
                          color: primaryColor,
                          child: InkWell(
                              splashColor: googleButtonBg,
                              onLongPress: () {
                                playWord.speak(wordList[index].word);
                              },
                              onTap: () async {
                                dynamic result = await Navigator.pushNamed(
                                    context, '/add',
                                    arguments: {
                                      'action': 'Modify Word',
                                      'word': wordList[index],
                                      'userId': _userId,
                                    });
                                _shouldRefresh = result['shouldRefresh'];
                                if (_shouldRefresh) {
                                  fetchRecent(_defaultRecentSize, orderType);
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${wordList[index].word} (${wordList[index].pronunciation})',
                                          style: TextStyle(
                                              color: googleButtonText,
                                              letterSpacing: 1,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Row(
                                          children: [
                                            Column(
                                              children: [
                                                Icon(
                                                  Icons.thumb_up,
                                                  color: googleButtonText,
                                                  size: 15,
                                                ),
                                                SizedBox(
                                                  height: 2,
                                                ),
                                                Text(
                                                  '${wordList[index].correct}',
                                                  style: TextStyle(
                                                      color: googleButtonText,
                                                      letterSpacing: 1,
                                                      fontSize: 14),
                                                )
                                              ],
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Column(
                                              children: [
                                                Icon(
                                                  Icons.thumb_down,
                                                  color: googleButtonText,
                                                  size: 15,
                                                ),
                                                SizedBox(
                                                  height: 2,
                                                ),
                                                Text(
                                                  '${wordList[index].incorrect}',
                                                  style: TextStyle(
                                                      color: googleButtonText,
                                                      letterSpacing: 1,
                                                      fontSize: 14),
                                                )
                                              ],
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Text(
                                      wordList[index].meaning,
                                      style: TextStyle(
                                          color: googleButtonText,
                                          letterSpacing: 1,
                                          fontSize: 15),
                                    ),
                                    SizedBox(
                                      height: 25,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '________________',
                                          style: TextStyle(
                                              color: googleButtonTextLight,
                                              fontSize: 15),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )),
                        );
                      },
                    ),
                  )
                : Center(
                    child: Text(
                      'Words will be visible here when you add',
                      style: TextStyle(color: googleButtonText),
                    ),
                  )
          ],
        ),
      ),
    );
  }

  fetchRecent(defaultRecentSize, orderType) {
    dbHelper.getRecentWords(defaultRecentSize, orderType).then((value) {
      setState(() {
        wordList = value;
        listSize = value.length;
      });
    });
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: TextField(
              onChanged: (value) {
                setState(() {});
              },
              keyboardType: TextInputType.number,
              controller: _controllerListSize,
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: snackbarColor, width: 1.0),
                  ),
                  focusedBorder: new OutlineInputBorder(
                    borderSide: BorderSide(color: snackbarColor, width: 1.5),
                  ),
                  border: const OutlineInputBorder(),
                  labelStyle:
                      new TextStyle(letterSpacing: 1.5, color: snackbarColor),
                  labelText: 'List Size'),
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    _defaultRecentSize = int.parse(_controllerListSize.text);
                    _prefs.then((SharedPreferences prefs) {
                      prefs.setInt('defaultRecentList', _defaultRecentSize);
                    });
                    fetchRecent(_defaultRecentSize, orderType);
                    Navigator.pop(context);
                  },
                  child: Text(
                    'SET',
                    style: TextStyle(
                        letterSpacing: 1, fontSize: 16, color: primaryColor),
                  )),
            ],
          );
        });
  }
}
