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
  TextEditingController _textController = TextEditingController();
  List<Words> wordList;
  List<Words> newWordList;
  FocusNode _focusNode;
  int listSize = 0;
  String _userId = '';
  bool _shouldRefresh = false;
  bool _shouldDelete = false;
  bool _isSnackbarActive = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    playWord.initTTS();
    _focusNode = FocusNode();
    _prefs.then((SharedPreferences prefs) {
      _userId = prefs.getString('userId') ?? '';
      print('userID: $_userId');
      dbHelper.getDbInstance().then((value) => fetchAllWords());
    });
  }

  @override
  void dispose() {
    playWord.stopTTS();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        automaticallyImplyLeading: _isSearching ? false : true,
        actions: [
          Tooltip(
            message: 'Search Words',
            child: IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search),
              onPressed: () {
                setState(() {
                  if (_isSearching) {
                    setState(() {
                      _textController.text = '';
                      _isSearching = !_isSearching;
                      newWordList = wordList;
                    });
                  } else {
                    setState(() {
                      _textController.text = '';
                      _isSearching = !_isSearching;
                    });
                  }
                });
              },
              color: googleButtonTextLight,
            ),
          )
        ],
        title: !_isSearching
            ? Text(
                'All Words',
                style:
                    TextStyle(color: googleButtonTextLight, letterSpacing: 1.5),
              )
            : Container(
                height: 45,
                child: TextField(
                  autofocus: true,
                  controller: _textController,
                  style: TextStyle(color: googleButtonText, letterSpacing: 1.5),
                  cursorColor: googleButtonText,
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: googleButtonTextLight, width: 1.0),
                      ),
                      focusedBorder: new OutlineInputBorder(
                        borderSide:
                            BorderSide(color: googleButtonText, width: 1.5),
                      ),
                      border: const OutlineInputBorder(),
                      labelStyle: new TextStyle(
                          color: googleButtonText, letterSpacing: 1.5),
                      labelText: 'Search Word'),
                  onChanged: onItemChanged,
                ),
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
          if (_isSearching) {
            setState(() {
              _isSearching = false;
              newWordList = wordList;
            });
          } else {
            if (_isSnackbarActive) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              _shouldRefresh = true;
            }
            Navigator.pop(context, {'shouldRefresh': _shouldRefresh});
          }
          return false;
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            listSize > 0
                ? Expanded(
                    child: ListView.builder(
                      itemCount: newWordList.length,
                      itemBuilder: (context, index) {
                        final word = newWordList[index];
                        return Dismissible(
                          key: Key(word.word),
                          // Provide a function that tells the app
                          // what to do after an item has been swiped away.
                          onDismissed: (direction) {
                            _shouldDelete = true;
                            // Remove the item from the data source.
                            setState(() {
                              newWordList.removeAt(index);
                              wordList.remove(index);
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
                                  backgroundColor: snackbarColor,
                                  action: SnackBarAction(
                                    textColor: error,
                                    label: "UNDO",
                                    onPressed: () {
                                      _isSnackbarActive = false;
                                      _shouldDelete = false;
                                      setState(() {
                                        newWordList.insert(index, word);
                                        wordList.insert(index, word);
                                      });
                                    },
                                  ),
                                ))
                                .closed
                                .then((SnackBarClosedReason reason) {
                              _isSnackbarActive = false;
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
                            elevation: 0,
                            color: primaryColor,
                            child: InkWell(
                                splashColor: googleButtonBg,
                                onLongPress: () {
                                  playWord.speak(newWordList[index].word);
                                },
                                onTap: () async {
                                  dynamic result = await Navigator.pushNamed(
                                      context, '/add',
                                      arguments: {
                                        'action': 'Modify Word',
                                        'word': newWordList[index],
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
                                            '${newWordList[index].word} (${newWordList[index].pronunciation}),',
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
                                                    '${newWordList[index].correct}',
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
                                                    '${newWordList[index].incorrect}',
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
                                        newWordList[index].meaning,
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

  onItemChanged(String value) {
    setState(() {
      newWordList = wordList.where((Words words) {
        return words.word.toLowerCase().contains(value.toLowerCase()) ||
            words.meaning.toLowerCase().contains(value.toLowerCase()) ||
            words.sentence.toLowerCase().contains(value.toLowerCase());
      }).toList();
    });
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
        newWordList = value;
      });
    });
  }
}
