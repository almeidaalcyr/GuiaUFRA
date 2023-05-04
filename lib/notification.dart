import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:geodesy/geodesy.dart' as geo;
import 'secreto.dart';

class LocalizacaoBage extends ChangeNotifier {
  String serverUrl = "ws://${Secreto.enderecoServidor}:${Secreto.portaServidor}";
  late WebSocketChannel channel;

  String _mensagem = "x";
  String get mensagem => _mensagem;
  final List <Marker> _bage = [Marker(
    rotate: true,
    width: 300,
    height: 80,
    point: geo.LatLng(0,0),
    builder: (ctx) => const Icon(
      Icons.bus_alert,
      color: Colors.green,
      size: 15,
    ),
  )
  ];

  List <Marker> get bage => _bage;

  LocalizacaoBage(){
    print("Localizacao Bage");
    print(serverUrl);
    channel = WebSocketChannel.connect(Uri.parse(serverUrl));
    try {
      channel.stream.listen(
            (data) => onData(data),
        onDone: () => onDone(),
      );
    } catch (e) {/**/}
  }

  onData(data) async {
    print(data);
    final dataJson = jsonDecode(data);
    try{
      _bage.clear();
      for (int i = 0; i < dataJson.length; i++){
        _bage.add(Marker(
          rotate: true,
          width: 300,
          height: 80,
          point: geo.LatLng(dataJson[i]["latitude"],dataJson[i]["longitude"]),
          builder: (ctx) => const Icon(
            Icons.directions_bus,
            color: Colors.red,
            size: 25,
          ),
        )
        );
      }
    } catch (e) {/**/}

    _mensagem = data;
    notifyListeners();

    // Envia nova solictação
    await Future.delayed(const Duration(seconds: 1));
    onSend("x");
  }

  onDone(){}

  onSend(msg){
    print("onSend");
    try {
      channel.sink.add(msg);
    } catch (e){/**/}
  }
}