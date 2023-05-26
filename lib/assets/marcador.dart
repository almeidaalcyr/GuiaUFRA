import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geodesy/geodesy.dart' as geo;
import 'dart:math' as math;

class Marcador {
  static Marker getMarcador(
      {
        required double latitude,
        required double longitude,
        required String texto,
        required Color cor,
        required IconData icone,
        double angulo = 0,
        double tamanho = 20,
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
              Transform.rotate(
                  angle: angulo * math.pi / 180,
                  child: Icon(
                    icone,
                    color: cor,
                    size: tamanho,
                  )
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

  Marcador marcador = Marcador();
}