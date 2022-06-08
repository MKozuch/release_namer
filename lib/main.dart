import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:window_size/window_size.dart';

import 'package:release_generator/title_provider.dart';

void main() async {
  // var pew = await ReleaseNameGenerator.create();
  // for(var i =0; i<10; ++i){
  //   print(pew.generate());
  //}

  runApp(MyApp());
}

class TitleGeneratorCubit extends Cubit<String> {
  static final List<String> _lst = [
    'Bustling Bat',
    'Frayed Felidae',
    'Greedy Goldfish',
    'Grown Giant Panda',
    'Humming Hare',
    'Jaded Jay',
    'Livid List',
    'Pure Pony',
    'Rundown Rhinoceros',
    'Yellow Yak',
  ];

  var _currentIndex = 0;

  TitleGeneratorCubit() : super(_lst[0]);

  void next() {
    _currentIndex++;
    _currentIndex %= _lst.length;
    emit(_lst[_currentIndex]);
  }
}

class MyApp extends StatelessWidget {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('Flutter Demo');
    setWindowMinSize(const Size(400, 300));
    setWindowMaxSize(Size.infinite);
  }


  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: BlocProvider(
            create: (context) => TitleGeneratorCubit(), child: Page1()));
  }
}

class Page1 extends StatelessWidget {
  Page1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Release name generator')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BlocBuilder<TitleGeneratorCubit, String>(
                builder: (context, str) => Text(str)),
            ElevatedButton(
              child: const Text('Generate'),
              onPressed: () {
                context.read<TitleGeneratorCubit>().next();
              },
            )
          ],
        )
      )
    );
  }
}
