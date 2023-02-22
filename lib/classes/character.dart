
/// Character class for generated characters
class Character {
  /// constructor
  Character(this.name, this.desc, this.vocab, this.characteristics);
  /// name of the character
  String name;
  /// description of character
  String desc;
  String vocab;
  /// list of characteristics that the character will refer to
  List<String> characteristics = [];
}
