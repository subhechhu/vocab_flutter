import 'package:flutter/material.dart';
import 'package:vocab/services/db_helper.dart';
import 'package:vocab/services/words.dart';
import 'package:vocab/util/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecentWords extends StatefulWidget {
  @override
  _RecentWordsState createState() => _RecentWordsState();
}

class _RecentWordsState extends State<RecentWords> {
  DbHelper dbHelper = DbHelper();
  List<Words> wordList;
  int listSize = 0;
  String userId = '';
  int _defaultRecentSize = 15;
  bool _shouldRefresh = false;
  TextEditingController _controllerListSize = TextEditingController();

  @override
  void initState() {
    super.initState();
    dbHelper.getDbInstance().then((value) => fetchRecent(_defaultRecentSize));
    getSharedPreference();
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
                          color: primaryColor,
                          child: InkWell(
                              splashColor: googleButtonBg,
                              onTap: () async {
                                dynamic result = await Navigator.pushNamed(
                                    context, '/add',
                                    arguments: {
                                      'action': 'Modify Word',
                                      'word': wordList[index],
                                      'userId': userId,
                                    });
                                _shouldRefresh = result['shouldRefresh'];
                                if (_shouldRefresh) {
                                  fetchRecent(_defaultRecentSize);
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
    userId = prefs.getString('userId') ?? '';
    print('userID: $userId');
  }

  fetchRecent(defaultRecentSize) {
    dbHelper.getRecentWords(defaultRecentSize).then((value) {
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
                    borderSide: BorderSide(color: dialogBg, width: 1.0),
                  ),
                  focusedBorder: new OutlineInputBorder(
                    borderSide: BorderSide(color: dialogBg, width: 1.5),
                  ),
                  border: const OutlineInputBorder(),
                  labelStyle:
                      new TextStyle(letterSpacing: 1.5, color: dialogBg),
                  labelText: 'List Size'),
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    _defaultRecentSize = int.parse(_controllerListSize.text);
                    fetchRecent(_defaultRecentSize);
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
