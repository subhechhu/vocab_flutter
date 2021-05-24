import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:vocab/services/db_helper.dart';
import 'package:vocab/util/colors.dart';

class RandomWord extends StatefulWidget {
  @override
  _RandomWordState createState() => _RandomWordState();
}

class _RandomWordState extends State<RandomWord> {
  DbHelper dbHelper = DbHelper();
  ProgressDialog pr;
  String _word = '';
  String _meaning = '';
  int _correct = 0;
  int _incorrect = 0;
  bool showMeaning = false;

  @override
  void initState() {
    super.initState();
    dbHelper
        .getDbInstance()
        .then((value) => dbHelper.getRandomData().then((value) {
              print(value.word);
              print(value.meaning);
              print(value.correct);
              print(value.incorrect);

              setState(() {
                _word = value.word;
                _meaning = value.meaning;
                _correct = value.correct;
                _incorrect = value.incorrect;
              });
              // pr.hide();
            }));
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
                            onPressed: () {},
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
                            onPressed: () {},
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
                onPressed: () {},
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
}
