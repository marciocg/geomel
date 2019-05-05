import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Geomel',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: MyStatefulWidget(),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  MyStatefulWidget({Key key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  Geolocator geolocator = Geolocator();
  LocationOptions locationOptions = LocationOptions(
      accuracy: LocationAccuracy.best, distanceFilter: 10, timeInterval: 2000);
  double latitude;
  double longitude;
  List<String> _listaLocalSalvo = [];
  //Map<String, dynamic> _mapaNomeLocal = {};
  //List<String> _listaNomeLocal = [];

  @override
  void initState() {
    super.initState();
    geolocator.getPositionStream(locationOptions).listen((Position posicao) {
      setState(() {
        latitude = posicao.latitude;
        longitude = posicao.longitude;
//        latitude = (posicao.latitude != null) ? posicao.latitude : 0;
//        longitude = (posicao.longitude != null) ? posicao.longitude : 0;
      });
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Locais salvos'),
      ),
      body: Center(
        child: _buildListaLocalSalvo(),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 70.0,
          child: Center(
            child: (latitude != null && longitude != null)
                ? Text('\n' + 'Latitude: ' +
                    latitude.toString() +
                    ' Longitude: ' +
                    longitude.toString())
                : Text('\n' + 'Verifique se a localização está ativa'),
          ),
        ),
      ),
      floatingActionButton: (latitude != null && longitude != null)
          ? FloatingActionButton(
//          onPressed: () => setState(() {
//            _listaLocalSalvo.add(latitude.toString() + ',' + longitude.toString());
//            _gravaListaLocaisSalvos();
//          }),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => new AlertDialog(
                        title: new Text("Insira o nome do local"),
                        content: new TextField(
                            autofocus: true,
                            decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(),
//                                border: InputBorder.none,
                                hintText: 'exemplo: Isca 1'),
                            onSubmitted: (texto) => setState(() {
//                              _mapaNomeLocal.addAll({texto: latitude.toString() + ',' + longitude.toString()});
                              _listaLocalSalvo.add(texto + '¨§°' + latitude.toString() + ',' + longitude.toString());
                              _gravaListaLocaisSalvos();
                              Navigator.of(context).pop();
                            }),
// esse 'actions' sem o setState apenas cancela, mas o usuário pode clicar fora da janela
//                        actions: <Widget>[
//                          FlatButton(
//                            child: Text('OK'),
//                            onPressed: () => setState(() {
//                                  _listaLocalSalvo.add(latitude.toString() +
//                                      ',' +
//                                      longitude.toString());
//                                  _gravaListaLocaisSalvos();
//                                  Navigator.of(context).pop();
//                                }),
//                          ),
//                        ],
                      ),
                ),
                );},
              tooltip: 'Marcar localização no Google Maps',
              child: Icon(Icons.add_location))
          : FloatingActionButton(
              backgroundColor: Colors.grey[400],
              tooltip: 'Localização desativada',
              child: Icon(Icons.location_off)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  _abrirURL(String localizacao, {forceWebView = true}) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=' + localizacao;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Erro ao conectar em $url';
    }
  }

  Widget _buildListaLocalSalvo() {
    _recuperaListaLocaisSalvos();

    return ListView.builder(
        padding: const EdgeInsets.all(9.0),
        itemCount: _listaLocalSalvo.length,
        itemBuilder: (BuildContext contexto, int indice) {
          return _buildRow(indice);
        });
  }

  Widget _buildRow(int indice) {
//    print('tit ' + _listaLocalSalvo[indice].split('¨§°').toList()[0].toString());
//    print('pos ' + _listaLocalSalvo[indice].split('¨§°').toList()[1].toString());
//    print('len ' + _listaLocalSalvo[indice].split('¨§°').length.toString());
    String titulo = _listaLocalSalvo[indice].split('¨§°').elementAt(0);
    String subtitulo = (_listaLocalSalvo[indice].split('¨§°').length > 1)
                  ? _listaLocalSalvo[indice].split('¨§°').elementAt(1)
                  : '';
    return ListTile(
      title: Text(titulo),
      subtitle: Text(subtitulo),
//      title: Text(localSalvo),
      trailing: Icon(Icons.map, color: Colors.redAccent),
      onLongPress: () {
        setState(() {
          _listaLocalSalvo.removeAt(indice);
          _gravaListaLocaisSalvos();
        });
      },
      onTap: () {
        _abrirURL(subtitulo, forceWebView: true);
      },
    );
  }

  _recuperaListaLocaisSalvos() async {
    final database = await SharedPreferences.getInstance();
    final chave = 'lista_locais_salvos';
    _listaLocalSalvo = database.getStringList(chave) ?? [];
  }

  _gravaListaLocaisSalvos() async {
    final database = await SharedPreferences.getInstance();
    final chave = 'lista_locais_salvos';
    database.setStringList(chave, _listaLocalSalvo);
  }
}
