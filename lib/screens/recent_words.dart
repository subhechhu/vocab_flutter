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

  @override
  void initState() {
    super.initState();
    dbHelper
        .getDbInstance()
        .then((value) => dbHelper.getRecentWords(20).then((value) {
              setState(() {
                wordList = value;
                listSize = value.length;
              });
            }));
    getSharedPreference();
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
      ),
      body: Column(
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
                            onTap: () {
                              Navigator.pushNamed(context, '/add', arguments: {
                                'action': 'Modify Word',
                                'word': wordList[index],
                                'userId': userId,
                              });
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
                                    mainAxisAlignment: MainAxisAlignment.center,
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
    );
  }

  getSharedPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId') ?? '';
    print('userID: $userId');
  }
}
