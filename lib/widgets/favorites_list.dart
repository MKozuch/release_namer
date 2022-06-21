import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'dart:core';

Future<void> registerDomain(BuildContext context, String str) async{
  str = str.toLowerCase().replaceAll(RegExp(r'\s+'), '');

  return await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Register domain"),
        content: Text("Do you want to open external site to try register domain '$str'"),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              final uri = Uri.https('domains.google.com', '/registrar/search', {'searchTerm': str});
              launchUrl(uri);
              Navigator.of(context).pop(true);
            },
            child: const Text("Ok")
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
        ],
      );
    },
  );
}

class FavoriteNames extends Cubit<List<String>>{
  late _PersistenceManager? _manager;

  FavoriteNames.withFilePersistence() : super([]){
    _manager = _FilePersistence('favorites.txt');
    _manager!.fetch().then((value) {
      if(value.isNotEmpty){
        _list.clear();
        _list.insertAll(0, value);
      }

      _emitState();
    },);
  }

  FavoriteNames() : super([]){
    _manager = null;
    _emitState();
  }

  final List<String> _list = [
    'Gorgeous Gorilla', 
    'Astute Armadillo', 
    'Menial Monkey', 
    'Wretched Wallaby', 
    'Quintessential Quokka', 
    'Salty Scallop',
  ];

  void _emitState(){
    emit(List.from(_list));
  }

  List<String> get() => _list;

  void add(String s){
    if(_list.contains(s)) _list.remove(s);
    _list.add(s);
    _emitState();
  }

  void remove(String s){
    _list.remove(s);
    _emitState();
  }
  
  void swap(int fromIdx, int toIdx) {
    if(fromIdx < toIdx) toIdx -= 1;
    _list.insert(toIdx, _list.removeAt(fromIdx));
    _emitState();
  }

  @override
  void onChange(Change<List<String>> change) {
    super.onChange(change);

    _manager?.save(change.nextState);
  }
}

Widget favoritesListBuilder(BuildContext context) =>
  BlocBuilder<FavoriteNames, List<String>>(
      builder: (context, list) {
        return list.isEmpty
            ? const Center(child: Text('Add something to favourite list'))
            : ReorderableListView.builder(
                buildDefaultDragHandles: true,
                itemCount: list.length,
                onReorder: (fromIdx, toIdx){
                  context.read<FavoriteNames>().swap(fromIdx, toIdx);
                },
                itemBuilder: (context, index){
                  final text = list[index];
                  return Padding(
                    key: ValueKey<String>(text),
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Dismissible(
                      direction: DismissDirection.horizontal,
                      key: ValueKey<String>(text),
                      background: Container(
                        color: Colors.green, 
                        alignment: AlignmentDirectional.centerStart,
                        child: const Icon(Icons.domain_add),
                      ),
                      secondaryBackground: Container(
                        color: Colors.red, 
                        alignment: AlignmentDirectional.centerEnd,
                        child: const Icon(Icons.delete),
                      ),
                      onDismissed: (DismissDirection _){
                        context.read<FavoriteNames>().remove(text);
                      },
                      confirmDismiss: (direction){
                        if(direction == DismissDirection.endToStart) return Future.value(true);
                        registerDomain(context, text);
                        return Future.value(false);
                      },
                      child: ListTile(
                        enableFeedback: true,
                        enabled: true,
                        dense: true,
                        title: Text(text),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              iconSize: 25,
                                icon: const Icon(Icons.copy),    
                                onPressed: () => Clipboard.setData(ClipboardData(text: text)),    
                              ),
                            IconButton(
                              iconSize: 25,
                              onPressed: ()=> context.read<FavoriteNames>().remove(text),
                              icon: const Icon(Icons.delete_outline),
                            )
                        ]
                        )
                      ),
                    ),
                  );
                },
              );
      },
  );


abstract class _PersistenceManager{
  void save(List<String> lst);
  Future<List<String>> fetch();
}

class _FilePersistence implements _PersistenceManager{
  final String _fileName;

  _FilePersistence(this._fileName);

  @override
  Future<List<String>> fetch() async{
    final file = await _localFile;
    return file.readAsLines();
  }

  @override
  void save(List<String> list) async{
    final file = await _localFile;
    file.openWrite();
    await file.writeAsString(list.join('\n'), mode: FileMode.writeOnly);
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$_fileName');
  }
}