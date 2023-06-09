import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:geodesy/geodesy.dart' as geo;
import 'package:provider/provider.dart';
import '../providers/gps.dart';
import 'tela_lista.dart';
import 'package:geolocator/geolocator.dart';
import '../antigos/contato.dart';
import '../assets/mapa_offline.dart';
import '../providers/webSocket.dart';

class TelaMapa extends StatefulWidget {
  const TelaMapa({super.key});

  @override
  _TelaMapaState createState() => _TelaMapaState();
}

class _TelaMapaState extends State<TelaMapa> {
  @override
  void initState(){
    super.initState();
    Timer.run(() {
      carregaMarcadores();
      verificaGpsAtivoGeolocator();
    });
    Timer.periodic(Duration(seconds: intervaloAtualizacao), (Timer t) => setState(() { print("setState");}));
  }

  final int intervaloAtualizacao = 1;
  MapController mapController = MapController();
  //Atributos do mapa
  double currentZoom = 15.5;
  final double minZoom = 15.0;
  final double maxZoom = 18.0;
  final double intervaloZoom = 0.5;
  final geo.LatLng center = geo.LatLng(-1.458039, -48.438787);
  //Limites NE e SW do campus Belém
  final geo.LatLng nePanBoundary = geo.LatLng(-1.451167, -48.431376);
  final geo.LatLng swPanBoundary = geo.LatLng(-1.464912, -48.446199);
  //Marcadores
  List <Marker> marcadores = [];

  late LocationPermission permissaoConcedida;

  void _zoomIn() {
    if (currentZoom + intervaloZoom <= maxZoom) {
      currentZoom = currentZoom + intervaloZoom;
      mapController.move(mapController.center, currentZoom);
    }
  }
  void _zoomOut() {
    if (currentZoom - intervaloZoom >= minZoom) {
      currentZoom = currentZoom - intervaloZoom;
      mapController.move(mapController.center, currentZoom);
    }
  }
  void _norteReset(){
    mapController.rotate(0);
  }

  carregaMarcadores() {
    marcadores = [];
    for (int i = 0; i < Contato.contato.length; i++){
      if (Contato.contato[i].exibirNoMapa) {
        for (int j = 0; j < Contato.contato[i].marcadores.length; j++){
          marcadores.add(Contato.contato[i].marcadores[j]);
        }
      }
    }
    setState(() {});
  }

  verificaGpsAtivoGeolocator() async {
    var servicoHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicoHabilitado){
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

  @override
  Widget build(BuildContext context) {
    final webSocket = Provider.of<WebSocket>(context, listen: true);
    final gps = Provider.of<Gps>(context, listen: true);

    return Scaffold(
      /*appBar: AppBar(
          title: const Text("Guia UFRA - Campus Belém"),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.headphones),
              tooltip: "nada",
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('This is a snackbar'))
                );
              },
            ),
          ],
        ),*/

      body: Stack(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: double.infinity,
              child: Listener( // zoom no centro da tela. não funciona no celular
                onPointerSignal: (pointerSignal) {
                  if (pointerSignal is PointerScrollEvent){
                    if (pointerSignal.scrollDelta.dy < 0) {
                      mapController.move(mapController.center, mapController.zoom+1);
                    } else {
                      mapController.move(mapController.center, mapController.zoom-1);
                    }
                  }
                },
                child: FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    center: center,
                    zoom: currentZoom,
                    minZoom: minZoom,
                    maxZoom: maxZoom,
                    nePanBoundary: nePanBoundary,
                    swPanBoundary: swPanBoundary,
                    slideOnBoundaries: true,
                  ),
                  layers: [
                    TileLayerOptions(
                        urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: ['a', 'b', 'c'],
                        tileProvider: const CachedTileProvider()
                    ),
                    MarkerLayerOptions(
                      markers: [
                        gps.marcador,
                        ...webSocket.bage,
                        ...marcadores,
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Container(
                child: Column(
                  children: [
                    const SizedBox(height: 50,),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(40,40),
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white,
                      ),
                      child: const Icon(Icons.zoom_in_map, size: 15),
                      onPressed: () => _zoomIn(),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(40,40),
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white,
                      ),
                      child: const Icon(Icons.zoom_out_map, size: 15),
                      onPressed: () => _zoomOut(),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(40,40),
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white,
                      ),
                      child: const Icon(CupertinoIcons.location_north_line_fill, size: 15),
                      onPressed: () => _norteReset(),
                    ),
                  ],
                ),
              ),
            ),

            //CardSwitchContato(2, "widget.textoBusca[indice]"),
            Align(
              alignment: Alignment.bottomLeft,
              child: Text(webSocket.alerta,
                style: TextStyle(color: Colors.red, fontSize: 20, backgroundColor: Colors.white),),
            ),

            const Align(
              alignment: Alignment.bottomRight,
              child: Text("© OpenStreetMap contributors", ),
            ),
          ]
      ),

      floatingActionButton: FloatingActionButton(//.extended(
        onPressed: () {
          //webSocket.onSend("x");
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
        tooltip: 'Busca',//.extended(
        child: const Icon(Icons.search,),
      ),
    );
  }
  /*);
  }*/

  @override
  void dispose() {
    super.dispose();
  }

  @mustCallSuper
  @override
  void didUpdateWidget(TelaMapa telaMapa) {
// TODO: implement didUpdateWidget
    super.didUpdateWidget(telaMapa);
  }
}
