import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:geodesy/geodesy.dart' as geo;
import 'package:guiaufra/selecionaMapa.dart';
import 'package:guiaufra/assets/marcador.dart';

import '../celular.dart';

class TelaMapa extends StatefulWidget {
  const TelaMapa({super.key});

  @override
  _TelaMapaState createState() => _TelaMapaState();
}

class _TelaMapaState extends State<TelaMapa> {
  Celular celular = Celular();
  Mapa mapa = Mapa("");

//  _TelaMapaState() {}

  @override
  void initState() {
    super.initState();
    celular.verificaGpsAtivoGeolocator();

    Timer.run(() {
      Timer.periodic(
          Duration(seconds: celular.intervaloAtualizacao), (Timer t) => celular.atualizaCoordenadas); //Auto update
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Guia UFRA - Campus Belém"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.headphones),
            tooltip: "nada",
            onPressed: () {},
          )
        ],
      ),

      body: Stack(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: double.infinity,
              child: FlutterMap(
                options: MapOptions(
                  zoom: 14.0,
                  minZoom: 12.0,
                  maxZoom: 18.0,

                  //Limites do campus Belém
                  nePanBoundary: geo.LatLng(-1.451167, -48.431376),
                  swPanBoundary: geo.LatLng(-1.464912, -48.446199),
                  slideOnBoundaries: true,

                  center: geo.LatLng(-1.4561754180442585,
                      -48.43970775604249), //(-1.458039, -48.438787),
                ),
                layers: [
                  mapa.mapaSelecionado,
                  MarkerLayerOptions(
                    markers: [
                      //celular.marcador,
                      Marcador().marcador.teste(),
                    ],
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: mapa.mapaProvedor,
            ),
          ]
      ),

      floatingActionButton: FloatingActionButton.extended(
        label: const Text("Pontos de interesse"),
        icon: const Icon(Icons.search,),
        onPressed: () {},
        tooltip: 'Busca',
      ),
    );
  }
}