import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:guiaufra/notification.dart';
import 'package:provider/provider.dart';

class Teste extends StatefulWidget {
  @override
  _TesteState createState() => _TesteState();
}

class _TesteState extends State<Teste> {
  @override
  Widget build(BuildContext context) {
    return Consumer<localizacao>(builder: (ctx, channel, _){
      return Scaffold(
          appBar: AppBar(
            title: const Text("~~"),
          ),
          body: Text("asdf"),
          floatingActionButton: FloatingActionButton.extended(
              label: const Text("envia"),
              icon: const Icon(Icons.send,),
              onPressed: () {
                print("envia");
                channel.onSend("x");
              }
          )
      );
    });
  }
}