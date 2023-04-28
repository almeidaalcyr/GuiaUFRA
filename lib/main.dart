// import 'dart:async';
// import 'dart:convert';
// import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'notification.dart';

// import 'assets/provider.dart';
import 'homepage/homepage.dart';
import 'telas/mapa.dart';

void main() {
  runApp(/*MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => ProviderClasse()),
  ], child: const MyApp())*/
  const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LocalizacaoBage>(
        create: (ctx) => (LocalizacaoBage()),
    child:MaterialApp(
      title: 'Guia UFRA',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(color: Colors.blue),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.blue,
        ),
        primarySwatch: Colors.blue,
      ),
      //home: Teste(),
      home: MyHomePage(title: 'Guia UFRA'), //Teste(),//TelaMapa(), //MyHomePage(title: 'Guia UFRA'),//TelaMapa(),
      debugShowCheckedModeBanner: false,
    )
    );
  }
}
