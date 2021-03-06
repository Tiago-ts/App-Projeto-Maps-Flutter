
import 'package:Motorcycle/modal/Usuario.dart';
import 'package:Motorcycle/util/StatusRequisicao.dart';
import 'package:Motorcycle/util/UsuarioFirebase.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:io';

class Corrida extends StatefulWidget {

  String idRequisicao;

  Corrida( this.idRequisicao );

  @override
  _CorridaState createState() => _CorridaState();
}

class _CorridaState extends State<Corrida> {

  Completer<GoogleMapController> _controller = Completer();
  CameraPosition _posicaoCamera =
  CameraPosition(target: LatLng(-23.563999, -46.653256));
  Set<Marker> _marcadores = {};
  Map<String, dynamic> _dadosRequisicao;
  String _idRequisicao;
  Position _localPiloto;
  String _statusRequisicao = StatusRequisicao.AGUARDANDO;

  //Controles para exibição na tela
  String _textoBotao = "Aceitar corrida";
  Color _corBotao = Color(0xffffeb3b);
  Function _funcaoBotao;
  String _mensagemStatus = "";

  _alterarBotaoPrincipal(String texto, Color cor, Function funcao) {
    setState(() {
      _textoBotao = texto;
      _corBotao = cor;
      _funcaoBotao = funcao;
    });
  }

  _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  _adicionarListenerLocalizacao() {
    var geolocator = Geolocator();
    var locationOptions =
    LocationOptions(accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 10);

    geolocator.getPositionStream(locationOptions).listen((Position position) {

      if( position != null ){

        if( _idRequisicao != null && _idRequisicao.isNotEmpty ){

          if( _statusRequisicao != StatusRequisicao.AGUARDANDO ){

            //Atualiza local do passageiro
            UsuarioFirebase.atualizarDadosLocalizacao(
                _idRequisicao,
                position.latitude,
                position.longitude
            );

          }else{//aguardando
            setState(() {
              _localPiloto = position;
            });
            _statusAguardando();
          }

        }

      }

    });
  }

  _recuperaUltimaLocalizacaoConhecida() async {
    Position position = await Geolocator()
        .getLastKnownPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);

