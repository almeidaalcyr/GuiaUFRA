import 'dart:async';
import 'dart:convert';
//import 'dart:html';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/plugin_api.dart';
import 'package:geodesy/geodesy.dart' as geo;
import 'tela_lista.dart';
import 'package:location/location.dart' hide LocationAccuracy;
import 'package:http/http.dart' as http;
//import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:geolocator/geolocator.dart';

import 'package:provider/src/provider.dart';
import '../assets/provider.dart';
import '../contato.dart';
import '../assets/marcador.dart';

//import 'package:geolocator_platform_interface/src/enums/location_accuracy.dart' as geoL;

class TelaMapa extends StatefulWidget {

  @override
  _TelaMapaState createState() => _TelaMapaState();
}

class _TelaMapaState extends State<TelaMapa> {
  static const int intervalo_Atualizacao_Dispositivo = 5; //Tempo de atualização das coordenadas do dispositivo
  bool googleServices = false; // Usar google services para melhorar a precisão?

  List <Marker> marcadores = []; //Precisa ser uma lista. Por causa do popup.

  @override
  void initState(){
    super.initState();
    Timer.run(() {
      carregaMarcadores();
      verificaGpsAtivoGeolocator();
      atualizaCoordenadaLocal();
    });
    Timer.periodic(Duration(seconds: intervalo_Atualizacao_Dispositivo), (Timer t) => atualizaCoordenadaLocal()); //Auto update

  }

  //mapas
  static const String OSM = "OSM";
  static const String MAPBOX = "MAPBOX";
  static const String LANDSCAPE = "LANDSCAPE";
  static const String NEIGHBOURHOOD = "NEIGHBOURHOOD";
  String mapaSelecionado = "padrão";
  late TileLayerOptions mapa;
  setMapa(String m){
    switch(m){
      case OSM:
        mapa = TileLayerOptions(
          fastReplace: true,
          //TODO: é necessário inserir a APIKEY
          urlTemplate: "https://api.mapbox.com/styles/v1/almeidaalcyr/ckq4moty32hjg17oxu6t5f3au/tiles/256/{z}/{x}/{y}@2x?access_token=",
          additionalOptions: {
            //TODO: é necessário inserir a APIKEY
            'accessToken': "",
          },
        );
        break;
      case LANDSCAPE:
        mapa = TileLayerOptions(
          //TODO: é necessário inserir a APIKEY
          urlTemplate: "https://tile.thunderforest.com/landscape/{z}/{x}/{y}.png?apikey=",
        );
        break;
      case NEIGHBOURHOOD:
        mapa = TileLayerOptions(
          //TODO: é necessário inserir a APIKEY
          urlTemplate: "https://tile.thunderforest.com/neighbourhood/{z}/{x}/{y}.png?apikey=",
        );
        break;
      default:
        mapa = TileLayerOptions(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c']
        );
        break;
    }
  }

  carregaMarcadores() {
    marcadores = [];
    for (int i = 0; i < Contato.contato.length; i++){
      if (Contato.contato[i].exibirNoMapa) {
        for (int j = 0; j < Contato.contato[i].marcadores.length; j++){
          marcadores.add(Contato.contato[i].marcadores[j]);
          print("*");
        }
      }
    }
    setState(() {});
  }

  Marker celular = Marcador.getMarcador(latitude: 0, longitude: 0, texto: " ", cor: Colors.blue, icone: Icons.circle);
  /*Marker( //Cria o marcador com a localização do celular
    rotate: true,
    width: 80,
    height: 80,
    point: geo.LatLng(0, 0),
    builder: (ctx) =>Container(
    ),
  );*/
  late LocationPermission permissaoConcedida;
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

  /* GEOLOCATOR */
  atualizaCoordenadaLocal(){
    try {
      if (permissaoConcedida == LocationPermission.always) {
        setState((){
          Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low, forceAndroidLocationManager: !googleServices, /*timeLimit: Duration (seconds: 10)*/)
              .then((event) {
            celular = Marcador.getMarcador(
                latitude: event.latitude,
                longitude: event.longitude,
                texto: "",
                cor: Colors.blue,
                icone: Icons.circle,
            );
          });
        });
      }
    }
    catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    /* Atualiza as coordenadas locais em tempo real.
       Pelo initState está configurado para atualizar a cada 5 segundos */
    /*StreamSubscription<Position> positionStream = Geolocator.getPositionStream(forceAndroidLocationManager: !googleServices).distinct().listen((Position position){
      print("**");
      double lat = position.latitude;
      double lng = position.longitude;
      print("$lat $lng");
      setState(() {
        celular = Marker( //Cria o marcador com a localização do celular
          rotate: true,
          width: 80,
          height: 80,
          point: geo.LatLng(lat, lng),
          builder: (ctx) =>Container(
            child: Icon(Icons.circle_outlined,),
          )
        );
      });
    });*/
    setMapa(mapaSelecionado);

    return Scaffold(
      appBar: AppBar(
        title: Text("Guia UFRA - Campus Belém"),
        actions: <Widget> [
          IconButton(
            icon: const Icon(Icons.headphones),
            tooltip: "nada",
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('This is a snackbar'))
              );
            },
          )
        ],
      ),

      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: FlutterMap(
          options: MapOptions(
            zoom: 14.0,
            minZoom: 15.5,
            maxZoom: 18.0,

            //Limites do campus Belém
            nePanBoundary: geo.LatLng(-1.451167, -48.431376),
            swPanBoundary: geo.LatLng(-1.464912, -48.446199),
            slideOnBoundaries: false,

            center: new geo.LatLng(-1.458039, -48.438787),
          ),
          layers: [
            mapa,
            MarkerLayerOptions(

              markers: [
                celular,
                ...marcadores,
              ],
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        label: Text("Pontos de interesse"),
        icon: Icon(Icons.search,),
        onPressed: () {
          Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_){
                    return TelaLista(Busca.localizacao);
                  }
              )

          ).then((_){
              carregaMarcadores();
          });
        },
        tooltip: 'Busca',
      ),
    );
  }
}
