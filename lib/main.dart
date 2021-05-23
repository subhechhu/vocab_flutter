import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:vocab/screens/add_words.dart';
import 'package:vocab/screens/all_words.dart';
import 'package:vocab/screens/home.dart';
import 'package:vocab/screens/login.dart';
import 'package:vocab/screens/recent_words.dart';
import 'package:vocab/screens/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/': (context) => Splash(),
        '/login': (context) => Login(),
        '/home': (context) => Home(),
        '/add': (context) => AddWord(),
        '/view_all': (context) => AllWords(),
        '/view_recent': (context) => RecentWords()
      }));
}
