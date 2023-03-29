// import 'dart:async';
// import 'dart:convert';
// import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:guiaufra/assets/provider.dart';
// import 'package:guiaufra/teste.dart';
import 'package:provider/provider.dart';

// import 'assets/provider.dart';
import 'homepage/homepage.dart';

void main() {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => ProviderClasse()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guia UFRA',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(color: Colors.blue),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.blue,
        ),
        primarySwatch: Colors.blue,
      ),
      //home: Teste(),
      home: const MyHomePage(title: 'Guia UFRA'),
      debugShowCheckedModeBanner: false,
    );
  }
}
