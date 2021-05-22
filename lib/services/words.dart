import 'package:flutter/material.dart';

class Words {
  int id;
  int correct;
  int incorrect;
  String word;
  String pronunciation;
  String meaning;
  String sentence;


  Words({this.id, this.correct, this.incorrect, this.word,
      this.pronunciation, this.meaning, this.sentence});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'correct': correct,
      'incorrect': incorrect,
      'word': word,
      'pronunciation': pronunciation,
      'meaning': meaning,
      'sentence': sentence
    };
  }

  @override
  String toString() {
    return 'Words{id:$id, correct: $correct, incorrect: $incorrect, word: $word, pronunciation: $pronunciation, meaning: $meaning, sentence: $sentence}';
  }
}
