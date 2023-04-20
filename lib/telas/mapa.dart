import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:geodesy/geodesy.dart' as geo;
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'tela_lista.dart';
import 'package:geolocator/geolocator.dart';
import '../contato.dart';
import '../assets/marcador.dart';
import '../assets/mapa_offline.dart';
import '../notification.dart';

class TelaMapa extends StatefulWidget {
  final WebSocketChannel channel = WebSocketChannel.connect(Uri.parse('ws://10.10.200.189:9000'));

  @override
  _TelaMapaState createState() => _TelaMapaState(channel: channel);
}

class _TelaMapaState extends State<TelaMapa> {
  final WebSocketChannel? channel;

  _TelaMapaState({this.channel}) {
    try {
      channel?.stream.listen((data) {
        final localizacoes = jsonDecode(data);
        try {
          bage.clear();
          for (int i = 0; i < localizacoes!.length; i++) {
            bage.add(Marcador.getMarcador(
                latitude: localizacoes[i]['latitude'],
                longitude: localizacoes[i]['longitude'],
                texto: " ",
                cor: Colors.red,
                icone: Icons.directions_bus));
          }

        } catch (e) {}
        setState(() {});

        print(data);

        print("***********");
      },
          onDone: () async {
            channel?.sink.close();
            print("~~~ onDone ~~~");
          },
          /*onError: () async {
            print("onError");
          }*/
      );
    } catch (e) {
      print("Não foi possível conectar!");
    }
  }

  static const int intervalo_Atualizacao_Dispositivo = 1; //Tempo de atualização das coordenadas do dispositivo

  bool googleServices = true;// Usar google services para melhorar a precisão?

  @override
  void initState(){
    super.initState();
    Timer.run(() {
      carregaMarcadores();
      verificaGpsAtivoGeolocator();
      atualizaCoordenadas();
    });
    Timer.periodic(Duration(seconds: intervalo_Atualizacao_Dispositivo), (Timer t) => atualizaCoordenadas()); //Auto update
    Timer.periodic(Duration(seconds: intervalo_Atualizacao_Dispositivo), (Timer t) {
      try {
        widget.channel.sink.add("x");
        print("enviado");
      } catch (e) { print("não enviou"); }
    }); //Auto update
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
    setState(() {});
    try {
      widget.channel.sink.add("x");
    } catch (e) {}
  }

  enviaMensagem(msg){
    widget.channel.sink.add(msg);
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
        title: const Text("Guia UFRA - Campus Belém"),
        actions: <Widget> [
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
          children: <Widget> [
            Container(
              width: double.infinity,
              height: double.infinity,
              child: FlutterMap(
                options: MapOptions(
                  zoom: 14.0,
                  minZoom: 12.0,
                  maxZoom: 18.0,

                  //Limites do campus Belém
                  nePanBoundary: geo.LatLng(-1.4561754180442585,-48.43970775604249),//(-1.451167, -48.431376),
                  swPanBoundary: geo.LatLng(-1.464912, -48.446199),
                  slideOnBoundaries: false,

                  center: new geo.LatLng(-1.4561754180442585,-48.43970775604249),//(-1.458039, -48.438787),
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
          widget.channel.sink.close();
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

  @override
  void dispose() {
    //widget.channel.sink.close();
    super.dispose();
  }
}
