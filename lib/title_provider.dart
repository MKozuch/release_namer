import 'dart:io';
import 'dart:math';

typedef Dict = Map<String, List<String>>;

class ReleaseNameModelIndex{
  String letter = '';
  int adjectiveIndex = 0;
  int animalIndex = 0;

  ReleaseNameWordsModel? model;


}

class ReleaseNameWordsModel{
  late Dict _animalDict;
  late Dict _adjectiveDict;
  static late ReleaseNameWordsModel _instance;

  ReleaseNameWordsModel._create();

  static Future<ReleaseNameWordsModel> create() async {
    var model = ReleaseNameWordsModel._create();

    var futures = <Future>[];
    futures.add(_makeDictAsync('./assets/animals.txt'           ).then((dict){model._animalDict    = dict;}));
    futures.add(_makeDictAsync('./assets/english-adjectives.txt').then((dict){model._adjectiveDict = dict;}));
    futures.add(Future.delayed(const Duration(seconds: 1))); // simulate fetching data
    await Future.wait(futures);

    return model;
  }

  List<String>? adjectivesForLetter(String s){
    return _adjectiveDict[s];
  }    
  List<String>? animalsForLetter(String s){
    return _animalDict[s];
  }

  bool isLetterValid(String s){
    return _animalDict[s]    != null && _animalDict[s]!.isNotEmpty
        && _adjectiveDict[s] != null && _adjectiveDict[s]!.isNotEmpty;
  }

  bool isIndexValid(ReleaseNameModelIndex idx){
    return this == idx.model
      && isLetterValid(idx.letter)
      && _adjectiveDict[idx.letter]!.length > idx.adjectiveIndex
      && _animalDict[idx.letter]!.length > idx.animalIndex;
  }

  String? nameAt(ReleaseNameModelIndex idx){
    if(isIndexValid(idx)){
      return '${_adjectiveDict[idx.letter]![idx.adjectiveIndex]} ${}';
    }
    return null;
  }

  String? adjectiveAt(ReleaseNameModelIndex idx){
    return isIndexValid(idx)
      ? _adjectiveDict[idx.letter]![idx.adjectiveIndex]
      : null;
  }
  String? animalAt(ReleaseNameModelIndex idx){
    return isIndexValid(idx)
      ? _animalDict[idx.letter]![idx.animalIndex]
      : null;
  }

  static Future<Dict> _makeDictAsync(String fileName) async{
    var dict = Dict();

    var file = File(fileName);
    file.readAsLinesSync().forEach((line) {
      line = line.trim().capitalize();
      if(line.isEmpty){
        return;
      }

      final startLetter = line.substring(0,1).toLowerCase();
      dict[startLetter] ??= []; 
      dict[startLetter]?.add(line.trim());
    });

    return dict;
  }
}


class ReleaseNameGenerator{
  late Random _rng;
  late ReleaseNameWordsModel _model;

  ReleaseNameGenerator(){
    _rng = Random();
  }

  set model(model){
    _model = model;
  }

  ReleaseNameModelIndex randomIndex(){
    var index = ReleaseNameModelIndex();
    index.model = _model;
    index.letter = _randomUsableLetter();
    index.adjectiveIndex = _rng.nextInt(_model.adjectivesForLetter(index.letter)!.length);
    index.animalIndex    = _rng.nextInt(_model.animalsForLetter(   index.letter)!.length);
    assert(_model.isIndexValid(index));
    return index;
  }

  String _randomUsableLetter(){
    var letter = _randomLetter();
    while(!_model.isLetterValid(letter)){
      letter = _randomLetter();
    }
    return letter;
  }


  String _randomDictEntryForLetter(Dict dict, String letter){
    return dict[letter]?.elementAt(_rng.nextInt(dict[letter]!.length)) ?? '';
  }

  bool _dictContainsLetter(Dict dict, String letter){
    return dict.containsKey(letter) && dict[letter]!.isNotEmpty;
  }

  String _randomDictEntry(Dict dict){
    var randomLetter = _randomLetter();
    while(!_dictContainsLetter(dict, randomLetter)){
      randomLetter = _randomLetter();
    }

    return _randomDictEntryForLetter(dict, randomLetter);
  }

  String _randomLetter(){
    final a = 'a'.codeUnitAt(0);
    final z = 'z'.codeUnitAt(0);
    return String.fromCharCode(_rng.nextInt(z-a)+a);
  }
}


extension StringExtension on String {
    String capitalize() {
      return split(' ')
        .map((e) => e[0].toUpperCase()+e.substring(1).toLowerCase())
        .join(' ');
    }
}