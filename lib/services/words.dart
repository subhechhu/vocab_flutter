class Words {
  int correct = 0;
  int incorrect = 0;
  String word = '';
  String pronunciation;
  String meaning;
  String sentence;
  int time = 0;

  Words(
      {this.correct,
      this.incorrect,
      this.word,
      this.pronunciation,
      this.meaning,
      this.sentence,
      this.time});

  Map<String, dynamic> toMap() {
    return {
      'correct': correct,
      'incorrect': incorrect,
      'word': word,
      'pronunciation': pronunciation,
      'meaning': meaning,
      'sentence': sentence,
      'time': time
    };
  }

  @override
  String toString() {
    return 'Words{correct: $correct, incorrect: $incorrect, word: $word, pronunciation: $pronunciation, meaning: $meaning, sentence: $sentence, time: $time}';
  }
}
