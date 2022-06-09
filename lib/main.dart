import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:window_size/window_size.dart';

import 'package:release_generator/title_provider.dart';

void main() async {
  // var pew = await ReleaseNameGenerator.create();
  // for(var i =0; i<10; ++i){
  //   print(pew.generate());
  //}

  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('Release namer');
    setWindowMinSize(const Size(400, 300));
    setWindowMaxSize(Size.infinite);
    setWindowFrame(const Rect.fromLTWH(0, 0, 640, 480));
  }

  runApp(MyApp());
}

class TitleGeneratorCubit extends Cubit<String?> {
  ReleaseNameGenerator? gen;

  TitleGeneratorCubit() : super(null) {
    ReleaseNameGenerator.create().then((value) {
      gen = value;
      next();
    });
  }

  void next() {
    if (gen == null) {
      emit(null);
    }

    emit(gen!.generate());
  }
}

class MyApp extends StatelessWidget {
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
        child: BlocBuilder<TitleGeneratorCubit, String?>(
          builder: (contex, str) {
            final isLoading = context.read<TitleGeneratorCubit>().state == null;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isLoading) 
                 ...[ 
                    Text(str ?? 'Loading'),
                    ElevatedButton(
                      child: const Text('Generate'),
                      onPressed: () {
                        context.read<TitleGeneratorCubit>().next();
                      },
                    ),
                  ],
                if (isLoading) const CircularProgressIndicator()
              ],
            );
          },
        ),
      ),
    );
  }
}
