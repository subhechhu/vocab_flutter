class IdomModel {
  String word = '';
  String meaning;
  String sentence;
  int time = 0;
  int id = 0;

  IdomModel({this.id, this.word, this.meaning, this.sentence, this.time});

  Map<String, dynamic> toMap() {
    return {
      'word': word,
      'id': id,
      'meaning': meaning,
      'sentence': sentence,
      'time': time
    };
  }

  @override
  String toString() {
    return 'Words{word: $word, id: $id, meaning: $meaning, sentence: $sentence, time: $time}';
  }
}
