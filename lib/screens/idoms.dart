import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vocab/services/IdomModel.dart';
import 'package:vocab/services/db_helper.dart';
import 'package:vocab/util/colors.dart';

class Idoms extends StatefulWidget {
  @override
  _IdomsState createState() => _IdomsState();
}

TextEditingController _textController = TextEditingController();
DbHelper dbHelper = DbHelper();
List<IdomModel> wordList;
List<IdomModel> newWordList;

bool _isSearching = false;

class _IdomsState extends State<Idoms> {
  int listSize = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dbHelper.getDbInstance().then((value) => getAllIdoms(false));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      floatingActionButton: MyFloatingActionButton(),
      appBar: AppBar(
        actions: [
          Tooltip(
            message: 'Refresh',
            child: IconButton(
              icon: Icon(Icons.refresh_outlined),
              onPressed: () {
                getAllIdoms(true);
              },
              color: googleButtonTextLight,
            ),
          ),
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
        iconTheme: IconThemeData(
          color: googleButtonTextLight,
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        title: !_isSearching
            ? Text(
                'Idoms',
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
                      labelText: 'Search Idom'),
                  onChanged: onItemChanged,
                ),
              ),
      ),
      body: Column(
        children: [
          listSize > 0
              ? Expanded(
                  child: ListView.builder(
                      itemCount: newWordList.length,
                      itemBuilder: (context, index) {
                        return Card(
                            elevation: 0,
                            color: primaryColor,
                            child: InkWell(
                              splashColor: googleButtonBg,
                              onLongPress: () {
                                // playWord.speak(newWordList[index].word);
                              },
                              onTap: () async {},
                              child: Column(
                                children: [
                                  Theme(
                                    data: Theme.of(context).copyWith(
                                        accentColor: googleButtonText,
                                        unselectedWidgetColor:
                                            googleButtonText),
                                    child: ExpansionTile(
                                      backgroundColor: Colors.white24,
                                      title: Text(
                                        '${newWordList[index].word}',
                                        style: TextStyle(
                                            color: googleButtonText,
                                            letterSpacing: 1,
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              32, 0, 32, 16),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      '${newWordList[index].meaning}',
                                                      style: TextStyle(
                                                        color: googleButtonText,
                                                        letterSpacing: 1,
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              SizedBox(
                                                height: 16,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      '${newWordList[index].sentence}',
                                                      style: TextStyle(
                                                          color:
                                                              googleButtonText,
                                                          letterSpacing: 1,
                                                          fontSize: 20),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ));
                      }))
              : Center(
                  child: Text(
                    'Words will be visible here when you add',
                    style: TextStyle(color: googleButtonText),
                  ),
                )
        ],
      ),
    );
  }

  onItemChanged(String value) {
    setState(() {
      newWordList = wordList.where((IdomModel words) {
        return words.word.toLowerCase().contains(value.toLowerCase()) ||
            words.meaning.toLowerCase().contains(value.toLowerCase()) ||
            words.sentence.toLowerCase().contains(value.toLowerCase());
      }).toList();
    });
  }

  getAllIdoms(order) {
    dbHelper.getAllIdoms(order).then((value) {
      setState(() {
        wordList = value;
        listSize = value.length;
        newWordList = value;
      });
    });
  }
}

class MyFloatingActionButton extends StatefulWidget {
  @override
  _MyFloatingActionButtonState createState() => _MyFloatingActionButtonState();
}

class _MyFloatingActionButtonState extends State<MyFloatingActionButton> {
  bool _showFab = true;
  bool _validateWord = false;

  final _controllerWord = TextEditingController();
  final _controllerMeaning = TextEditingController();
  final _controllerSentence = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _controllerWord.dispose();
    _controllerMeaning.dispose();
    _controllerSentence.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _showFab
        ? FloatingActionButton(
            elevation: 10,
            onPressed: () {
              Scaffold.of(context)
                  .showBottomSheet<void>(
                    (BuildContext context) {
                      return Container(
                          height: MediaQuery.of(context).size.height / 2,
                          color: Colors.grey[600],
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                              child: getBottomSheetChild(),
                            ),
                          ));
                    },
                  )
                  .closed
                  .then((value) => showFoatingActionButton(true));
              showFoatingActionButton(false);
            },
            backgroundColor: fabButton,
            splashColor: googleButtonBg,
            child: Icon(
              Icons.add,
              color: googleButtonText,
            ),
          )
        : Container();
  }

  showFoatingActionButton(bool value) {
    setState(() {
      _showFab = value;
    });
  }

  Column getBottomSheetChild() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Tooltip(
              message: 'Close',
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                color: googleButtonTextLight,
              ),
            )
          ],
        ),
        TextFormField(
          controller: _controllerWord,
          decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: googleButtonTextLight, width: 1.0),
              ),
              focusedBorder: new OutlineInputBorder(
                borderSide: BorderSide(color: googleButtonText, width: 1.5),
              ),
              border: const OutlineInputBorder(),
              errorText: _validateWord ? 'Word Cannot Be Empty' : null,
              errorStyle: TextStyle(letterSpacing: 1.5, color: lightRed),
              labelStyle:
                  new TextStyle(color: googleButtonText, letterSpacing: 1.5),
              labelText: 'Idom/Phrasal Verb'),
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
                  borderSide:
                      BorderSide(color: googleButtonTextLight, width: 1.0),
                ),
                focusedBorder: new OutlineInputBorder(
                  borderSide: BorderSide(color: googleButtonText, width: 1.5),
                ),
                border: const OutlineInputBorder(),
                labelStyle:
                    new TextStyle(color: googleButtonText, letterSpacing: 1.5),
                labelText: 'Meaning'),
            keyboardType: TextInputType.multiline,
            maxLines: 2,
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
                  borderSide:
                      BorderSide(color: googleButtonTextLight, width: 1.0),
                ),
                focusedBorder: new OutlineInputBorder(
                  borderSide: BorderSide(color: googleButtonText, width: 1.5),
                ),
                border: const OutlineInputBorder(),
                labelStyle:
                    new TextStyle(color: googleButtonText, letterSpacing: 1.5),
                labelText: 'Sentence'),
            keyboardType: TextInputType.multiline,
            maxLines: 2,
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
                child:
                Card(
                  elevation: 2,
                  color: googleButtonBg,
                  child: InkWell(
                      splashColor: googleButtonBg,
                      onTap: () {
                        processSaving();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Add',
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
                  elevation: 2,
                  color: googleButtonBg,
                  child: InkWell(
                      splashColor: googleButtonBg,
                      onTap: () {
                        _controllerMeaning.text = '';
                        _controllerSentence.text = '';
                        _controllerWord.text = '';
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Clear',
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
    );
  }

  processSaving() {
    setState(() {
      _controllerWord.text.isEmpty // checks if word section is empty
          ? _validateWord =
              true // if some one presses get button with empty word, show error message 'Word Cannot Be Empty'
          : _validateWord = false;
    });
    if (_controllerWord.text.isEmpty) {
      showToastMessage('Text cannot be empty');
      return;
    }

    IdomModel idomModel = IdomModel();
    idomModel.word = _controllerWord.text;
    idomModel.meaning = _controllerMeaning.text;
    idomModel.sentence = _controllerSentence.text;
    idomModel.time = DateTime.now().millisecondsSinceEpoch;

    dbHelper.insertIdom(idomModel).then((int value) {
      print('value: $value');
      if (value != 0) {
        showToastMessage("Succesfully added");
        _controllerMeaning.text = '';
        _controllerSentence.text = '';
        _controllerWord.text = '';
      } else {
        showToastMessage("Something added");
      }
    });
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
}
