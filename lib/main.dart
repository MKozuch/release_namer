import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:window_size/window_size.dart';

import 'package:release_generator/title_provider.dart';

void main() async {

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
  late ReleaseNameGenerator gen;
  late ReleaseNameModelIndex idx;
  ReleaseNameWordsModel? model;

  TitleGeneratorCubit() : super(null) {
    gen = ReleaseNameGenerator();
    idx = ReleaseNameModelIndex();

    ReleaseNameWordsModel.create().then((value) {
      model = value;

      gen.model = model;
      idx.model = model;
      nextReleaseName();
    });
  }

  void nextReleaseName() {
    if (model == null) {
      emit(null);
    }

    idx = gen.randomIndex();
    
    emit(model!.nameAt(idx));
  }
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
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
                        context.read<TitleGeneratorCubit>().nextReleaseName();
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
