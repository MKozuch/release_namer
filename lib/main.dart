import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:window_size/window_size.dart';

import 'package:release_generator/pages/release_name_generator.dart';
import 'package:release_generator/widgets/favorites_list.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('Release namer');
    setWindowMinSize(const Size(400, 300));
    setWindowMaxSize(Size.infinite);
    setWindowFrame(const Rect.fromLTWH(0, 0, 400, 30));
  }

  runApp(const ReleaseNamerApp());
}


class ReleaseNamerApp extends StatelessWidget {
  const ReleaseNamerApp({super.key});

  @override
  Widget build(BuildContext context) =>
    MultiBlocProvider(
      providers: [
        BlocProvider<FavoriteNames>(
          create: (BuildContext _){
            return FavoriteNames();
          },
          lazy: false,
        )
      ],
      child: MaterialApp(
        themeMode: ThemeMode.dark,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.amber, brightness: Brightness.light),
          textTheme: GoogleFonts.latoTextTheme(),
        ),
        home: Scaffold(
          appBar: AppBar(
              title: const Text('Release name generator'),
              actions: const [
                Icon(Icons.air),
              ]),
          drawer: Drawer(
            child: favoritesListBuilder(context),
          ),
        body: const Page1(),
      ),
    ),
  );
}

