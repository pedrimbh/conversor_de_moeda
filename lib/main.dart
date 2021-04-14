import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

const request = 'https://api.hgbrasil.com/finance?format=json&key=6f559199';

void main() async {
  runApp(
    MaterialApp(
      home: Home(),
      theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          hintStyle: TextStyle(color: Colors.amber),
        ),
      ),
    ),
  );
}

Future<Map> getData() async {
  http.Response response = await http.get(Uri.parse(request));
  return json.decode(response.body);
}

class Home extends StatefulWidget {
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
    double real = double.parse(text);
        dolarController.text = (real/dolar).toStringAsFixed(2);
        euroController.text = (real/euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
      double dolar = double.parse(text);
      realController.text = (dolar * this.dolar).toStringAsFixed(2);
      euroController.text = (dolar* this.dolar /euro).toStringAsFixed(2);

  }

  void _euroChanged(String text) {
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro /dolar).toStringAsFixed(2);
  }
  void _clearAll(){
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('\$Conversor\$'),
        centerTitle: true,
        backgroundColor: Colors.amber,
        actions: [
          IconButton(icon: Icon(Icons.refresh),iconSize: 35,onPressed:_clearAll,)
        ],
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        // ignore: missing_return
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text(
                  'Carregando dados',
                  style: TextStyle(color: Colors.amber, fontSize: 25.0),
                  textAlign: TextAlign.center,
                ),
              );
            default:
              if (snapshot.hasError) {
                return Text(
                  'Erro ao Carregar',
                  style: TextStyle(color: Colors.amber, fontSize: 25.0),
                  textAlign: TextAlign.center,
                );
              } else {
                dolar = snapshot.data['results']['currencies']['USD']['buy'];
                euro = snapshot.data['results']['currencies']['EUR']['buy'];
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          Icons.monetization_on,
                          size: 150,
                          color: Colors.amber,
                        ),
                        Divider(
                          height: 16,
                        ),
                        buildTextField("Reais", "R\$", realController,_realChanged),
                        Padding(
                            padding: const EdgeInsets.only(top: 16, bottom: 16),
                            child: buildTextField(
                                "Dolares", "US\$", dolarController,_dolarChanged)),
                        buildTextField("Euro", "€", euroController, _euroChanged),
                      ],
                    ),
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildTextField(String label, String prefix,
    TextEditingController controller, Function fun) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        prefixText: prefix),
    style: TextStyle(color: Colors.amber, fontSize: 25),
    onChanged: fun,
    keyboardType: TextInputType.numberWithOptions(decimal: true),
  );
}

