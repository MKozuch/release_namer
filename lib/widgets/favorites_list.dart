import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

class FavoriteNames extends Cubit<List<String>>{
  FavoriteNames() : super([]){
    emit(_list);
  }

  List<String> _list = ['Gorgeous Gorilla', 'Astute Armadillo', 'Menial Monkey', 'Wretched Wallaby', 'Quintessential Quokka'];
  //List<String> _list = [];

  List<String> get() => _list;

  void add(String s){
    _list.add(s);
    emit(List.from(_list));
  }

  void remove(String s){
    _list.remove(s);
    emit(List.from(_list));
  }
}

Widget favoritesListBuilder(BuildContext context) =>
    BlocBuilder<FavoriteNames, List<String>>(
        builder: (context, list) {
          return list.isEmpty
              ? const Center(child: Text('Add something to favourite list'))
              : ListView.builder( // why this does not get called on emit?
                  itemCount: list.length,
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
