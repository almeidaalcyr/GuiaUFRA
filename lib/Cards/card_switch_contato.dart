//import 'dart:js';

import 'package:flutter/material.dart';
// ignore: implementation_imports
import 'package:provider/src/provider.dart';
import '../antigos/contato.dart';

class CardSwitchContato extends StatefulWidget{
  int indice;
  String texto;
  bool exibirIcone;

  CardSwitchContato(
    this.indice,
    this.texto,
    {this.exibirIcone = true});
  @override
_CardSwitchContatoState createState() => _CardSwitchContatoState();
}

class _CardSwitchContatoState extends State<CardSwitchContato>{
  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
        secondary: widget.exibirIcone
        ? Icon(Contato.contato[widget.indice].icone,
          color: Contato.contato[widget.indice].cor,)
        : const Icon(Icons.map_outlined),
        title: Text(Contato.contato[widget.indice].nome),
        subtitle: Text(Contato.contato[widget.indice].sigla ?? ""),
        value: Contato.contato[widget.indice].exibirNoMapa,
        onChanged: (bool? value) {
          Contato.alteraExibirNoMapa(widget.indice);
          setState((){});
        },
    );
  }
}