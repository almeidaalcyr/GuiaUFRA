//import 'dart:js';

import 'package:flutter/material.dart';
import 'package:guiaufra/Cards/card_exibir_contato.dart';
import '../contato.dart';

class CardCheckboxContato extends StatefulWidget{
  int indice;
  String texto;
  bool exibirIcone;

  CardCheckboxContato(
    this.indice,
    this.texto,
    {this.exibirIcone = true});
  @override
_CardCheckboxContatoState createState() => _CardCheckboxContatoState();
}

class _CardCheckboxContatoState extends State<CardCheckboxContato>{
  @override
  Widget build(BuildContext context) {
    return Card(
      child: CheckboxListTile(
        secondary: widget.exibirIcone
        ? Icon(Contato.contato[widget.indice].icone,
          color: Contato.contato[widget.indice].cor,)
        : const Icon(Icons.map_outlined),
        title: Text(widget.texto),
        value: Contato.contato[widget.indice].exibirNoMapa,
        onChanged: (bool? value) {
          Contato.alteraExibirNoMapa(widget.indice);
          setState((){});
        },
      ),
    );
  }
}