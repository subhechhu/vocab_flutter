import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:vocab/services/db_helper.dart';
import 'package:vocab/services/words.dart';
import 'package:vocab/util/colors.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vocab/util/messages.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocab/util/playWord.dart';

class RandomWord extends StatefulWidget {
  @override
  _RandomWordState createState() => _RandomWordState();
}

class _RandomWordState extends State<RandomWord> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  PlayWord playWord = PlayWord();
  DbHelper dbHelper = DbHelper();
  ProgressDialog pr;
  String _word = '';
  String _meaning = '';
  int _correct = 0;
  int _incorrect = 0;
  bool showMeaning = false;
  String userName = '';
  Words wordObject;

  @override
  void initState() {
    super.initState();
    playWord.initTTS();
    dbHelper.getDbInstance().then((value) => fetchDetails());
    _prefs.then((SharedPreferences prefs) {
      var str = prefs.getString('displayName' ?? '');
      var parts = str.split(':');
      userName = parts[0].trim();
    });
  }

  @override
  void dispose() {
    playWord.stopTTS();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // pr = ProgressDialog(context,
    //     type: ProgressDialogType.Normal, isDismissible: false, showLogs: true);
    // pr.style(message: 'Loading Words...');
    // pr.show();

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: googleButtonText,
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        title: Text(
          'Test By Words',
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
                  Text(
                    '$_word',
                    style: TextStyle(
                        color: googleButtonText,
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(
                height: 100,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      showMeaning ? '$_meaning' : '',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: googleButtonText,
                        fontSize: 20,
                      ),
                    ),
                  )
                ],
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
                              setState(() {
                                showMeaning = false;
                              });
                              updateCount("correct");
                              fetchDetails();
                              showToastMessage(getShortCorrectMessage());
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
                              fetchDetails();
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
              FloatingActionButton(
                onPressed: () {
                  playWord.speak(_word);
                },
                backgroundColor: googleButtonBg,
                splashColor: googleButtonBg,
                child: Icon(
                  Icons.volume_up_rounded,
                  color: googleButtonText,
                ),
              ),
              SizedBox(
                height: 100,
              ),
              TextButton(
                  onPressed: () {
                    showMeaning ? print('oh no') : processWithIncorrect();
                    setState(() {
                      showMeaning = !showMeaning;
                    });
                  },
                  child: Text(
                    showMeaning ? 'Hide Meaning' : 'Show Meaning',
                    style: TextStyle(
                        color: googleButtonText,
                        letterSpacing: 1,
                        fontSize: 16),
                  ))
            ],
          ),
        ),
      )),
    );
  }

  showToastMessage(message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
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

  processWithIncorrect() {
    setState(() {
      _incorrect = _incorrect + 1;
    });
    updateCount('incorrect');
    showToastMessage(getDontTapMeText(userName));
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
