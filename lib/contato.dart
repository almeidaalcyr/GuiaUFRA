import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import 'assets/marcador.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Contato {
  static List <Contato> contato = [];

  static String formataCelular(String telefone){
    return telefone.replaceAllMapped(RegExp(r'(\d{2})(\d{4})(\d+)'), (Match m) => "(${m[1]}) ${m[2]}-${m[3]}");
  }

  static void alteraExibirNoMapa(int indice, {bool? valor}) async{
    Contato.contato[indice].exibirNoMapa = valor ?? !Contato.contato[indice].exibirNoMapa;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? exibirPOI = prefs.getStringList("exibirPOI");

    if (exibirPOI?[indice] == "0"){
    exibirPOI?[indice] = "1";
    } else {
      exibirPOI?[indice] = "0";
    }

    await prefs.setStringList("exibirPOI", exibirPOI!);
  }

  final String id;
  final String nome;
  final String? sigla;
  final IconData icone;
  final Color cor;
  final List <dynamic>? telefone;
  final List <dynamic>? email;
  final List <dynamic>? site;
  final List <dynamic>? coordenadas;
  final String? whatsapp;
  final String? instagram;
  final String? facebook;
  final String? youtube;
  final String? twitter;
  final String? telegram;

  List <Marker> marcadores = [];
  bool exibirNoMapa = false;

  static List <String> nomeSigla = [];

  bool possuiContato = false;
  bool possuiRedeSocial = false;
  bool possuiCoordenada = false;

  Contato({
    required this.id,
    required this.nome,
    this.sigla,
    required this.icone,
    required this.cor,
    this.telefone,
    this.email,
    this.site,
    this.coordenadas,
    this.whatsapp,
    this.instagram,
    this.facebook,
    this.youtube,
    this.twitter,
    this.telegram,
  }){
    if (sigla != null) {
      nomeSigla.add("$nome $sigla");
    }
    else {
      nomeSigla.add(nome);
    }

    if (
    whatsapp != null ||
    instagram != null ||
    facebook != null ||
    youtube != null ||
    twitter != null ||
    telegram != null) {
      possuiContato = true;
      possuiRedeSocial = true;
    } else if (
    telefone != null ||
    email != null ||
    site != null) {
      possuiContato = true;
    }

    if (coordenadas != null){
      possuiCoordenada = true;
      for (int i = 0; i < coordenadas!.length; i++){
        Marker marcador = Marcador.getMarcador(
            latitude: coordenadas![i]['latitude'],
            longitude: coordenadas![i]['longitude'],
            texto: sigla ?? nome,
            cor: cor,
            icone: icone
        );

        marcadores.add(marcador);
      }
    }
  }

  static IconData getIcone(String icone) {
    switch (icone) {
      case 'a':
        return Icons.shopping_bag;
      case 'a':
        return Icons.bus_alert;
      case 'a':
        return Icons.science;
      case 'a':
        return Icons.add_business;
      case 'a':
        return Icons.attach_money_rounded;
      case 'a':
        return Icons.auto_stories_outlined;
      case 'a':
        return Icons.airport_shuttle_outlined;
      case 'a':
        return Icons.alternate_email_sharp;
      case 'a':
        return Icons.bolt;
      case 'a':
        return Icons.call;
      case 'a':
        return Icons.coffee;
      case 'a':
        return Icons.date_range;
      case 'a':
        return Icons.dining;
      case 'a':
        return Icons.directions_boat;
      case 'onibus':
        return Icons.directions_bus;
      case 'a':
        return Icons.e_mobiledata;
      case 'a':
        return Icons.explicit;
      case 'a':
        return Icons.flash_on;
      case 'a':
        return Icons.flatware;
      case 'a':
        return Icons.fmd_good;
      case 'a':
        return Icons.liquor_outlined;
      case 'a':
        return Icons.local_atm;
      case 'a':
        return Icons.navigation;
      case 'a':
        return Icons.pool;
      case 'a':
        return Icons.restaurant;
      case 'a':
        return Icons.sensors;
      case 'a':
        return Icons.store;
      case 'a':
        return Icons.wc;
      case 'a':
        return Icons.wheelchair_pickup;
      case 'wifi':
        return Icons.wifi_tethering;
      case 'a':
        return Icons.circle_sharp;
      case 'a':
        return Icons.local_parking;
      case 'a':
        return Icons.park;
      case 'a':
        return Icons.pets;
      case 'a':
        return Icons.local_hospital;
      case 'a':
        return Icons.restaurant;
      case 'escola':
        return Icons.school;
      default:
      //return Icons.link;
        return Icons.circle_sharp;
    }
  }

  static getCor(String cor) {
    switch (cor) {
      case 'azul':
        return Colors.blue;
      case 'verde':
        return Colors.green;
      case 'vermelho':
        return Colors.red;
      default:
        return Colors.black;
    }
  }
}