import 'dart:math';

String getCorrectMessage(name) {
  List<String> message = [
    'Well Done, $name. Try another',
    'You Just Nailed It. What about this one, $name?',
    'Good Job, $name. I bet you can answer this one too',
    'You are right, $name. Try the next one',
    'Bravo! You\'re Correct. Keep it up, $name',
    'How did you get so good, $name?? Can you answer this though?',
    'Simply Superb, $name. What about this?',
    'Brilliant Work, $name. Answer this now.',
    'Top Notch. Keep it up, $name',
    'Good Going, $name. Try Next'
  ];
  return message[Random().nextInt(message.length)];
}

String getShortCorrectMessage() {
  List<String> message = [
    'Sweet',
    'Great',
    'Cool',
    'That was easy, isn\'t  it?',
    'Is there any word that you don\'t remember?',
    'Nice',
    'Amazing',
    'WoooHooo'
  ];
  return message[Random().nextInt(message.length)];
}

String getWrongMessage(name) {
  List<String> message = [
    'Oops!! That\'s Incorrect, $name',
    'I\'m afarid that\'s not quite right, $name.',
    'I\'m afraid you\'re mistaken, $name.',
    'No $name, you\'ve got it wrong this time',
    'It doesn\' look right. Does it, $name?',
    'Oh no, that’s not correct, $name',
    'Where did you hear that, $name?',
    '$name, You got it wrong. Memorize it next time.',
  ];
  return message[Random().nextInt(message.length)];
}

String getDontTapMeText(name) {
  List<String> message = [
    'Seriously, $name? Again?',
    'Will you stop tapping me, $name?',
    'Good god, $name. Do you remember anything?',
    'Stop pressing me, $name',
    'Give some effort, $name. Please?',
    'Learn! Learn!!, Learn!!!'
  ];
  return message[Random().nextInt(message.length)];
}
