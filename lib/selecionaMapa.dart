import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'assets/mapa_offline.dart';

class Mapa {
  late TileLayerOptions _mapaSelecionado;
  late Text _mapa_provedor;

  TileLayerOptions get mapaSelecionado => _mapaSelecionado;
  Text get mapaProvedor => _mapa_provedor;

  Mapa (String mapaSelecionado){
    this._mapaSelecionado = TileLayerOptions(
      urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
      subdomains: ['a', 'b', 'c'],
      tileProvider: const CachedTileProvider(),
    );
    this._mapa_provedor = Text("© OpenStreetMap contributors");
  }
}