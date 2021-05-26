import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vocab/services/db_helper.dart';
import 'package:vocab/services/words.dart';
import 'package:vocab/util/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocab/util/playWord.dart';

class AllWords extends StatefulWidget {
  @override
  _AllWordsState createState() => _AllWordsState();
}

class _AllWordsState extends State<AllWords> {
  PlayWord playWord = PlayWord();
  DbHelper dbHelper = DbHelper();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<Words> wordList;
  int listSize = 0;
  String _userId = '';
  bool _shouldRefresh = false;
  bool _shouldDelete = false;
  bool _isSnackbarActive = false;

  @override
  void initState() {
    super.initState();
    playWord.initTTS();
    _prefs.then((SharedPreferences prefs) {
      _userId = prefs.getString('userId') ?? '';
      print('userID: $_userId');
      dbHelper.getDbInstance().then((value) => fetchAllWords());
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
        title: Text(
          'All Words',
          style: TextStyle(color: googleButtonTextLight, letterSpacing: 1.5),
        ),
        iconTheme: IconThemeData(
          color: googleButtonTextLight,
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
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
                        final word = wordList[index];
                        return Dismissible(
                          key: Key(word.word),
                          // Provide a function that tells the app
                          // what to do after an item has been swiped away.
                          onDismissed: (direction) {
                            _shouldDelete = true;
                            // Remove the item from the data source.
                            setState(() {
                              wordList.removeAt(index);
                            });
                            _isSnackbarActive = true;
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(
                                  content: WillPopScope(
                                    onWillPop: () async {
                                      ScaffoldMessenger.of(context)
                                          .removeCurrentSnackBar();
                                      return true;
                                    },
                                    child: Text(
                                      'Details for ${word.word.toUpperCase()} deleted',
                                      style: TextStyle(
                                          letterSpacing: 1,
                                          color: googleButtonText),
                                    ),
                                  ),
                                  margin: EdgeInsets.all(20),
                                  behavior: SnackBarBehavior.floating,
                                  duration: Duration(seconds: 3),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5))),
                                  backgroundColor: googleButtonBg,
                                  action: SnackBarAction(
                                    textColor: error,
                                    label: "UNDO",
                                    onPressed: () {
                                      _isSnackbarActive = false;
                                      _shouldDelete = false;
                                      setState(() {
                                        wordList.insert(index, word);
                                      });
                                    },
                                  ),
                                ))
                                .closed
                                .then((SnackBarClosedReason reason) {
                              _isSnackbarActive = false;
                              print('should delete? $_shouldDelete');
                              if (_shouldDelete) {
                                dbHelper
                                    .deleteWord(word.word)
                                    .then((int value) {
                                  firestore
                                      .collection(_userId)
                                      .doc(word.word)
                                      .delete()
                                      .then((value) => _shouldRefresh = true);
                                });
                              }
                            });
                          },
                          background: Container(color: error),
                          child: Card(
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
                                    fetchAllWords();
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${wordList[index].word}',
                                            style: TextStyle(
                                                color: googleButtonText,
                                                letterSpacing: 1,
                                                fontSize: 16),
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
                                      Text(
                                        '${wordList[index].pronunciation}',
                                        style: TextStyle(
                                            color: googleButtonText,
                                            letterSpacing: 1,
                                            fontSize: 16),
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
                          ),
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

  getSharedPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId') ?? '';
    print('userID: $_userId');
  }

  fetchAllWords() {
    dbHelper.getAllWords().then((value) {
      setState(() {
        wordList = value;
        listSize = value.length;
      });
    });
  }
}
