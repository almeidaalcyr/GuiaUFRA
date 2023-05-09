import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:geodesy/geodesy.dart' as geo;
import 'secreto.dart';
import 'assets/marcador.dart';

/*
  TODO: Monitorar a conexão do usuário. Notificar se estiver offline
*/

class LocalizacaoBage extends ChangeNotifier {
  final List <Marker> _bage = [];
  List <Marker> get bage => _bage;

  String serverUrl = Secreto.enderecoServidor;
  late WebSocketChannel channel;

  final int limiteSemAtualizacao = 300; // Limite de tempo que o rastreador pode ficar sem enviar a posicao
  final int limiteSemDados = 20; // Limite de tempo que o usuario pode ficar sem receber dados do servidor

  double ultimaMensagemRecebida = 0;

  LocalizacaoBage(){
    channel = WebSocketChannel.connect(Uri.parse(serverUrl));
    try {
      channel.stream.listen(
            (data) => onData(data),
        onDone: () => onDone(),
      );
    } catch (e) {/**/}

    Timer.periodic(const Duration(seconds: 1), (timer) => onSend("x"));
  }

  double tempoAtual() => DateTime.now().millisecondsSinceEpoch / 1000;

  onData(data) {
    print(data);
    ultimaMensagemRecebida = tempoAtual();
    final dataJson = jsonDecode(data);
    try{
      _bage.clear();
      for (int i = 0; i < dataJson.length; i++){
        int tempoDispositivo = dataJson[i]["timeStamp"];
        int atraso = (ultimaMensagemRecebida - tempoDispositivo).toInt();

        if (atraso < limiteSemAtualizacao) {
          _bage.add(Marcador.getMarcador(
              latitude: dataJson[i]["latitude"],
              longitude: dataJson[i]["longitude"],
              texto: "${atraso.toString()}s",
              cor: Colors.red,
              icone: Icons.navigation_rounded,//Icons.directions_bus,
              angulo: dataJson[i]["rumo"])
          );
        }
      }
    } catch (e) {/**/}

    notifyListeners();
  }

  onDone(){
    print("onDone");
  }

  onSend(msg) async {
    try {
      channel.sink.add(msg);
    } catch (e){/**/}

    double tempo = tempoAtual();

    // Verifica o tempo desde a última mensagem. Se for maior que "limiteSemDados", tira o marcador do mapa
    if (ultimaMensagemRecebida + limiteSemDados < tempo){
      _bage.clear();
      notifyListeners();
    }
  }
}