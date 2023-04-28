import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:guiaufra/Cards/card_switch_contato.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../Cards/card_checkbox_contato.dart';
import '../Cards/card_link_contato.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Cards/card_rede_social.dart';
import '../main.dart';
import '../contato.dart';

class TelaDetalhesContato extends StatefulWidget {
  late int indice;

  TelaDetalhesContato(this.indice);

  @override
  _TelaDetalhesContatoState createState() => _TelaDetalhesContatoState();
}

class _TelaDetalhesContatoState extends State<TelaDetalhesContato> {
  @override
  void initState() {
    super.initState();
    Timer.run(() {
      carregaPOIs();
    });
  }

  carregaPOIs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {});
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Contato.contato[widget.indice].sigla != null
        ? Text(Contato.contato[widget.indice].sigla!)
        : const Text(""),
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(0, 20, 0, 30),
              child: Text(Contato.contato[widget.indice].nome, textAlign: TextAlign.left, style: const TextStyle(fontSize: 30),)
            ),

            CardLinkContato("telefone", Contato.contato[widget.indice].telefone),
            //CardTelaContato("ramal", Contato.contato[widget.indice].ramal),
            CardLinkContato("email", Contato.contato[widget.indice].email),
            CardLinkContato("site", Contato.contato[widget.indice].site),
            CardSwitchContato(widget.indice, "Exibir no mapa", exibirIcone: false,),
            CardRedeSocial(widget.indice)
            
          ]
        ),
      )
    );
  }
}