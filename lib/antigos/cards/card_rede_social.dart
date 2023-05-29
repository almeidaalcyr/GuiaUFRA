import 'package:flutter/material.dart';
import 'package:guiaufra/antigos/cards/card_icone_rede_social.dart';
import 'package:url_launcher/url_launcher.dart';
import '../contato.dart';


class CardRedeSocial extends StatelessWidget {
  late int indice;

  late double tamanho;
  String mensagem = "";

  CardRedeSocial(
    this.indice,
    {
      double this.tamanho = 30,
      String this.mensagem = ""
    }
  );


  @override
  Widget build(BuildContext context) {
    if (Contato.contato[indice].possuiRedeSocial) {
      return Container(
        padding: EdgeInsets.all(5),
        child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text("Redes Sociais", textAlign: TextAlign.left),
                Row(
                  children: [
                    RedeSocial("whatsapp", Contato.contato[indice].whatsapp),
                    RedeSocial("instagram", Contato.contato[indice].instagram),
                    RedeSocial("facebook", Contato.contato[indice].facebook),
                    RedeSocial("youtube", Contato.contato[indice].youtube),
                    RedeSocial("twitter", Contato.contato[indice].twitter),
                    RedeSocial("telegram", Contato.contato[indice].telegram),
                  ],
                ),
              ]
          ),
      );
    }
    return Wrap();
  }
}