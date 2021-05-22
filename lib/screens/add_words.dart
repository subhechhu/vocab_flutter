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

class AddWord extends StatefulWidget {
  @override
  _AddWordState createState() => _AddWordState();
}

class _AddWordState extends State<AddWord> {
  DbHelper dbHelper = DbHelper();

  int _maxLinesMeaning = 5;
  int _maxLinesSentence = 10;
  bool _validateWord = false;
  bool _validatPronunciation = false;
  bool _validateMeaning = false;
  bool _hasFetchedMeaning = false;

  final _controllerWord = TextEditingController();
  final _controllerPronunciation = TextEditingController();
  final _controllerMeaning = TextEditingController();
  final _controllerSentence = TextEditingController();

  ProgressDialog pr;

  String action;

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

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: googleButtonText,
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        title: Text(
          action,
          style: TextStyle(color: googleButtonText, letterSpacing: 1.5),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _controllerWord,
                  style: TextStyle(color: googleButtonText, letterSpacing: 1),
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
                                  Icon(
                                    getAddIcon(),
                                    color: googleButtonText,
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
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
                                    : print('code to delete word');
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    action == 'Add Word'
                                        ? Icons.clear
                                        : Icons.delete,
                                    color: googleButtonText,
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
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

  verifyInput() {
    if (action == 'Add Word') {
      if (!_hasFetchedMeaning) {
        setState(() {
          _controllerWord.text.isEmpty
              ? _validateWord = true
              : _validateWord = false;
        });

        if (_controllerWord.text.isEmpty) return;
        pr.style(
            message:
                'Fetching details for ${_controllerWord.value.text.trim()}');
        pr.show();
        getDetailsForWord();
      } else {
        // if all details is fetched, next add details to DB & Firebase
        setState(() {
          _controllerWord.text.isEmpty
              ? _validateWord = true
              : _validateWord = false;
          _controllerPronunciation.text.isEmpty
              ? _validatPronunciation = true
              : _validatPronunciation = false;
          _controllerMeaning.text.isEmpty
              ? _validateMeaning = true
              : _validateMeaning = false;
        });
        if (_controllerWord.text.isEmpty ||
            _controllerPronunciation.text.isEmpty ||
            _controllerMeaning.text.isEmpty) return;

        Words words = Words(
            word: _controllerWord.value.text.trim().toLowerCase(),
            meaning: _controllerMeaning.value.text.trim().toLowerCase(),
            pronunciation:
                _controllerPronunciation.value.text.trim().toLowerCase(),
            sentence: _controllerSentence.value.text.trim().toLowerCase());

        print(words.toString());

        dbHelper.insertWord(words).then((int insert) {
          if (insert != 0) {
            Fluttertoast.showToast(
                msg:
                    "${_controllerWord.value.text.trim().toLowerCase()} added to Database",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                backgroundColor: googleButtonBg,
                textColor: googleButtonTextLight,
                fontSize: 16.0);

            _controllerWord.text = '';
            clearFields();

            setState(() {
              _hasFetchedMeaning = false;
            });
          } else {
            Fluttertoast.showToast(
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
      // if coming from the list, modify the details.
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
        sentence = definations.example + "\n\n" + meaning;
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
    }
  }

  void clearFields() {
    _controllerMeaning.text = '';
    _controllerSentence.text = '';
    _controllerPronunciation.text = '';
  }
}
