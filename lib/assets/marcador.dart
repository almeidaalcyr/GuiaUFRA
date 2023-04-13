import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geodesy/geodesy.dart' as geo;

class Marcador {
  static Marker getMarcador(
      {
        required double latitude,
        required double longitude,
        required String texto,
        required Color cor,
        required IconData icone,
      }
      )
  {
    return Marker(
      rotate: true,
      width: 300,
      height: 80,
      point: geo.LatLng(latitude,longitude),
      builder: (ctx) => Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                " ",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15),
              ),
              Icon(
                icone,
                color: cor,
                size: 15,
              ),
              Text(
                texto,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15),
              ),
            ],
          )
      ),
    );
  }
}