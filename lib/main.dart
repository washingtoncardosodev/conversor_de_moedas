import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?format=json&key=61278822";

void main() async {

  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
      hintColor: Colors.blue,
      primaryColor: Colors.blue,
      inputDecorationTheme: InputDecorationTheme(
        enabledBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
        focusedBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
        hintStyle: TextStyle(color: Colors.blue),
      )
    ),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar;
  double euro;

void _realChanged(String text) {

  if (text.isEmpty) {
    _clearAll();
    return;
  }

  double real = double.parse(text);
  dolarController.text = (real / this.dolar).toStringAsFixed(2);
  euroController.text = (real / this.euro).toStringAsFixed(2);
}

void _dolarChanged(String text) {

  if (text.isEmpty) {
    _clearAll();
    return;
  }

  double dolar = double.parse(text);
  realController.text = (dolar * this.dolar).toStringAsFixed(2);
  euroController.text = (dolar * this.dolar / this.euro).toStringAsFixed(2);
}

void _euroChanged(String text) {

  if (text.isEmpty) {
    _clearAll();
    return;
  }
  
  double euro = double.parse(text);
  realController.text = (euro * this.euro).toStringAsFixed(2);
  dolarController.text = (euro * this.euro / this.dolar).toStringAsFixed(2);
}

void _clearAll() {
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Conversor de Moedas"),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text("Carregando...", style: TextStyle(fontSize: 25.0), textAlign: TextAlign.center),
              );
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text("Erro ao carregar dados...", style: TextStyle(fontSize: 25.0), textAlign: TextAlign.center),
                );
              } else {
                this.dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                this.euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                return SingleChildScrollView(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(Icons.monetization_on, size: 100.0, color: Colors.blue),  
                      buildTextField("Reais", "R\$ ", realController, _realChanged),
                      Divider(),
                      buildTextField("Dólares", "US\$ ", dolarController, _dolarChanged),
                      Divider(),
                      buildTextField("Euros", "€ ", euroController, _euroChanged),
                    ],
                  )
                );
              }
          }
        }
      )
    );
  }
}

Widget buildTextField(String label, String prefix, TextEditingController c, Function f) {
  return TextFormField(
    keyboardType: TextInputType.number,
    decoration: InputDecoration(labelText: label, labelStyle: TextStyle(fontSize: 15.0), border: OutlineInputBorder(), prefixText: prefix),
    style: TextStyle(color: Colors.blue, fontSize: 20.0),
    controller: c,
    onChanged: f,
  );
}