import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProviderClasse with ChangeNotifier, DiagnosticableTreeMixin {
  //List <dynamic> _contato = [];
  List <dynamic> _calendario = [];
  List <bool> _exibirPOI = [];

  //List <dynamic> get contato => _contato;
  List <dynamic> get calendario => _calendario;
  List <bool> get exibirPOI => _exibirPOI;

  //void setContato(List <dynamic> valor){ _contato = valor; }
  void setCalendario(List <dynamic> valor){ _calendario = valor; }
  void setExibirPOI(List <bool> valor){ _exibirPOI = valor; }
  Future<void> alterarExibirPOI(int indice) async {
    _exibirPOI[indice] = !_exibirPOI[indice];
    print("EXIBIR POI ALTERADO");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List <String> temp = [];
    for (int i = 0; i< _exibirPOI.length; i++){
      if (_exibirPOI[i]){
        temp.add("1");
      }
      else {
        temp.add("0");
      }
    }
    prefs.setStringList("exibirPOI", temp);
  }

  /*getNomeSigla(){
    List <String> temp = [];
    for (int i = 0; i < contato.length; i++){
      contato[i]['sigla'] != null
      ? temp.add("${contato[i]['nome']} ${contato[i]['sigla']}")
      : temp.add("${contato[i]['nome']}");
    }
    //print(contato);
    return temp;
  }*/

  getEvento(){
    List <String> temp = [];
    for (int i = 0; i < calendario.length; i++){
      temp.add(calendario[i]["evento"]);
    }
    return temp;
  }






  //int _count = 0;
  //int get count => _count;
  
  /*void increment() {
    _count++;
    notifyListeners();
  }*/

  /// Makes `Counter` readable inside the devtools by listing all of its properties
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    //properties.add(IntProperty('count', count));
  }
}