/* Só funciona no google chrome, e no debug */

/*import 'package:flutter/cupertino.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class InternetMonitor extends ChangeNotifier {
  String _conexao = "";
  String get conexao => _conexao;

  bool _conectado = false;
  bool get conectado => _conectado;

  String internetStatus = "";
  String tmpInternetStatus = "";

  InternetMonitor(){
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {

    });
    verificaInternet();
  }

  verificaInternet() async{
      final connectivityResult = await (Connectivity().checkConnectivity());
      tmpInternetStatus = internetStatus;
      _conectado = true;

      if (connectivityResult == ConnectivityResult.mobile) {
        _conexao = "MOBILE";
      } else if (connectivityResult == ConnectivityResult.wifi) {
        _conexao = "WIFI";
      } else if (connectivityResult == ConnectivityResult.ethernet) {
        _conexao = "ETHERNET";
      } else if (connectivityResult == ConnectivityResult.vpn) {
        _conexao = "VPN";
        // Note for iOS and macOS:
        // There is no separate network interface type for [vpn].
        // It returns [other] on any device (also simulator)
      } else if (connectivityResult == ConnectivityResult.bluetooth) {
        _conexao = "BLUETOOTH";
      } else if (connectivityResult == ConnectivityResult.other) {
        _conexao = "OUTROS";
      } else if (connectivityResult == ConnectivityResult.none) {
        _conexao = "OFFLINE";
        _conectado = false;
      } else {
        _conexao = "ERRO";
        _conectado = false;
      }
      // Got a new connectivity status
      notifyListeners();
    }
}
 */