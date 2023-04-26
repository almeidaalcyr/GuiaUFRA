
import 'dart:async';
import 'dart:convert';
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
  @override
  _TelaMapaState createState() => _TelaMapaState();
}

class _TelaMapaState extends State<TelaMapa> {
  bool googleServices = true;// Usar google services para melhorar a precisão?
  MapController mapController = MapController();

  double currentZoom = 15.5;
  final double minZoom = 15.0;
  final double maxZoom = 18.0;
  final double deltaZoom = 0.5;
  final LatLng center = geo.LatLng(-1.458039, -48.438787);
  //Limites NE e SW do campus Belém
  final LatLng nePanBoundary = geo.LatLng(-1.451167, -48.431376);
  final LatLng swPanBoundary = geo.LatLng(-1.464912, -48.446199);
  //mapas
  static const String OSM = "OSM";
  static const String LANDSCAPE = "LANDSCAPE";
  static const String NEIGHBOURHOOD = "NEIGHBOURHOOD";
  String mapaSelecionado = "default";

  void _zoomIn() {
    if (currentZoom + deltaZoom <= maxZoom) {
      currentZoom = currentZoom + deltaZoom;
      mapController.move(mapController.center, currentZoom + deltaZoom);
    }
  }
  void _zoomOut() {
    if (currentZoom - deltaZoom >= minZoom) {
      currentZoom = currentZoom - deltaZoom;
      mapController.move(mapController.center, currentZoom - deltaZoom);
    }
  }

  @override
  void initState(){
    super.initState();
    Timer.run(() {
      carregaMarcadores();
      verificaGpsAtivoGeolocator();
      //atualizaCoordenadas();
    });
  }


  late TileLayerOptions mapa;
  String mapa_provedor = "";
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
        mapa_provedor = "© Mapbox";
        break;
      case LANDSCAPE:
        mapa = TileLayerOptions(
          //TODO: é necessário inserir a APIKEY
          urlTemplate: "https://tile.thunderforest.com/landscape/{z}/{x}/{y}.png?apikey=",
          tileProvider: const CachedTileProvider(),
        );
        mapa_provedor = "Mapas © Thunderforest Dados © OpenStreetMap contributors";
        break;
      case NEIGHBOURHOOD:
        mapa = TileLayerOptions(
          //TODO: é necessário inserir a APIKEY
          urlTemplate: "https://tile.thunderforest.com/neighbourhood/{z}/{x}/{y}.png?apikey=",
          tileProvider: const CachedTileProvider(),
        );
        mapa_provedor = "Mapas © Thunderforest Dados © OpenStreetMap contributors";
        break;
      default:
        mapa = TileLayerOptions(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: ['a', 'b', 'c'],
          tileProvider: const CachedTileProvider(),
        );
        mapa_provedor = "© OpenStreetMap contributors";
        break;
    }
  }

  List <Marker> marcadores = []; //Precisa ser uma lista. Por causa do popup.
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
  Marker celular = Marcador.getMarcador(latitude: 0, longitude: 0, texto: " ", cor: Colors.blue, icone: Icons.circle);
  List <Marker> bage = [Marcador.getMarcador(latitude: 0, longitude: 0, texto: " ", cor: Colors.blue, icone: Icons.directions_bus)];
  /*atualizaCoordenadas(){
    try {
      if (permissaoConcedida == LocationPermission.always) {
        Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low, forceAndroidLocationManager: googleServices, timeLimit: Duration (seconds: 60))
            .then((event) {
          celular = Marcador.getMarcador(
            latitude: event.latitude,
            longitude: event.longitude,
            texto: "",
            cor: Colors.blue,
            icone: Icons.circle,
          );
        });
        print("*");
      }
    }
    catch (e) {
    }

    setState(() {});
    try {
    } catch (e) {}
  }*/

  @override
  Widget build(BuildContext context) {
    // Atualiza as coordenadas locais em tempo real.
       /*Pelo initState está configurado para atualizar a cada 5 segundos */
    StreamSubscription<Position> positionStream = Geolocator.getPositionStream(forceAndroidLocationManager: !googleServices).distinct().listen((Position position){
      double lat = position.latitude;
      double lng = position.longitude;
//      print("$lat $lng");
      setState(() {
        celular = Marker( //Cria o marcador com a localização do celular
            rotate: true,
            width: 80,
            height: 80,
            point: geo.LatLng(lat, lng),
            builder: (ctx) =>Container(
              child: const Icon(Icons.circle_outlined,),
            )
        );
      });
    });
    setMapa(mapaSelecionado);

    return Consumer<localizacao>(builder: (ctx, channel, _) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Guia UFRA - Campus Belém"),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.headphones),
              tooltip: "nada",
              onPressed: () {
                //channel?.changeStream((p0) => null);

                /*ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('This is a snackbar'))
              );*/
              },
            )
          ],
        ),

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
                    mapa,
                    MarkerLayerOptions(
                      markers: [
                        celular,
                        //...bage,
                        ...marcadores,
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  ElevatedButton(
                    child: const Icon(Icons.zoom_in),
                    onPressed: () {
                      _zoomIn();
                    },
                  ),
                  ElevatedButton(
                    child: const Icon(Icons.zoom_out),
                    onPressed: () {
                      _zoomOut();
                    },
                  ),
                ],

              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(mapa_provedor),
              ),
            ]
        ),

        floatingActionButton: FloatingActionButton.extended(
          label: const Text("Pontos de interesse"),
          icon: const Icon(Icons.search,),
          onPressed: () {
            channel.onSend("x");
            /*Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_){
                      return TelaLista(Busca.localizacao);
                    }
                )
            ).then((_){
              carregaMarcadores();
            });*/
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

