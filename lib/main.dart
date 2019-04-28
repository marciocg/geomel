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
  LocationOptions locationOptions = LocationOptions(accuracy: LocationAccuracy.best, distanceFilter: 10, timeInterval: 2000);
  double latitude;
  double longitude;
  List<String> _listaLocalSalvo = [];

  @override
  void initState() {
    super.initState();
    geolocator.getPositionStream(locationOptions).listen((Position posicao) {
      setState(() {
        latitude = posicao.latitude;
        longitude = posicao.longitude;
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
        //child: Text('Latitude: ' + latitude.toString() +
        //    '\nLongitude: ' + longitude.toString()),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 80.0,
          child: Center(
              child: Text('Latitude: ' + latitude.toString() +
              ' Longitude: ' + longitude.toString()),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() {
          _listaLocalSalvo.add(latitude.toString() + '/' + longitude.toString());
          _gravaListaLocaisSalvos();
          //_abrirURL(forceWebView: true);
        }),
        tooltip: 'Marcar localização no Google Maps',
        child: Icon(Icons.add_location),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  _abrirURL({forceWebView = true}) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=' + latitude.toString() + "," + longitude.toString();
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Erro ao conectar em $url';
    }
  }

  Widget _buildListaLocalSalvo() {
    _recuperaListaLocaisSalvos();

    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _listaLocalSalvo.length,
        //reverse: true,
        itemBuilder: (BuildContext contexto, int indice) {
        //  if (_listaLocalSalvo.length == 0) {
        //  _recuperaListaLocaisSalvos();
        //  }
          return _buildRow(_listaLocalSalvo[indice], indice);
        }
    );
  }

  Widget _buildRow(String localSalvo, int indice) {
    return ListTile(
      title: Text(localSalvo),
      trailing: Icon(Icons.map, color: Colors.red),
      onLongPress: () {
        setState(() {
          _listaLocalSalvo.removeAt(indice);
          _gravaListaLocaisSalvos();
        });
      },
      onTap: () {
        _abrirURL(forceWebView: true);
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