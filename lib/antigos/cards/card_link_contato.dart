import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'card_contato.dart';
import '../contato.dart';

class CardLinkContato extends StatelessWidget{
  late String campo;
  late List<dynamic>? valor;
  Icon icone = const Icon(Icons.stairs);
  String protocolo = "";

  CardLinkContato(this.campo, this.valor){
    switch (this.campo) {
      case "telefone":
        icone = const Icon(Icons.call);
        protocolo = "tel:";
        break;
      case "email":
        icone = const Icon(Icons.mail);
        protocolo = "mailto:";
        break;
      case "site":
        icone = const Icon(Icons.link);
        protocolo = "";
        break;

      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    if (this.valor != null) {
      return  Column(
          children: [
            ...valor!.map((e) {
              String valor_novo = "";
              switch (campo) {
                case "telefone":
                  valor_novo = Contato.formataCelular(e);
                  break;
                default:
                  valor_novo = e;
                  break;
              }
              return GestureDetector(
                  onTap: () async {
                    await launch("$protocolo$e");
                  },
                  child: ListTile(
                    leading: icone,
                    title: campo != "telefone"
                        ? Text(e)
                        : Text(valor_novo),
                    subtitle: Text(campo),
                  )
              );
            })
          ]
      );
    }
    return Wrap();
  }
}