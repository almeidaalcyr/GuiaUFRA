import 'dart:io';

import 'package:flutter/material.dart';
// import 'package:provider/src/provider.dart';
import 'package:url_launcher/url_launcher.dart';
// import '../assets/provider.dart';

class Cardhome extends StatelessWidget{
  late String texto;
  late IconData? icone;
  late String? imagem;
  late Widget? wg;
  late String? siteDesktop;
  late String? siteMobile;

  Cardhome(
    this.texto,
    {
      this.wg,
      this.siteDesktop,
      this.siteMobile,
      this.icone,
      this.imagem
    }
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (wg != null ){
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_){
                return wg!;
              }
            )
          );
        }
        else {
          try {
            if (Platform.isAndroid) {
              if (siteMobile != null) {
                await launch(siteMobile!);
              }
              else {
                await launch(siteDesktop!);    
              }
            }
          }
          catch (e) {
            await launch(siteDesktop!);
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Theme.of(context).primaryColor
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            imagem != null
            ? Image.asset(
                'assets/imagens/$imagem',
                height: 100,
                width: 100,
              )
            : Icon(
                icone,
                size: 84,
                color: Colors.black54,
              ),
            Text(
              texto,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white
              )
            ),
          ],
        ),
      )
    );
  }
}