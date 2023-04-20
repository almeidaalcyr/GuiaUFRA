import 'dart:async';
import 'dart:io';

class NotificationController {

  static final NotificationController _singleton = new NotificationController._internal();

  StreamController<String> streamController = new StreamController.broadcast(sync: true);

  String wsUrl = 'ws://10.10.200.189:9000';

  late WebSocket channel;

  factory NotificationController() {
    return _singleton;
  }

  NotificationController._internal() {
    initWebSocketConnection();
  }

  initWebSocketConnection() async {
    print("conecting...");
    this.channel = await connectWs();
    print("socket connection initializied");
    this.channel.done.then((dynamic _) => _onDisconnected());
    broadcastNotifications();
  }

  broadcastNotifications() {
    this.channel.listen((streamData) {
      streamController.add(streamData);
    }, onDone: () {
      print("conecting aborted");
      initWebSocketConnection();
    }, onError: (e) {
      print('Server error: $e');
      initWebSocketConnection();
    });
  }

  connectWs() async{
    try {
      return await WebSocket.connect(wsUrl);
    } catch  (e) {
      print("Error! can not connect WS connectWs " + e.toString());
      await Future.delayed(Duration(milliseconds: 10000));
      return await connectWs();
    }

  }

  void _onDisconnected() {
    initWebSocketConnection();
  }
}