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

class ReleaseNamGeneratorState{
  String adjective = '';
  String animal = '';
  String get fullName => '$adjective $animal'; 

  ReleaseNamGeneratorState(this.adjective, this.animal);
}

class ReleaseGeneratorCubit extends Cubit<ReleaseNamGeneratorState?> {
  late ReleaseNameGenerator gen;
  late ReleaseNameModelIndex idx;
  ReleaseNameWordsModel? model;

  ReleaseGeneratorCubit() : super(null) {
    gen = ReleaseNameGenerator();
    idx = ReleaseNameModelIndex();

    ReleaseNameWordsModel.create().then((value) {
      model = value;

      gen.model = model;
      idx.model = model;
      randomReleaseName();
    });
  }

  void randomReleaseName() {
    if (model == null) {
      emit(null);
    }

    idx = gen.randomIndex();
    _emitState();
  }

  void nextAdjective(){
    idx.nextAdjective();
    _emitState();
  }
  void nextAnimal(){
    idx.nextAnimal();
    _emitState();
  }


  void _emitState(){
    emit(ReleaseNamGeneratorState(model!.adjectiveAt(idx)!, model!.animalAt(idx)!));
  }
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: BlocProvider(
        create: (context) => ReleaseGeneratorCubit(), child: Page1()));
  }
}

class Page1 extends StatelessWidget {
  Page1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Release name generator')),
      body: Center(
        child: BlocBuilder<ReleaseGeneratorCubit, ReleaseNamGeneratorState?>(
          builder: (contex, state) {
            final isLoading = context.read<ReleaseGeneratorCubit>().state == null;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isLoading) 
                 ...[ 
                   Row(
                    children: [
                      Text(state!.adjective),
                      TextButton(
                        onPressed: ()=> context.read<ReleaseGeneratorCubit>().nextAdjective(), 
                        child: const Icon(Icons.skip_next)
                      )
                   ],
                  ),
                  Row(
                    children: [
                      Text(state!.animal),
                      TextButton(
                        onPressed: ()=> context.read<ReleaseGeneratorCubit>().nextAnimal, 
                        child: const Icon(Icons.skip_next)
                      )
                   ],
                  ),

                    ElevatedButton(
                      child: const Text('Generate'),
                      onPressed: () {
                        context.read<ReleaseGeneratorCubit>().randomReleaseName();
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
