import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:geodesy/geodesy.dart' as geo;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'tela_lista.dart';
import 'package:geolocator/geolocator.dart';
import '../contato.dart';
import '../assets/marcador.dart';
import '../assets/mapa_offline.dart';

class TelaMapa extends StatefulWidget {
  @override
  _TelaMapaState createState() => _TelaMapaState();
}

class _TelaMapaState extends State<TelaMapa> {
  static const int intervalo_Atualizacao_Dispositivo = 1; //Tempo de atualização das coordenadas do dispositivo
  static String enderecoAPITraccar = 'ws://10.10.200.189:9000';
  bool googleServices = true; // Usar google services para melhorar a precisão?

  final TextEditingController _controller = TextEditingController();
  final _channel = WebSocketChannel.connect(
    Uri.parse(enderecoAPITraccar),
  );

  @override
  void initState(){
    super.initState();
    Timer.run(() {
      carregaMarcadores();
      verificaGpsAtivoGeolocator();
      atualizaCoordenadas();
    });
    Timer.periodic(Duration(seconds: intervalo_Atualizacao_Dispositivo), (Timer t) => atualizaCoordenadas()); //Auto update
  }

  //mapas
  static const String OSM = "OSM";
  static const String LANDSCAPE = "LANDSCAPE";
  static const String NEIGHBOURHOOD = "NEIGHBOURHOOD";
  String mapaSelecionado = "OFFLINE";
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
  atualizaCoordenadas(){
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
      }
    }
    catch (e) {}
    _channel.sink.add("x");
    setState(() {});
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
        /*actions: <Widget> [
          IconButton(
            icon: const Icon(Icons.headphones),
            tooltip: "nada",
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('This is a snackbar'))
              );
            },
          )
        ],*/
      ),

      body: Stack(
          children: <Widget> [
            Container(
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
                      ...bage,
                      ...marcadores,
                    ],
                  ),
                ],
              ),
            ),
            StreamBuilder(
              stream: _channel.stream,
              builder: (context, snapshot) {
                print("STREAM BUILDER");
                if (snapshot.hasData) {
                  final j = jsonDecode(snapshot.data);
                  try {
                    //setState(() {
                      bage.clear();
                      for (int i = 0; i < j!.length; i++) {
                        print(i);
                        bage.add(Marcador.getMarcador(
                            latitude: j[i]['latitude'],
                            longitude: j[i]['longitude'],
                            texto: " ",
                            cor: Colors.red,
                            icone: Icons.directions_bus));
                      }
                      print(snapshot.data);

                  } catch (e) {
                    print("CATCH - STREAMBUILDER");
                  }
                }
                return Wrap(); //Text(snapshot.hasData ? 'CONECTOU' : 'ERRO');//Text(j[0]);//;${"a"}
              },
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
      ), //floatingActionButton
    );
  }
}
