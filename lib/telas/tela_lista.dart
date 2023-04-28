import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:guiaufra/Cards/card_calendario.dart';
import 'package:guiaufra/Cards/card_switch_contato.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../Cards/card_checkbox_contato.dart';
import 'package:provider/src/provider.dart';
import '../contato.dart';
import '../Cards/card_contato.dart';
import '../evento.dart';

class TelaLista extends StatefulWidget {
  bool barraBusca = false;
  List <String> textoBusca = [];
  List <int> indicesResultadoBusca = [];
  late Busca _busca;
  String titulo = "";

  TelaLista(this._busca);

  @override
  _TelaListaState createState() => _TelaListaState();
}

enum Busca {
  localizacao,
  contato,
  evento,
}

class _TelaListaState extends State<TelaLista> {
  @override
  void initState(){
    super.initState();
    Timer.run(() {
      preencheTextoBusca();
    });
  }

  List <Card> cards = [];
  List <dynamic> coordenadas = [];

  TextEditingController controller = new TextEditingController();

  preencheTextoBusca(){
    if (widget._busca == Busca.localizacao) {
      widget.titulo = "Localização";
      setState(() {
        widget.textoBusca = Contato.nomeSigla;
      });
    }
    else if (widget._busca == Busca.contato){
      widget.titulo = "Contatos";
      setState(() {
        widget.textoBusca = Contato.nomeSigla;
      });
    }
    else if (widget._busca == Busca.evento){
      widget.titulo = "Eventos";
      setState(() {
        widget.textoBusca = Evento.eventosString;
      });
    }
  }

  void onTextoBuscaAlterado(String text) async {
    widget.indicesResultadoBusca.clear();
    if (text.isEmpty){
      setState(() {});
      return;
    }
    for (var element in widget.textoBusca) {
      if (element.toUpperCase().contains(text.toUpperCase())) {
        widget.indicesResultadoBusca.add(widget.textoBusca.indexOf(element));
      }
    }
    setState(() {});
  }

  Widget getCard(int indice){
    if (widget._busca == Busca.localizacao){
      return CardSwitchContato(indice, widget.textoBusca[indice]);
    }
    else if (widget._busca == Busca.contato){
      return CardContato(indice);
    }
    else if (widget._busca == Busca.evento){
      return CardCalendario(indice);
    }
    return Wrap();
  }

  Widget build(BuildContext context) {
    print(Evento.eventos.length);
    //print(Contato.contato[1].sigla);
    return Scaffold(
        appBar: AppBar(
            title:
            widget.barraBusca == false
                ? ListTile(
              title: Text(
                widget.titulo,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              trailing: IconButton(
                  icon: const Icon(
                    Icons.search,
                    color: Colors.white,),
                  onPressed: (){
                    setState(() {
                      widget.barraBusca = true;
                    });
                  }),
            )

                : ListTile(
              title: TextField(
                autofocus: true,

                decoration: InputDecoration(
                    hintText: "Busca ${widget.titulo}",
                    hintStyle: const TextStyle(
                      color: Colors.white54,
                      fontSize: 20,
                    )
                ),
                controller: controller,
                onChanged: onTextoBuscaAlterado,

              ),
              trailing: IconButton(
                  icon: const Icon(
                    Icons.cancel,
                    color: Colors.white,),
                  onPressed: (){
                    if (controller.text.isNotEmpty) {
                      controller.clear();
                      onTextoBuscaAlterado('');
                    }
                    setState(() {
                      widget.barraBusca = false;
                    });

                  }),
            )
        ),

        body: widget.barraBusca && widget.indicesResultadoBusca.isEmpty && controller.text.isNotEmpty
            ? const Center(child: Text("A busca não possui resultados"),)
            : Column(
            children: [
              Expanded(
                  child: widget.indicesResultadoBusca.isNotEmpty || controller.text.isNotEmpty
                      ? ListView.builder(
                      itemCount: widget.indicesResultadoBusca.length,
                      itemBuilder: (context, i){
                        return getCard(widget.indicesResultadoBusca[i]);
                      })
                      : ListView.builder(
                      itemCount: widget.textoBusca.length,
                      itemBuilder: (context, i){
                        return getCard(i);
                      })
              ),
            ]
        )
    );
  }
}