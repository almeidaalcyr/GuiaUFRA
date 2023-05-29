import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Evento {
  final inputFormato = DateFormat('yyyy-MM-dd');
  final outputFormato = DateFormat('dd MM yyyy');

  static List <Evento> eventos = [];

  final String id;
  final String evento;
  late bool passado;
  late bool presente;
  late bool futuro;

  DateTime? dataInicio;
  DateTime? dataFim;
  bool intervaloDeDatas = false;

  List <DateTime> listaDatas = [];

  static List <String> eventosString = [];
  //TODO: descobrir uma forma de não precisar de eventosString.add(evento);
  Evento({
    required this.id,
    required this.evento,
    List <dynamic>? intervalo,
    List <dynamic>? datas,
  }){
    eventosString.add(evento);
    print(evento);

    if (datas != null){
      dataInicio = inputFormato.parse(datas[0]);
      dataFim = inputFormato.parse(datas[datas.length - 1]);

      for (int i = 0; i < datas.length; i++){
        listaDatas.add(inputFormato.parse(datas[i]));
      }

    } else if (intervalo != null){
      dataInicio = inputFormato.parse(intervalo[0]);
      dataFim = inputFormato.parse(intervalo[1]);

      intervaloDeDatas = true;
      DateTime temp = dataInicio!;
      while (!temp.isAfter(dataFim!)){
        listaDatas.add(temp);
        temp = temp.add(const Duration(days: 1));
      }
      /*for (int i = 0; i < intervalo!.length; i++){
        listaDatas.add(inputFormato.parse(intervalo![i]));
      }*/
    }

    DateTime hoje = inputFormato.parse(DateTime.now().toString());
    passado = (dataInicio!.isBefore(hoje) && dataFim!.isBefore(hoje));
    presente = dataInicio!.isBefore(hoje) && dataFim!.isAfter(hoje) || dataInicio!.isAtSameMomentAs(hoje) || dataFim!.isAtSameMomentAs(hoje);
    futuro = dataInicio!.isAfter(hoje) && dataFim!.isAfter(hoje);
  }
}