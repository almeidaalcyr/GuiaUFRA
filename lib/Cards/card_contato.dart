
import 'package:flutter/material.dart';
import '../telas/tela_detalhes_contato.dart';
import 'package:provider/src/provider.dart';
import '../assets/provider.dart';
import '../contato.dart';

class CardContato extends StatelessWidget{
  late Map<String, dynamic> contato;
  late int indice;

  CardContato(this.indice);

  @override
  Widget build(BuildContext context) {
    if (Contato.contato[indice].possuiContato) {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) {
                    return TelaDetalhesContato(indice);
                  }
              )
          );
        },
        child: ListTile(
          title: Text(Contato.contato[indice].nome),
          subtitle: Text(Contato.contato[indice].sigla ?? ""),

        ),
      );
    }
    return Wrap();
  }
}