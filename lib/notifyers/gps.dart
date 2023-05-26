import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geodesy/geodesy.dart' as geo;

class Gps extends ChangeNotifier {
  bool googleServices = false;
  Marker _marcador = Marker(point: geo.LatLng(0,0), builder: (ctx) =>
      Container(child: Wrap()));
  Marker get marcador => _marcador;

  double _latitude = 0;
  double get latitude => _latitude;
  double _longitude = 0;
  double get longitude => _longitude;

  Gps(){
    StreamSubscription<Position> positionStream = Geolocator
        .getPositionStream(forceAndroidLocationManager: googleServices)
        .distinct()
        .listen((Position position) {
      _latitude = position.latitude;
      _longitude = position.longitude;

      atualizaMarcador();
      notifyListeners();
    });
  }

  atualizaMarcador(){
    _marcador = Marker( //Cria o marcador com a localização do celular
        rotate: true,
        width: 80,
        height: 80,
        point: geo.LatLng(_latitude, _longitude),
        builder: (ctx) =>
            Container(
              child: const Icon(
                Icons.circle,
                color: Colors.blue,
                size: 20,),
            )
    );
  }
}