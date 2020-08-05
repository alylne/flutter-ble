import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_blue_example/widgets.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:bluetooth/bluetooth.dart';
import './widgets.dart';

void main() {
  runApp(new FlutterBlueApp());
}


class BluetoothApp extends StatefulWidget {
  @override
  _BluetoothAppState createState() => _BluetoothAppState();
}

class _BluetoothAppState extends State<BluetoothApp> {

  //Inicializando uma globalKey, pois isso nos ajudá a mostrar uma SnackBar posteriormente
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  //Obtém uma instância do bluetooth
  FlutterBluetoothSerial bluetooth = FlutterBluetoothSerial.instance;

  //Defina algumas variáveis, que serão necessárias posteriormente
  List<BluetoothDevice> _devicesList = [];

  BluetoothDevice _device;
  bool _connected = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      // Aqui no container vamos criar a interface do app
    );
  }
}

class _BluetoothAppState extends State<BluetoothApp> {

  @override
  void initState() {
    super.initState();
    bluetoothConnectionState();
  }

// Aqui nós vamos utilizar um callback async utilizando await
  Future<void> bluetoothConnectionState() async {
    List<BluetoothDevice> devices = [];

// Obtemos a lista de dispositivos pareados
    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException {
      print("Error");
    }

// neste ponto verificamos se o bluetooth está conectado ou desconectado
    bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case FlutterBluetoothSerial.CONNECTED:
          setState(() {
            _connected = true;
            _pressed = false;
          });

          break;

        case FlutterBluetoothSerial.DISCONNECTED:
          setState(() {
            _connected = false;
            _pressed = false;
          });
          break;

        default:
          print(state);
          break;
      }
    });

    if (!mounted) {
      return;
    }

    setState(() {
      _devicesList = devices;
    });


    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        home: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text(“Flutter Bluetooth”),
            backgroundColor: Colors.deepPurple,
          ),
          body: Container(
            child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
            Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
            “PAIRED DEVICES”,
            style: TextStyle(fontSize: 24, color: Colors.blue),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
          Text(
          ‘Device:’,
            style: TextStyle(fontWeight: FontWeight.bold,),
          ),
          DropdownButton(
            // To be implemented : _getDeviceItems()
            items: _getDeviceItems(),
            onChanged: (value) => setState(() => _device = value),
            value: _device,
          ),
          RaisedButton(
            onPressed:
            // To be implemented : _disconnect and _connect
            _pressed ? null : _connected ? _disconnect : _connect,
            child: Text(_connected ? ‘Disconnect’ : ‘Connect’),
          ),
          ],
        ),
      ),
      Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
      elevation: 4,
      child: Padding(
      padding: const EdgeInsets.all(8.0),
      // Defining a Row containing THREE main Widgets:
      // 1. Text (wrapped with “Expanded”)
      // 2. FlatButton
      // 3. FlatButton
      child: Row(
      children: <Widget>[
      Expanded(
      child: Text(
      “DEVICE 1”,
      style: TextStyle(fontSize: 20,color: Colors.green,),
      ),
      ),
      FlatButton(
      onPressed:
      // To be implemented : _sendOnMessageToBluetooth()
      _connected ? _sendOnMessageToBluetooth : null,
      child: Text(“ON”),
      ),
      FlatButton(
      onPressed:
      // To be implemented : _sendOffMessageToBluetooth()
      _connected ? _sendOffMessageToBluetooth : null,
      child: Text(“OFF”),
      ),
      ],
      ),
      ),
      ),
      ),
      Expanded(
      child: Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
      child: Text(
      "NOTE: If you cannot find the device in the list, "
      "please turn on bluetooth and pair the device by "
      “going to the bluetooth settings”,
      style: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.bold,
      color: Colors.red),
      ),
      ),
      ),
      )
      ],
      ),
      ),
      ),
      );
    }


    List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
      List<DropdownMenuItem<BluetoothDevice>> items = [];
      if (_devicesList.isEmpty) {
        items.add(DropdownMenuItem(
          child: Text(‘NONE’),
        ));
      } else {
        _devicesList.forEach((device) {
          items.add(DropdownMenuItem(
            child: Text(device.name),
            value: device,
          ));
        });
      }
      return items;
    }



    // Método que conecta o bluetooth
    void _connect() {
      if (_device == null) {
        show(‘No device selected’);
      } else {
        bluetooth.isConnected.then((isConnected) {
          if (!isConnected) {
            bluetooth
                .connect(_device)
                .timeout(Duration(seconds: 10))
                .catchError((error) {
              setState(() => _pressed = false);
            });
            setState(() => _pressed = true);
          }
        });
      }
    }

// Método que desconecta o bluetooth
    void _disconnect() {
      bluetooth.disconnect();
      setState(() => _pressed = true);
    }

// Método que exibe a Snackbar com a mensagem
    Future show(
        String message, {
          Duration duration: const Duration(seconds: 3),
        }) async {
      await new Future.delayed(new Duration(milliseconds: 100));
      _scaffoldKey.currentState.showSnackBar(
        new SnackBar(
          content: new Text(
            message,
          ),
          duration: duration,
        ),
      );
    }


    void _sendOnMessageToBluetooth() {
      bluetooth.isConnected.then((isConnected) {
        if (isConnected) {
          bluetooth.write(“1”);
          show(‘Device Turned On’);
        }
      });
    }

    void _sendOffMessageToBluetooth() {
      bluetooth.isConnected.then((isConnected) {
        if (isConnected) {
          bluetooth.write(“0”);
          show(‘Device Turned Off’);
        }
      });
    }
