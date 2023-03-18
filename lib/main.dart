// ignore_for_file: prefer_const_constructors

import 'package:esu_n_esu/gen/firebase_options_dev.dart' as dev;
import 'package:esu_n_esu/gen/firebase_options_prod.dart' as prod;
import 'package:esu_n_esu/home/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // NOTE: nameを指定しないとprodビルドする際に、デフォルトのFirebase Appを複数回作成してしまい、起動できなくなる
  await Firebase.initializeApp(name: 'name', options: getFirebaseOptions());
  runApp(MyApp());
}

FirebaseOptions getFirebaseOptions() {
  const flavor = String.fromEnvironment('flavor');
  switch (flavor) {
    case 'dev':
      print('$flavorでビルド');
      return dev.DefaultFirebaseOptions.currentPlatform;
    case 'prod':
      print('$flavorでビルド');
      return prod.DefaultFirebaseOptions.currentPlatform;
    default:
      throw ArgumentError('$flavorというフレーバーは存在しません');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
      routes: {
        "/home": (context) => HomePage(),
      },
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale("ja", "JP"),
      ],
    );
  }
}
