import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class localizacao extends ChangeNotifier {
  static const String serverUrl = 'ws://10.10.200.189:9000';
  late WebSocketChannel channel;

  localizacao(){
    this.channel = WebSocketChannel.connect(Uri.parse(serverUrl));
    try {
      this.channel?.stream.listen(
            (data) => onData(data),
        onDone: () => onDone(),
      );
    } catch (e) {
      print("Não foi possível conectar!");
    }
    print("LOCALIZACAO CRIADO");
  }

  onData(data) {
    print(data);
    notifyListeners();
    //this.onSend("x");
  }

  onDone(){
    print("onDone chamado");
  }

  onSend(msg){
    print("onSend chamado!");
    try {
      this.channel?.sink.add(msg);
    } catch (e){
      print("não foi possível enviar");
    }
  }
}