import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:vocab/util/colors.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart';
import 'package:vocab/services/meaning_response.dart';

import 'package:vocab/services/db_helper.dart';
import 'package:vocab/services/words.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddWord extends StatefulWidget {
  @override
  _AddWordState createState() => _AddWordState();
}

class _AddWordState extends State<AddWord> {
  DbHelper dbHelper = DbHelper();
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  int _maxLinesMeaning = 5;
  int _maxLinesSentence = 10;
  bool _validateWord = false;
  bool _validatPronunciation = false;
  bool _validateMeaning = false;
  bool _hasFetchedMeaning = false;
  bool _switchState = false;

  final _controllerWord = TextEditingController();
  final _controllerPronunciation = TextEditingController();
  final _controllerMeaning = TextEditingController();
  final _controllerSentence = TextEditingController();

  ProgressDialog pr;

  String action;
  String _userId;

  Words words;

  @override
  void dispose() {
    _controllerWord.dispose();
    _controllerPronunciation.dispose();
    _controllerMeaning.dispose();
    _controllerSentence.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    dbHelper.getDbInstance();
  }

  @override
  Widget build(BuildContext context) {
    pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: true);

    Map data = ModalRoute.of(context).settings.arguments;
    action = data['action'];
    _userId = data['userId'];

    if (action == 'Modify Word') {
      words = data['word'];

      _controllerWord.text = words.word;
      _controllerMeaning.text = words.meaning;
      _controllerPronunciation.text = words.pronunciation;
      _controllerSentence.text = words.sentence;
    }

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: googleButtonTextLight,
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        title: Text(
          action,
          style: TextStyle(color: googleButtonTextLight, letterSpacing: 1.5),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          child: SingleChildScrollView(
            child: Column(
              children: [
                action == 'Modify Word'
                    ? Container()
                    : Row(
                        children: [
                          Text(
                            'Add Manually',
                            style: TextStyle(
                                fontSize: 20, color: googleButtonText),
                          ),
                          Switch(
                            onChanged: toggleSwitch,
                            value: _switchState,
                            activeColor: googleButtonText,
                            inactiveThumbColor: googleButtonTextLight,
                            inactiveTrackColor: googleButtonTextLight,
                          ),
                        ],
                      ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  onTap: () {
                    action == 'Modify Word'
                        ? showToast('Unable to modify main word')
                        : print('adding word');
                  },
                  readOnly: action == 'Modify Word' ? true : false,
                  showCursor: action == 'Modify Word' ? false : true,
                  controller: _controllerWord,
                  style: TextStyle(
                      color: action == 'Modify Word'
                          ? googleButtonTextLight
                          : googleButtonText,
                      letterSpacing: 1),
                  cursorColor: googleButtonTextLight,
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: googleButtonTextLight, width: 1.0),
                      ),
                      focusedBorder: new OutlineInputBorder(
                        borderSide:
                            BorderSide(color: googleButtonText, width: 1.5),
                      ),
                      errorText: _validateWord ? 'Word Cannot Be Empty' : null,
                      border: const OutlineInputBorder(),
                      labelStyle: new TextStyle(
                          color: googleButtonText, letterSpacing: 1.5),
                      labelText: 'Word'),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: _controllerPronunciation,
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: googleButtonTextLight, width: 1.0),
                      ),
                      focusedBorder: new OutlineInputBorder(
                        borderSide:
                            BorderSide(color: googleButtonText, width: 1.5),
                      ),
                      errorText: _validatPronunciation
                          ? 'Pronunciation Cannot Be Empty'
                          : null,
                      border: const OutlineInputBorder(),
                      labelStyle: new TextStyle(
                          color: googleButtonText, letterSpacing: 1.5),
                      labelText: 'Pronunciation'),
                  style: TextStyle(color: googleButtonText, letterSpacing: 1),
                  cursorColor: googleButtonTextLight,
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  child: TextFormField(
                    controller: _controllerMeaning,
                    decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: googleButtonTextLight, width: 1.0),
                        ),
                        focusedBorder: new OutlineInputBorder(
                          borderSide:
                              BorderSide(color: googleButtonText, width: 1.5),
                        ),
                        errorText:
                            _validateMeaning ? 'Meaning Cannot Be Empty' : null,
                        border: const OutlineInputBorder(),
                        labelStyle: new TextStyle(
                            color: googleButtonText, letterSpacing: 1.5),
                        labelText: 'Meaning'),
                    keyboardType: TextInputType.multiline,
                    maxLines: _maxLinesMeaning,
                    style: TextStyle(color: googleButtonText, letterSpacing: 1),
                    cursorColor: googleButtonTextLight,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  child: TextFormField(
                    controller: _controllerSentence,
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
                        labelText: 'Sentence'),
                    keyboardType: TextInputType.multiline,
                    maxLines: _maxLinesSentence,
                    style: TextStyle(color: googleButtonText, letterSpacing: 1),
                    cursorColor: googleButtonTextLight,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: Card(
                          elevation: 0,
                          color: googleButtonBg,
                          child: InkWell(
                              splashColor: googleButtonBg,
                              onTap: () {
                                verifyInput();
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Icon(
                                  //   getAddIcon(),
                                  //   color: googleButtonText,
                                  // ),
                                  // SizedBox(
                                  //   width: 15,
                                  // ),
                                  Text(
                                    getAddText(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: googleButtonText,
                                        letterSpacing: 1.5,
                                        fontSize: 18),
                                  ),
                                ],
                              )),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: Card(
                          elevation: 0,
                          color: googleButtonBg,
                          child: InkWell(
                              splashColor: googleButtonBg,
                              onTap: () {
                                action == 'Add Word'
                                    ? clearFields()
                                    : deleteConfirmation();
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Icon(
                                  //   action == 'Add Word'
                                  //       ? Icons.clear
                                  //       : Icons.delete,
                                  //   color: googleButtonText,
                                  // ),
                                  // SizedBox(
                                  //   width: 15,
                                  // ),
                                  Text(
                                    action == 'Add Word' ? 'Clear' : 'Delete',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: googleButtonText,
                                        letterSpacing: 1.5,
                                        fontSize: 18),
                                  ),
                                ],
                              )),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void toggleSwitch(bool value) {
    setState(() {
      _hasFetchedMeaning = !_hasFetchedMeaning;
      _switchState = !_switchState;
    });
  }

  verifyInput() {
    if (action == 'Add Word') {
      // add new word
      if (!_hasFetchedMeaning) {
        // to fetch the details of word from owlbot server, if false, fetch

        setState(() {
          _controllerWord.text.isEmpty // checks if word section is empty
              ? _validateWord =
                  true // if some one presses get button with empty word, show error message 'Word Cannot Be Empty'
              : _validateWord = false;
        });

        if (_controllerWord.text.isEmpty)
          return; // nothing to fetch from owlbot server
        pr.style(
            message:
                'Fetching details for ${_controllerWord.value.text.trim().toUpperCase()}');
        pr.show();
        getDetailsForWord(); // get details from server for the word
      } else {
        // if all details is fetched from server, add details to DB & Firebase
        setState(() {
          _controllerWord.text
                  .isEmpty // checks if word section is empty, throws error is yes
              ? _validateWord = true
              : _validateWord = false;
          _controllerPronunciation.text
                  .isEmpty // checks if pronunciation section is empty, throws error if yes
              ? _validatPronunciation = true
              : _validatPronunciation = false;
          _controllerMeaning.text
                  .isEmpty // checks if meaning section is emptym throws error is yes
              ? _validateMeaning = true
              : _validateMeaning = false;
        });
        if (_controllerWord.text.isEmpty ||
            _controllerPronunciation.text.isEmpty ||
            _controllerMeaning.text.isEmpty)
          return; // if any of first 3 section is empty, return

        Words words = Words(
            // create Word class to add it to DB & FB
            correct: 0,
            incorrect: 0,
            word: _controllerWord.value.text.trim().toLowerCase(),
            meaning: _controllerMeaning.value.text.trim().toLowerCase(),
            pronunciation:
                _controllerPronunciation.value.text.trim().toLowerCase(),
            sentence: _controllerSentence.value.text.trim().toLowerCase(),
            time: DateTime.now().millisecondsSinceEpoch);

        dbHelper.insertWord(words).then((int insert) {
          if (insert != 0) {
            addToFirebase(words); // add data to firebase, with id above

            showToast(
                "${_controllerWord.value.text.trim().toLowerCase()} added to Database");

            _controllerWord.text = '';
            clearFields(); // clear all the fields for new words & details

            if (!_switchState) {
              setState(() {
                _hasFetchedMeaning =
                    false; // ready to fetch meaning for next word
              });
            }
          } else {
            Fluttertoast.showToast(
                // data insert on local db failed
                msg: "Failed. Something went wrong",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                backgroundColor: error,
                textColor: googleButtonTextLight,
                fontSize: 16.0);
          }
        });
      }
    } else {
      // modfiy old word
      setState(() {
        _controllerWord.text
                .isEmpty // checks if word section is empty, throws error is yes
            ? _validateWord = true
            : _validateWord = false;
        _controllerPronunciation.text
                .isEmpty // checks if pronunciation section is empty, throws error if yes
            ? _validatPronunciation = true
            : _validatPronunciation = false;
        _controllerMeaning.text
                .isEmpty // checks if meaning section is emptym throws error is yes
            ? _validateMeaning = true
            : _validateMeaning = false;
      });
      if (_controllerWord.text.isEmpty ||
          _controllerPronunciation.text.isEmpty ||
          _controllerMeaning.text.isEmpty)
        return; // if any of first 3 section is empty, return

      if (words.meaning == _controllerMeaning.text &&
          words.sentence == _controllerSentence.text &&
          words.pronunciation == _controllerPronunciation.text) {
        showToast('Nothing to modify');
        Navigator.pop(context, {'shouldRefresh': false});
      } else {
        Words updatedWords = words;
        updatedWords.meaning = _controllerMeaning.text;
        updatedWords.pronunciation = _controllerPronunciation.text;
        updatedWords.sentence = _controllerSentence.text;
        dbHelper
            .updateWord(updatedWords)
            .then((value) => updateFirebase(updatedWords));
      }
    }
  }

  IconData getAddIcon() {
    if (action == 'Add Word') {
      if (_hasFetchedMeaning) {
        return Icons.save;
      } else {
        return Icons.download_rounded;
      }
    } else {
      return Icons.check;
    }
  }

  String getAddText() {
    if (action == 'Add Word') {
      if (_hasFetchedMeaning) {
        return 'Add';
      } else {
        return 'Get Meaning';
      }
    } else {
      return 'Modify';
    }
  }

  getDetailsForWord() async {
    String url =
        'https://owlbot.info/api/v4/dictionary/${_controllerWord.value.text.trim().toLowerCase()}';

    Response response = await get(Uri.parse(url), headers: {
      HttpHeaders.authorizationHeader:
          'token 22f202b5361e234f44893150c0a10f102b180f7b'
    });
    pr.hide();

    try {
      Map<String, dynamic> meaningMap = jsonDecode(response.body);
      MeaningResponse meaningResponse = MeaningResponse.fromJson(meaningMap);

      // _controllerPronunciation.text = meaningResponse.pronunciation;
      print(meaningResponse.pronunciation);
      String meaning = '';
      String sentence = '';
      for (Definitions definations in meaningResponse.definitions) {
        meaning = definations.definition + "\n\n" + meaning;
        sentence = definations.example + "\n\n" + sentence;
      }

      _controllerMeaning.text = meaning;
      _controllerSentence.text = sentence;
      _controllerPronunciation.text = meaningResponse.pronunciation;

      setState(() {
        _hasFetchedMeaning = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Unable to fetch meaning. Please add it manually'),
        duration: Duration(seconds: 5),
      ));
      setState(() {
        _hasFetchedMeaning = true;
      });
    }
  }

  void clearFields() {
    _controllerMeaning.text = '';
    _controllerSentence.text = '';
    _controllerPronunciation.text = '';
  }

  void addToFirebase(Words words) {
    firestore.collection(_userId).doc(words.word).set({
      'word': words.word,
      'correct': words.correct,
      'incorrect': words.incorrect,
      'pronunciation': words.pronunciation,
      'meaning': words.meaning,
      'sentence': words.sentence,
      'time': words.time
    });
  }

  void updateFirebase(Words words) {
    firestore.collection(_userId).doc(words.word).update({
      'word': words.word,
      'pronunciation': words.pronunciation,
      'meaning': words.meaning,
      'sentence': words.sentence
    }).then((value) => Navigator.pop(context, {'shouldRefresh': true}));
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

  deleteConfirmation() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        'Deleted data cannot be retrived. Do you wish to continue? If yes, press PROCEED. Ignore(10 sec) if no.',
        style: TextStyle(letterSpacing: 1, color: googleButtonText),
      ),
      margin: EdgeInsets.all(20),
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: 10),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      backgroundColor: googleButtonBg,
      action: SnackBarAction(
        textColor: error,
        label: "PROCEED",
        onPressed: () {
          deleteItemFromDB();
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    ));
  }

  deleteItemFromDB() {
    dbHelper.deleteWord(words.word).then((value) => deleteItemFromFB());
  }

  deleteItemFromFB() {
    firestore
        .collection(_userId)
        .doc(words.word)
        .delete()
        .then((value) => Navigator.pop(context, {'shouldRefresh': true}));
  }
}
