import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:geodesy/geodesy.dart' as geo;
import 'package:geodesy/geodesy.dart';
import 'package:provider/provider.dart';
import 'tela_lista.dart';
import 'package:geolocator/geolocator.dart';
import '../contato.dart';
import '../assets/marcador.dart';
import '../assets/mapa_offline.dart';
import '../notification.dart';

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
    Timer.periodic(Duration(seconds: intervaloAtualizacao), (Timer t) => setState(() {}));
  }

  final int intervaloAtualizacao = 1;
  bool googleServices = true;// Usar google services para melhorar a precisão?
  MapController mapController = MapController();
  //Atributos do mapa
  double currentZoom = 15.5;
  final double minZoom = 15.0;
  final double maxZoom = 18.0;
  final double intervaloZoom = 0.5;
  final LatLng center = geo.LatLng(-1.458039, -48.438787);
  //Limites NE e SW do campus Belém
  final LatLng nePanBoundary = geo.LatLng(-1.451167, -48.431376);
  final LatLng swPanBoundary = geo.LatLng(-1.464912, -48.446199);
  //Marcadores
  Marker celular = Marcador.getMarcador(latitude: 0, longitude: 0, texto: " ", cor: Colors.blue, icone: Icons.circle);
  List <Marker> bage = [Marcador.getMarcador(latitude: 0, longitude: 0, texto: " ", cor: Colors.blue, icone: Icons.directions_bus)];
  List <Marker> marcadores = [];

  late LocationPermission permissaoConcedida;

  void _zoomIn() {
    if (currentZoom + intervaloZoom <= maxZoom) {
      currentZoom = currentZoom + intervaloZoom;
      mapController.move(mapController.center, currentZoom + intervaloZoom);
    }
  }
  void _zoomOut() {
    if (currentZoom - intervaloZoom >= minZoom) {
      currentZoom = currentZoom - intervaloZoom;
      mapController.move(mapController.center, currentZoom - intervaloZoom);
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
    // Atualiza as coordenadas locais em tempo real.
    StreamSubscription<Position> positionStream = Geolocator
        .getPositionStream(forceAndroidLocationManager: !googleServices)
        .distinct()
        .listen((Position position) {
      celular = Marker( //Cria o marcador com a localização do celular
          rotate: true,
          width: 80,
          height: 80,
          point: geo.LatLng(position.latitude, position.longitude),
          builder: (ctx) =>
              Container(
                child: const Icon(
                  Icons.circle,
                  color: Colors.blue,
                  size: 20,),
              )
      );
      setState(() {

      });
    });

    //return Consumer<localizacao>(builder: (ctx, channel, _) {
    return Consumer<LocalizacaoBage>(builder: (ctx, ws, _) {
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
                        celular,
                        ...ws.bage,
                        ...marcadores,
                      ],
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Column(
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.white),
                        foregroundColor: MaterialStateProperty.all(Colors.black),
                        overlayColor:  MaterialStateProperty.all(Colors.grey),
                      ),
                      child: const Icon(Icons.zoom_in),
                      onPressed: () => _zoomIn(),
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.white),
                        foregroundColor: MaterialStateProperty.all(Colors.black),
                        overlayColor:  MaterialStateProperty.all(Colors.grey),
                      ),
                      child: const Icon(Icons.zoom_out),
                      onPressed: () => _zoomOut(),
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.white),
                        foregroundColor: MaterialStateProperty.all(Colors.black),
                        overlayColor:  MaterialStateProperty.all(Colors.grey),
                      ),
                      child: const Icon(CupertinoIcons.location_north_line_fill),
                      onPressed: () => _norteReset(),
                    ),
                  ],
                ),
              ),
              const Align(
                alignment: Alignment.bottomRight,
                child: Text("© OpenStreetMap contributors"),
              ),
            ]
        ),

        floatingActionButton: FloatingActionButton.extended(
          label: const Text("Pontos de interesse"),
          icon: const Icon(Icons.search,),
          onPressed: () {
            ws.onSend("x");
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
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
