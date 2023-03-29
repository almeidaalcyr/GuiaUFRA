import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'card_contato.dart';
import '../contato.dart';

class RedeSocial extends StatelessWidget {
  late String rede;
  late String? valor;
  late String link;
  String? mensagem = "";
  RedeSocial(
    this.rede,
    this.valor,
    {this.mensagem}
  );

  @override
  Widget build(BuildContext context) {
    if (valor != null) {
      switch (rede) {
        case "whatsapp":
          link = "https://api.whatsapp.com/send?phone=+55$valor&text=$mensagem";
          valor = Contato.formataCelular(valor!);
          break;
        case "instagram":
          link = "https://www.instagram.com/$valor/";
          valor = "@$valor";
          break;
        case "facebook":
          link = "https://www.facebook.com/$valor/";
          break;
        case "youtube":
          link = "https://www.youtube.com/c/$valor/";
          break;
        case "twitter":
          link = "https://twitter.com/$valor/";
          break;
        case "telegram":
          link = "https://t.me/$valor/";
          break;
        default:
      }
      return GestureDetector(
        onTap: () async {
          await launch(link);
        },
        child: Container(
            width: 100,
            child: Column(

              children: [
                Image.asset(
                  'assets/imagens/$rede.png',
                  height: 40,
                  width: 40,
                ),
                Text(valor!),
              ],
            )
        ),

      );
    }
    return Wrap();
  }
}