    if (position != null) {

      //Atualizar localização em tempo real do piloto


    }

  }

  _movimentarCamera(CameraPosition cameraPosition) async {
    GoogleMapController googleMapController = await _controller.future;
    googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  _exibirMarcador(Position local, String icone, String infoWindow) async {

    double pixelRatio = MediaQuery.of(context).devicePixelRatio;

    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: pixelRatio),
        icone)
        .then((BitmapDescriptor bitmapDescriptor) {
      Marker marcador = Marker(
          markerId: MarkerId(icone),
          position: LatLng(local.latitude, local.longitude),
          infoWindow: InfoWindow(title: infoWindow),
          icon: bitmapDescriptor);

      setState(() {
        _marcadores.add(marcador);
      });
    });


  }

  _recuperarRequisicao() async {

    String idRequisicao = widget.idRequisicao;

    Firestore db = Firestore.instance;
    DocumentSnapshot documentSnapshot = await db
        .collection("requisicoes")
        .document( idRequisicao )
        .get();




  }

  _adicionarListenerRequisicao() async {

    Firestore db = Firestore.instance;

    await db.collection("requisicoes")
        .document( _idRequisicao ).snapshots().listen((snapshot){

      if( snapshot.data != null ){

        _dadosRequisicao = snapshot.data;

        Map<String, dynamic> dados = snapshot.data;
        _statusRequisicao = dados["status"];

        switch( _statusRequisicao ){
          case StatusRequisicao.AGUARDANDO :
            _statusAguardando();
            break;
          case StatusRequisicao.A_CAMINHO :
            _statusACaminho();
            break;
          case StatusRequisicao.VIAGEM :
            _statusEmViagem();
            break;
          case StatusRequisicao.FINALIZADA :
            _statusFinalizada();
            break;
          case StatusRequisicao.CONFIRMADA :
            _statusConfirmada();
            break;

        }

      }

    });

  }

  _statusAguardando() {

    _alterarBotaoPrincipal(
        "Aceitar corrida",
        Color(0xffffeb3b),
            () {
          _aceitarCorrida();
        });

    if( _localPiloto != null ){

      double pilotoLat = _localPiloto.latitude;
      double pilotoLon = _localPiloto.longitude;

      Position position = Position(
          latitude: pilotoLat, longitude: pilotoLon
      );
      _exibirMarcador(
          position,
          "imagens/motorista.png",
          "Piloto"
      );

      CameraPosition cameraPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude), zoom: 19);

      _movimentarCamera( cameraPosition );

    }

  }

  _statusACaminho() {

    _mensagemStatus = "A caminho do passageiro";
    _alterarBotaoPrincipal(
        "Iniciar corrida",
        Color(0xffffeb3b),
            (){
          _iniciarCorrida();
        }
    );


    double latitudePassageiro = _dadosRequisicao["passageiro"]["latitude"];
    double longitudePassageiro = _dadosRequisicao["passageiro"]["longitude"];

    double latitudePiloto = _dadosRequisicao["piloto"]["latitude"];
    double longitudePiloto = _dadosRequisicao["piloto"]["longitude"];

    //Exibir dois marcadores
    _exibirDoisMarcadores(
        LatLng(latitudePiloto, longitudePiloto),
        LatLng(latitudePassageiro, longitudePassageiro)
    );

    //'southwest.latitude <= northeast.latitude': is not true
    var nLat, nLon, sLat, sLon;

    if( latitudePiloto <=  latitudePassageiro ){
      sLat = latitudePiloto;
      nLat = latitudePassageiro;
    }else{
      sLat = latitudePassageiro;
      nLat = latitudePiloto;
    }

    if( longitudePiloto <=  longitudePassageiro ){
      sLon = longitudePiloto;
      nLon = longitudePassageiro;
    }else{
      sLon = longitudePassageiro;
      nLon = longitudePiloto;
    }
    //-23.560925, -46.650623
    _movimentarCameraBounds(
        LatLngBounds(
            northeast: LatLng(nLat, nLon), //nordeste
            southwest: LatLng(sLat, sLon) //sudoeste
        )
    );

  }

  _finalizarCorrida(){

    Firestore db = Firestore.instance;
    db.collection("requisicoes")
        .document( _idRequisicao )
        .updateData({
      "status" : StatusRequisicao.FINALIZADA
    });


    String idPassageiro = _dadosRequisicao["passageiro"]["idUsuario"];
    db.collection("requisicao_ativa")
        .document( idPassageiro )
        .updateData({"status": StatusRequisicao.FINALIZADA });

    String idPiloto = _dadosRequisicao["piloto"]["idUsuario"];
    db.collection("requisicao_ativa_piloto")
        .document( idPiloto )
        .updateData({"status": StatusRequisicao.FINALIZADA });

  }

  _statusFinalizada() async {

    //Calcula valor da corrida
    double latitudeDestino = _dadosRequisicao["destino"]["latitude"];
    double longitudeDestino = _dadosRequisicao["destino"]["longitude"];

    double latitudeOrigem = _dadosRequisicao["origem"]["latitude"];
    double longitudeOrigem = _dadosRequisicao["origem"]["longitude"];

    double distanciaEmMetros = await Geolocator().distanceBetween(
        latitudeOrigem,
        longitudeOrigem,
        latitudeDestino,
        longitudeDestino
    );

    //Converte para KM
    double distanciaKm = distanciaEmMetros / 1000;

    //8 é o valor cobrado por KM
    double valorViagem = distanciaKm * 8;

    //Formatar valor viagem

    var f = new NumberFormat("#,##0.00", "pt_BR");
    var valorViagemFormatado = f.format( valorViagem );

    _mensagemStatus = "Viagem finalizada";

    _alterarBotaoPrincipal(
        "Confirmar - R\$ ${valorViagemFormatado}",
        Color(0xffffeb3b),
            (){
          _confirmarCorrida();
        }
    );

    _mensagemStatus = "Viagem finalizada";
    _alterarBotaoPrincipal(
        "Confirmar - R\$ ${valorViagemFormatado}",
        Color(0xff1ebbd8),
            (){
          _confirmarCorrida();
        }
    );

    _marcadores = {};
    Position position = Position(
        latitude: latitudeDestino, longitude: longitudeDestino
    );
    _exibirMarcador(
        position,
        "imagens/destino.png",
        "Destino"
    );

    CameraPosition cameraPosition = CameraPosition(
        target: LatLng(position.latitude, position.longitude), zoom: 19);

    _movimentarCamera( cameraPosition );

  }

  _statusConfirmada(){

    Navigator.pushReplacementNamed(context, "/painel-piloto");

  }

  _confirmarCorrida(){

    Firestore db = Firestore.instance;
    db.collection("requisicoes")
        .document( _idRequisicao )
        .updateData({
      "status" : StatusRequisicao.CONFIRMADA
    });

    String idPassageiro = _dadosRequisicao["passageiro"]["idUsuario"];
    db.collection("requisicao_ativa")
        .document( idPassageiro )
        .delete();

    String idPiloto = _dadosRequisicao["piloto"]["idUsuario"];
    db.collection("requisicao_ativa_piloto")
        .document( idPiloto )
        .delete();

  }

  _statusEmViagem() {

    _mensagemStatus = "Em viagem";
    _alterarBotaoPrincipal(
        "Finalizar corrida",
        Color(0xffffeb3b),
            (){
          _finalizarCorrida();
        }
    );


    double latitudeDestino = _dadosRequisicao["destino"]["latitude"];
    double longitudeDestino = _dadosRequisicao["destino"]["longitude"];

    double latitudeOrigem = _dadosRequisicao["piloto"]["latitude"];
    double longitudeOrigem = _dadosRequisicao["piloto"]["longitude"];

    //Exibir dois marcadores
    _exibirDoisMarcadores(
        LatLng(latitudeOrigem, longitudeOrigem),
        LatLng(latitudeDestino, longitudeDestino)
    );

    //'southwest.latitude <= northeast.latitude': is not true
    var nLat, nLon, sLat, sLon;

    if( latitudeOrigem <=  latitudeDestino ){
      sLat = latitudeOrigem;
      nLat = latitudeDestino;
    }else{
      sLat = latitudeDestino;
      nLat = latitudeOrigem;
    }

    if( longitudeOrigem <=  longitudeDestino ){
      sLon = longitudeOrigem;
      nLon = longitudeDestino;
    }else{
      sLon = longitudeDestino;
      nLon = longitudeOrigem;
    }
    //-23.560925, -46.650623
    _movimentarCameraBounds(
        LatLngBounds(
            northeast: LatLng(nLat, nLon), //nordeste
            southwest: LatLng(sLat, sLon) //sudoeste
        )
    );

  }

  _iniciarCorrida(){

    Firestore db = Firestore.instance;
    db.collection("requisicoes")
        .document( _idRequisicao )
        .updateData({
      "origem" : {
        "latitude" : _dadosRequisicao["piloto"]["latitude"],
        "longitude" : _dadosRequisicao["piloto"]["longitude"]
      },
      "status" : StatusRequisicao.VIAGEM
    });

    String idPassageiro = _dadosRequisicao["passageiro"]["idUsuario"];
    db.collection("requisicao_ativa")
        .document( idPassageiro )
        .updateData({"status": StatusRequisicao.VIAGEM });

    String idPiloto = _dadosRequisicao["piloto"]["idUsuario"];
    db.collection("requisicao_ativa_piloto")
        .document( idPiloto )
        .updateData({"status": StatusRequisicao.VIAGEM });

  }

  _movimentarCameraBounds(LatLngBounds latLngBounds) async {

    GoogleMapController googleMapController = await _controller.future;
    googleMapController
        .animateCamera(
        CameraUpdate.newLatLngBounds(
            latLngBounds,
            100
        )
    );

  }

  _exibirDoisMarcadores(LatLng latLngPiloto, LatLng latLngPassageiro){

    double pixelRatio = MediaQuery.of(context).devicePixelRatio;

    Set<Marker> _listaMarcadores = {};
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: pixelRatio),
        "imagens/motorista.png")
        .then((BitmapDescriptor icone) {
      Marker marcador1 = Marker(
          markerId: MarkerId("marcador-piloto"),
          position: LatLng(latLngPiloto.latitude, latLngPiloto.longitude),
          infoWindow: InfoWindow(title: "Local piloto"),
          icon: icone);
      _listaMarcadores.add( marcador1 );
    });

    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: pixelRatio),
        "imagens/passageiro.png")
        .then((BitmapDescriptor icone) {
      Marker marcador2 = Marker(
          markerId: MarkerId("marcador-passageiro"),
          position: LatLng(latLngPassageiro.latitude, latLngPassageiro.longitude),
          infoWindow: InfoWindow(title: "Local passageiro"),
          icon: icone);
      _listaMarcadores.add( marcador2 );
    });

    setState(() {
      _marcadores = _listaMarcadores;
    });

  }

  _aceitarCorrida() async {

    //Recuperar dados do piloto
    Usuario piloto   = await UsuarioFirebase.getDadosUsuarioLogado();
    piloto.latitude  = _localPiloto.latitude;
    piloto.longitude = _localPiloto.longitude;

    Firestore db = Firestore.instance;
    String idRequisicao = _dadosRequisicao["id"];

    db.collection("requisicoes")
        .document( idRequisicao ).updateData({
      "piloto" : piloto.toMap(),
      "status" : StatusRequisicao.A_CAMINHO,
    }).then((_){

      //atualiza requisicao ativa
      String idPassageiro = _dadosRequisicao["passageiro"]["idUsuario"];
      db.collection("requisicao_ativa")
          .document( idPassageiro ).updateData({
        "status" : StatusRequisicao.A_CAMINHO,
      });

      //Salvar requisicao ativa para piloto
      String idPiloto = piloto.idUsuario;
      db.collection("requisicao_ativa_piloto")
          .document( idPiloto )
          .setData({
        "id_requisicao" : idRequisicao,
        "id_usuario" : idPiloto,
        "status" : StatusRequisicao.A_CAMINHO,
      });

    });



  }

  @override
  void initState() {
    super.initState();

    _idRequisicao = widget.idRequisicao;

    // adicionar listener para mudanças na requisicao
    _adicionarListenerRequisicao();

    //_recuperaUltimaLocalizacaoConhecida();
    _adicionarListenerLocalizacao();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Painel corrida - " + _mensagemStatus ),
      ),
      body: Container(
        child: Stack(
          children: <Widget>[
            GoogleMap(

              //mapa piloto

              mapType: MapType.normal,
              //mapType: MapType.satellite,
              initialCameraPosition: _posicaoCamera,
              onMapCreated: _onMapCreated,
              //myLocationEnabled: true,
              myLocationButtonEnabled: false,
              markers: _marcadores,
              //-23,559200, -46,658878
            ),
            Positioned(
              right: 0,
              left: 0,
              bottom: 0,
              child: Padding(
                padding: Platform.isIOS
                    ? EdgeInsets.fromLTRB(20, 10, 20, 25)
                    : EdgeInsets.all(10),
                child: RaisedButton(
                    child: Text(
                      _textoBotao,
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                    color: _corBotao,
                    padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                    onPressed: _funcaoBotao),
              ),
            )
          ],
        ),
      ),
    );
  }
}
