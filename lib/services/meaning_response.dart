/// pronunciation : "stōk"
/// word : "stoke"
/// definitions : [{"type":"verb","definition":"add coal or other solid fuel to (a fire, furnace, boiler, etc.).","example":"he <b>stoked up</b> the barbecue","image_url":null,"emoji":null}]

class MeaningResponse {
  String _pronunciation;
  String _word;
  List<Definitions> _definitions;

  String get pronunciation => _pronunciation;
  String get word => _word;
  List<Definitions> get definitions => _definitions;

  MeaningResponse({
      String pronunciation, 
      String word, 
      List<Definitions> definitions}){
    _pronunciation = pronunciation;
    _word = word;
    _definitions = definitions;
}

  MeaningResponse.fromJson(dynamic json) {
    _pronunciation = json["pronunciation"];
    _word = json["word"];
    if (json["definitions"] != null) {
      _definitions = [];
      json["definitions"].forEach((v) {
        _definitions.add(Definitions.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["pronunciation"] = _pronunciation;
    map["word"] = _word;
    if (_definitions != null) {
      map["definitions"] = _definitions.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// type : "verb"
/// definition : "add coal or other solid fuel to (a fire, furnace, boiler, etc.)."
/// example : "he <b>stoked up</b> the barbecue"
/// image_url : null
/// emoji : null

class Definitions {
  String _type;
  String _definition;
  String _example;
  dynamic _imageUrl;
  dynamic _emoji;

  String get type => _type;
  String get definition => _definition;
  String get example => _example;
  dynamic get imageUrl => _imageUrl;
  dynamic get emoji => _emoji;

  Definitions({
      String type, 
      String definition, 
      String example, 
      dynamic imageUrl, 
      dynamic emoji}){
    _type = type;
    _definition = definition;
    _example = example;
    _imageUrl = imageUrl;
    _emoji = emoji;
}

  Definitions.fromJson(dynamic json) {
    _type = json["type"];
    _definition = json["definition"];
    _example = json["example"];
    _imageUrl = json["image_url"];
    _emoji = json["emoji"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["type"] = _type;
    map["definition"] = _definition;
    map["example"] = _example;
    map["image_url"] = _imageUrl;
    map["emoji"] = _emoji;
    return map;
  }

}