import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'assets/marcador.dart';

class localizacao extends ChangeNotifier {
  List <Marker> _bage = [];
  List <Marker> get bage => _bage;
  WebSocketChannel channel = WebSocketChannel.connect(Uri.parse('ws://10.10.200.189:9000'));

  localizacao(){}

  void connect() {
    try {
      channel?.stream.listen((data) => onData(data),
        onDone: () async {
          channel?.sink.close();
          print("~~~ onDone ~~~");
        },
      );
    } catch (e) {
      print("Não foi possível conectar!");
    }
  }

  onData(data) {
    final localizacoes = jsonDecode(data);

    try {
      bage.clear();
      for (int i = 0; i < localizacoes!.length; i++) {
        bage.add(Marcador.getMarcador(
            latitude: localizacoes[i]['latitude'],
            longitude: localizacoes[i]['longitude'],
            texto: " ",
            cor: Colors.red,
            icone: Icons.directions_bus));
      }
    } catch (e) {}

    print(data);

    print("***********");
    notifyListeners();
  }

  onSend(msg){
    channel?.sink.add(msg);
  }
}