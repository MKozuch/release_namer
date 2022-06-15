import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

class FavoriteNames extends Cubit<List<String>>{
  FavoriteNames() : super([]){
    emit(_list);
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
}

Widget favoritesListBuilder(BuildContext context) =>
    BlocBuilder<FavoriteNames, List<String>>(
        builder: (context, list) {
          return list.isEmpty
              ? const Center(child: Text('Add something to favourite list'))
              : ReorderableListView.builder(
                  itemCount: list.length,
                  onReorder: (fromIdx, toIdx){
                    context.read<FavoriteNames>().swap(fromIdx, toIdx);
                  },
                  itemBuilder: (context, index){
                    final text = list[index];
                    return Dismissible(
                      direction: DismissDirection.endToStart,
                      key: ValueKey<String>(text),
                      background: Container(
                        color: Colors.red, 
                        alignment: AlignmentDirectional.centerEnd,
                        child: const Icon(Icons.delete),
                      ),
                      onDismissed: (DismissDirection _){
                        context.read<FavoriteNames>().remove(text);
                      },
                      child: ListTile(
                        dense: true,
                        title: Text(text),
                        trailing: TextButton(
                          onPressed: ()=> context.read<FavoriteNames>().remove(text),
                          child: const Icon(Icons.star_border),
                        )
                      ),
                    );
                  },
                );
        },
    );
