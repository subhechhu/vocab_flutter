import 'package:flutter/material.dart';
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
  String _word = '';
  String _meaning = '';
  int _correct = 0;
  int _incorrect = 0;
  bool showWord = true;
  bool initShowWord;
  bool showMeaning = false;
  String userName = '';
  Words wordObject;

  @override
  void initState() {
    super.initState();
    playWord.initTTS();
    _prefs.then((SharedPreferences prefs) {
      var str = prefs.getString('displayName' ?? '');
      var parts = str.split(':');
      userName = parts[0].trim();
      initShowWord = showWord = prefs.getBool('showWord');
      dbHelper.getDbInstance().then((value) => fetchDetails());
    });
  }

  @override
  void dispose() {
    playWord.stopTTS();
    super.dispose();
    if (showWord != initShowWord) {
      _prefs.then((SharedPreferences prefs) {
        prefs.setBool('showWord', showWord);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      floatingActionButton: getFAB(
        'show word',
        showWord ? Icons.visibility_off : Icons.visibility,
      ),
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: googleButtonTextLight,
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        title: Text(
          'Test By Words',
          style: TextStyle(color: googleButtonTextLight, letterSpacing: 1.5),
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
                  renderText(showWord ? '$_word' : '', 30.0, FontWeight.bold),
                ],
              ),
              getSizedBox(100.0, 0.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: showMeaning
                        ? renderText('$_meaning', 20.0, FontWeight.normal)
                        : renderText('', 20.0, FontWeight.normal),
                  )
                ],
              ),
              getSizedBox(150.0, 0.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      renderFloatingActionButton(
                          'correct', Icons.thumb_up_alt, '$_correct'),
                      getSizedBox(0.0, 20.0),
                      renderFloatingActionButton(
                          'incorrect', Icons.thumb_down_alt, '$_incorrect'),
                    ],
                  )
                ],
              ),
              getSizedBox(75.0, 0.0),
              getFAB('tts', Icons.volume_up_rounded),
              getSizedBox(100.0, 0.0),
              TextButton(
                onPressed: () {
                  showMeaning ? print('oh no') : processWithIncorrect();
                  setState(() {
                    showMeaning = !showMeaning;
                  });
                },
                child: showMeaning
                    ? renderText('Hide Meaning', 16.0, FontWeight.normal)
                    : renderText('Show Meaning', 16.0, FontWeight.normal),
              ),
            ],
          ),
        ),
      )),
    );
  }

//method to get SizedBox()
  SizedBox getSizedBox(double hightValue, double widthValue) {
    return SizedBox(
      height: hightValue,
      width: widthValue,
    );
  }

// widget to render text
  Text renderText(message, double size, textWeight) {
    return Text(
      message,
      style: TextStyle(
          color: googleButtonText,
          letterSpacing: 1,
          fontSize: size,
          fontWeight: textWeight),
    );
  }

//widget to render FAB
  Widget renderFloatingActionButton(type, fabIcon, value) {
    return Column(
      children: [
        getFAB(type, fabIcon),
        getSizedBox(5.0, 0.0),
        renderText('$value', 20.0, FontWeight.normal),
      ],
    );
  }

// generate fab button()
  FloatingActionButton getFAB(type, fabIcon) {
    return FloatingActionButton(
      elevation: 2,
      heroTag: '$type',
      onPressed: () {
        fabButtonPress(type);
      },
      backgroundColor: googleButtonBg,
      splashColor: googleButtonBg,
      child: Icon(
        fabIcon,
        color: googleButtonText,
      ),
    );
  }

  // process count update
  fabButtonPress(type) {
    switch (type) {
      case 'correct':
        setState(() {
          showMeaning = false;
        });
        updateCount('$type');
        fetchDetails();
        showToastMessage(getShortCorrectMessage());
        break;
      case 'incorrect':
        setState(() {
          showMeaning = false;
        });
        fetchDetails();
        break;
      case 'tts':
        playWord.speak(_word);
        break;
      case 'show word':
        setState(() {
          showWord = !showWord;
        });
        if (!showWord) {
          playWord.speak(_word);
        }
    }
  }

// get random word from local db
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
        if (!showWord) {
          playWord.speak(_word);
        }
      }
    });
  }

// increase incorrect count & update it on local db
  processWithIncorrect() {
    setState(() {
      _incorrect = _incorrect + 1;
    });
    updateCount('incorrect');
    showToastMessage(getDontTapMeText(userName));
  }

// update the in/correct count locally
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

// method to show toast message
  showToastMessage(message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: googleButtonBg,
        textColor: googleButtonTextLight,
        fontSize: 16.0);
  }
}
