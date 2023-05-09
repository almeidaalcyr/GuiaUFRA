// import 'dart:async';
// import 'dart:convert';
// import 'dart:developer';

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'contato.dart';
import 'evento.dart';
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

List <dynamic> calendario = [];
List <dynamic> contato = [];
List <String>? exibirPOI= [];
List <bool> exibirPOIb = [];

carregaJSON() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Carrega o calendario academico do JSON
  await rootBundle.loadString('assets/calendarioacademico2021.json').then((value) {
    calendario = json.decode(value);
    calendario.map((e) {
      Evento.eventos.add(Evento(
        id: calendario.indexOf(e).toString(),
        evento: e['evento'],
        datas: e['datas'],
        intervalo: e['intervalo'],
      ));

    }).toList();

  });

  // Carrega a lista de contatos do JSON
  await rootBundle.loadString('assets/localizacao.json').then((value) {
    contato = json.decode(value);
    contato.map((e) {
      Contato.contato.add(Contato(
        id: contato.indexOf(e).toString(),
        nome: e['nome'],
        sigla: e['sigla'],
        icone: Contato.getIcone(e['icone']),
        cor: Contato.getCor(e['cor']),
        telefone: e['telefone'],
        email: e['email'],
        site: e['site'],
        coordenadas: e['coordenadas'],
        whatsapp: e['whatsapp'],
        instagram: e['instagram'],
        facebook: e['facebook'],
        youtube: e['youtube'],
        twitter: e['twitter'],
        telegram: e['telegram'],
      ));
    }).toList();


      Contato.contato.sort((a,b) => a.nome.compareTo(b.nome));
      contato.sort((a,b) => a["nome"].compareTo(b["nome"]));
      Contato.nomeSigla.sort();


    //Verifica se o "exibirPOI" existe. se não, cria ele
    if (prefs.getStringList("exibirPOI") == null){
      exibirPOI = List.filled(contato.length, "0");
      prefs.setStringList("exibirPOI", exibirPOI!);
    }
    else {
      // Se o "exibirPOI" estiver preenchido, mas com o tamanho errado, preenche de novo
      exibirPOI = prefs.getStringList("exibirPOI");
      if (exibirPOI?.length != contato.length){
        exibirPOI = List.filled(contato.length, "0"); // mudar para 0
        prefs.setStringList("exibirPOI", exibirPOI!);
      }
    }

    for (int i = 0; i < exibirPOI!.length; i++) {
      print(exibirPOI![i]);
      if (exibirPOI![i] == "1") {
        Contato.contato[i].exibirNoMapa = true;
      }
      else {
        Contato.contato[i].exibirNoMapa = false;
      }
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    carregaJSON();
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
      home: TelaMapa(), //Teste(),//TelaMapa(), //MyHomePage(title: 'Guia UFRA'),//TelaMapa(),
      debugShowCheckedModeBanner: false,
    )
    );
  }
}
