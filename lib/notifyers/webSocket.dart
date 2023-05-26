import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../secreto.dart';
import '../assets/marcador.dart';

/*
  TODO: Monitorar a conexão do usuário. Notificar se estiver offline. tentar reconectar caso a conexao volte
*/

class WebSocket extends ChangeNotifier {
  final List <Marker> _bage = [];
  List <Marker> get bage => _bage;

  String serverUrl = Secreto.enderecoServidor;
  late WebSocketChannel channel;

  final int limiteSemDados = 20; // Limite de tempo que o usuario pode ficar sem receber dados do servidor
  String _alerta = "";
  String get alerta => _alerta;

  double ultimaMensagemRecebida = 0;

  WebSocket(){
    connect();
  }

  double tempoAtual() => DateTime.now().millisecondsSinceEpoch / 1000;

  connect() {
    print("onConnect");
    channel = WebSocketChannel.connect(Uri.parse(serverUrl), );
    try {
      channel.stream.listen(
            (data) => onData(data),
        onDone: () => onDone(),

      );
    } catch (e) {/**/}

    Timer.periodic(const Duration(seconds: 1), (timer) => onSend("x"));
  }

  onData(data) {
    print("onData");
    print(data);
    ultimaMensagemRecebida = tempoAtual();
    final dataJson = jsonDecode(data);
    try{
      _bage.clear();
      _alerta = "Não há Bagé rodando no momento!";
      for (int i = 0; i < dataJson.length; i++){
        int tempoDispositivo = dataJson[i]["timeStamp"];
        int atraso = (ultimaMensagemRecebida - tempoDispositivo).toInt();
        //if (dataJson[i]["ativo"]) {
        _alerta = "";
        _bage.add(Marcador.getMarcador(
            latitude: dataJson[i]["latitude"],
            longitude: dataJson[i]["longitude"],
            texto: "${dataJson[i]["rota"]} ${atraso.toString()}s",
            cor: Colors.red,
            icone: Icons.navigation_rounded,
            angulo: dataJson[i]["rumo"],
            tamanho: 25
        )
        );
        //}
      }
    } catch (e) {/**/}

    notifyListeners();
  }

  onDone(){
    _alerta = "Erro";
    print("onDone");
  }

  onSend(msg) async {
    try {
      channel.sink.add(msg);
      print("onSend");
    } catch (e){/**/}

    double tempo = tempoAtual();

    // Verifica o tempo desde a última mensagem. Se for maior que "limiteSemDados", tira o marcador do mapa
    if (ultimaMensagemRecebida + limiteSemDados < tempo){
      _bage.clear();
      notifyListeners();
    }
  }
}