import 'dart:io';
import 'dart:math';

typedef Dict = Map<String, List<String>>;

class ReleaseNameGenerator{

  late Dict _animalDict;
  late Dict _adjectiveDict;
  late Random _rng;

  ReleaseNameGenerator._create();

  static Future<ReleaseNameGenerator> create() async{
    var generator = ReleaseNameGenerator._create();

    var futures = <Future>[];
    futures.add(_makeDictAsync('./assets/animals.txt'           ).then((dict){generator._animalDict    = dict;}));
    futures.add(_makeDictAsync('./assets/english-adjectives.txt').then((dict){generator._adjectiveDict = dict;}));

    generator._rng = Random();
    await Future.wait(futures);

    return generator;
  }

  String generate(){
    var letter = _randomLetter();
    while(!_dictContainsLetter(_animalDict, letter) || !_dictContainsLetter(_adjectiveDict, letter)){
      letter = _randomLetter();
    }

    return ("${_randomDictEntryForLetter(_adjectiveDict, letter)} ${_randomDictEntryForLetter(_animalDict, letter)}").capitalize();
  }

  String _randomDictEntryForLetter(Dict dict, String letter){
    return dict[letter]?.elementAt(_rng.nextInt(dict[letter]!.length)) ?? '';
  }

  bool _dictContainsLetter(Dict dict, String letter){
    return dict.containsKey(letter) && dict[letter]!.isNotEmpty;
  }

  String _randomDictEntry(Dict dict){
    var randomLetter = _randomLetter();
    while(!_dictContainsLetter(dict, randomLetter))
      randomLetter = _randomLetter();

    return _randomDictEntryForLetter(dict, randomLetter);
  }

  static Future<Dict> _makeDictAsync (String fileName) async{
    var dict = Dict();

    var file = File(fileName);
    file.readAsLinesSync().forEach((line) {
      line = line.trim();
      if(line.isEmpty)
        return;

      final startLetter = line.substring(0,1).toLowerCase();
      dict[startLetter] ??= []; 
      dict[startLetter]?.add(line.trim());
    });

    return dict;
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