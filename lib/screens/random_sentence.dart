import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:vocab/services/db_helper.dart';
import 'package:vocab/services/words.dart';
import 'package:vocab/util/colors.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vocab/util/messages.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RandomSentence extends StatefulWidget {
  @override
  _RandomSentenceState createState() => _RandomSentenceState();
}

class _RandomSentenceState extends State<RandomSentence> {
  DbHelper dbHelper = DbHelper();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  ProgressDialog pr;
  String _word = '';
  String _meaning = '';
  int _correct = 0;
  int _incorrect = 0;
  bool isTextEmpty = true;
  bool _validateText = false;
  FocusNode _focusNode;
  String userName = '';
  Words wordObject;

  final _controllerWord = TextEditingController();

  @override
  void initState() {
    super.initState();
    dbHelper.getDbInstance().then((value) => {fetchDetails()});
    _prefs.then((SharedPreferences prefs) {
      var str = prefs.getString('displayName' ?? '');
      var parts = str.split(':');
      userName = parts[0].trim();
    });
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    _controllerWord.dispose();
    _focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: googleButtonText,
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        title: Text(
          'Test By Meaning',
          style: TextStyle(color: googleButtonText, letterSpacing: 1.5),
        ),
        centerTitle: true,
      ),
      body: (SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      '$_meaning',
                      style: TextStyle(
                          color: googleButtonText,
                          fontSize: 25,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 50,
              ),
              SizedBox(
                height: 150,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Column(
                        children: [
                          FloatingActionButton(
                            heroTag: "thumbs_up",
                            onPressed: () {
                              showToastMessage(
                                  'You have answered ${_word.toUpperCase()} correctly $_correct times.');
                            },
                            backgroundColor: googleButtonBg,
                            splashColor: googleButtonBg,
                            child: Icon(
                              Icons.thumb_up_alt,
                              color: googleButtonText,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            '$_correct',
                            style: TextStyle(
                                color: googleButtonText,
                                letterSpacing: 1,
                                fontSize: 20),
                          )
                        ],
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        children: [
                          FloatingActionButton(
                            heroTag: "thumbs_down",
                            onPressed: () {
                              showToastMessage(
                                  'You have answered ${_word.toUpperCase()} incorrectly $_incorrect times.');
                            },
                            backgroundColor: googleButtonBg,
                            splashColor: googleButtonBg,
                            child: Icon(
                              Icons.thumb_down_alt,
                              color: googleButtonText,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            '$_incorrect',
                            style: TextStyle(
                                color: googleButtonText,
                                letterSpacing: 1,
                                fontSize: 20),
                          )
                        ],
                      ),
                    ],
                  )
                ],
              ),
              SizedBox(
                height: 75,
              ),
              TextFormField(
                focusNode: _focusNode,
                onChanged: (text) {
                  if (text.isEmpty)
                    setState(() {
                      isTextEmpty = true;
                    });
                  else
                    setState(() {
                      isTextEmpty = false;
                    });
                },
                onFieldSubmitted: (term) {
                  _validateText // is validate is already pressed
                      ? print('validating')
                      : processWithValidation();
                },
                keyboardType: TextInputType.emailAddress,
                controller: _controllerWord,
                textInputAction: TextInputAction.done,
                style: TextStyle(color: googleButtonText, letterSpacing: 1),
                cursorColor: googleButtonTextLight,
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: googleButtonTextLight, width: 1.0),
                    ),
                    focusedBorder: new OutlineInputBorder(
                      borderSide:
                          BorderSide(color: googleButtonText, width: 1.5),
                    ),
                    border: const OutlineInputBorder(),
                    labelStyle: new TextStyle(
                        color: googleButtonText, letterSpacing: 1.5),
                    labelText: 'Word'),
              ),
              SizedBox(
                height: 100,
              ),
              SizedBox(
                height: 50,
                child: Card(
                  elevation: 0,
                  color: _validateText ? googleButtonTextLight : googleButtonBg,
                  child: InkWell(
                      splashColor: googleButtonBg,
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        _validateText // is validate is already pressed
                            ? print('validating')
                            : processWithValidation();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isTextEmpty ? 'Give up' : 'Validate',
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
            ],
          ),
        ),
      )),
    );
  }

  validateInput() {
    if (_word == _controllerWord.text) {
      updateCount('correct');
      showToastMessage(getCorrectMessage(userName));
      _controllerWord.text = '';
      fetchDetails();
    } else {
      updateCount('incorrect');
      setState(() {
        _incorrect = _incorrect + 1;
      });
      String wrongMessage = getWrongMessage(userName);
      showSnackBar(
          '$wrongMessage. ${_word.toUpperCase()} is correct word for the sentence');
    }
  }

  showSnackBar(message) {
    setState(() {
      _validateText = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        message,
        style: TextStyle(letterSpacing: 1, color: googleButtonText),
      ),
      margin: EdgeInsets.all(20),
      behavior: SnackBarBehavior.floating,
      duration: Duration(hours: 24),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      backgroundColor: googleButtonBg,
      action: SnackBarAction(
        textColor: error,
        label: "Get It",
        onPressed: () {
          setState(() {
            _validateText = false;
          });
          fetchDetails();
          _controllerWord.text = '';
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    ));
  }

  showToastMessage(message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: googleButtonBg,
        textColor: googleButtonTextLight,
        fontSize: 16.0);
  }

  fetchDetails() {
    dbHelper.getRandomData().then((value) {
      if (value.word == _word)
        fetchDetails();
      else {
        wordObject = value;
        setState(() {
          _word = value.word;
          _meaning = value.meaning;
          _correct = value.correct;
          _incorrect = value.incorrect;
        });
      }
    });
  }

  processWithValidation() {
    {
      if (isTextEmpty) {
        updateCount('Empty');
        showSnackBar('You gave up. $_word is correct word for the sentence');
      } else
        validateInput();
    }
  }

  updateCount(String type) {
    if (type == 'correct') {
      Words updatedWord = wordObject;
      updatedWord.correct = _correct + 1;
      dbHelper.updateWord(updatedWord);
    } else {
      Words updatedWord = wordObject;
      updatedWord.incorrect = _incorrect + 1;
      dbHelper.updateWord(updatedWord);
    }
  }
}
