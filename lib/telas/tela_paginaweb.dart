import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
//import 'package:webview_flutter/webview_flutter.dart';

class TelaPaginaweb extends StatelessWidget{
  String titulo;
  String site;
  TelaPaginaweb(this.titulo, this.site);
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("aaaa"),
      ),
      //body: WebView(
        //initialUrl: "https://sigaa.ufra.edu.br/sigaa/mobile/touch/login.jsf",
        //javascriptMode: JavascriptMode.unrestricted,

        
      //),
      
    );
    }
}
