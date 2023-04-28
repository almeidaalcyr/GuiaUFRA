import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guiaufra/telas/tela_lista.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'card_home.dart';
import '../contato.dart';
import '../evento.dart';
import '../telas/mapa.dart';
import '../telas/tela_paginaweb.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState(){
    super.initState();
    Timer.run(() {
      carregaJSON();
    });
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
      setState(() {

      });
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

      setState(() {
        Contato.contato.sort((a,b) => a.nome.compareTo(b.nome));
        contato.sort((a,b) => a["nome"].compareTo(b["nome"]));
        Contato.nomeSigla.sort();
      });


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

  @override
  Widget build(BuildContext context) {
    //context.read<ProviderClasse>().setCalendario(calendario);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Guia UFRA - Campus Belém"),
      ),
      body: Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          height: double.infinity,
          child: GridView(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 4 / 4,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              children: [
                Cardhome("Mapa", wg: TelaMapa(), icone: Icons.map_outlined, ),
                Cardhome("Calendário\nAcadêmico", wg: TelaLista(Busca.evento), icone: Icons.date_range),
                //Cardhome("SIGAA", siteMobile: "https://sigaa.ufra.edu.br/sigaa/mobile/touch/login.jsf", siteDesktop: "https://autenticacao.ufra.edu.br/sso-server/login?service=http%3A%2F%2Fsigaa.ufra.edu.br%2Fsigaa%2Flogin%2Fcas", icone: Icons.school),
                //Cardhome("SIPAC", siteMobile: "https://sipac.ufra.edu.br/sipac/mobile/touch/public/principal.jsf", siteDesktop: "https://sipac.ufra.edu.br/public/jsp/portal.jsf", icone: Icons.school),
                Cardhome("Contatos", wg: TelaLista(Busca.contato), icone: Icons.call),
                //Cardhome("GLPI", siteDesktop: "http://suporte.ufra.edu.br/glpi/plugins/formcreator/front/formdisplay.php?id=1", imagem: "glpi.png"),
              ]
          )
      ),

      /*drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
              ),
              child: Text('Teste Drawer'),
            ),
            ListTile(
              title: const Text('Item 1'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Item 2'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),*/
    );
  }
}
