import 'package:flutter/cupertino.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MyAppState extends ChangeNotifier {
  WebSocketChannel? channel;
  bool webSocketConnected = false;
  int webSocketReconnectAttempts = 0;

  MyAppState() {
    connect();
  }

  void onMessage(message) {
    webSocketConnected = true;
    webSocketReconnectAttempts = 0;
    notifyListeners();
  }

  void onDone() async {
    var delay = 1 + 1 * webSocketReconnectAttempts;
    if (delay > 10) {
      delay = 10;
    }
    print(
        "Done, reconnecting in $delay seconds, attempt $webSocketReconnectAttempts ");
    webSocketConnected = false;
    channel = null;
    await Future.delayed(Duration(seconds: delay));
    connect();
  }

  void onError(error) {
    print(error);
    if (error is WebSocketChannelException) {
      webSocketReconnectAttempts += 1;
    }
  }

  void connect() {
    try {
      channel = WebSocketChannel.connect(
        Uri.parse('ws://10.10.200.189:9000'),
      );
      channel!.stream.listen(onMessage, onDone: onDone, onError: onError);
    } catch (e) {
      print(e);
    }
  }
}