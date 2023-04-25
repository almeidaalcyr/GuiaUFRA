import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';

import 'assets/marcador.dart';

class Celular {
  late LocationPermission permissaoConcedida;
  bool googleServices = true;// Usar google services para melhorar a precisão?
  late Marker marcador;
  int _intervaloAtualizacao = 1;
  int get intervaloAtualizacao => _intervaloAtualizacao;

  atualizaCoordenadas(){
    try {
      if (permissaoConcedida == LocationPermission.always) {
        Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low, forceAndroidLocationManager: googleServices, timeLimit: Duration (seconds: 60))
            .then((event) {
          marcador = Marcador.getMarcador(
            latitude: event.latitude,
            longitude: event.longitude,
            texto: "",
            cor: Colors.blue,
            icone: Icons.circle,
          );
        });
      }
    }
    catch (e) {}
  }

  verificaGpsAtivoGeolocator() async {
    var servicoAbilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicoAbilitado){
      return Future.error('Location services are disabled.');
    }

    permissaoConcedida = await Geolocator.checkPermission();
    if (permissaoConcedida == LocationPermission.denied) {
      permissaoConcedida = await Geolocator.requestPermission();
      if (permissaoConcedida == LocationPermission.denied){
        return Future.error('Location permissions are denied');
      }
    }

    if (permissaoConcedida == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }
  }
}