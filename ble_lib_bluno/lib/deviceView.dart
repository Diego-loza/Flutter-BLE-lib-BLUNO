import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';

import 'bleDevice.dart';

class DeviceView extends StatefulWidget {
  BleDevice bleDevice;
  DeviceView({Key? key, required this.bleDevice}) : super(key: key);

  @override
  _DeviceViewState createState() => _DeviceViewState(bleDevice: bleDevice);
}

class _DeviceViewState extends State<DeviceView> {
  final String _serviceUuid = "0000dfb0-0000-1000-8000-00805f9b34fb";
  final String _characteristicUuid = "0000dfb1-0000-1000-8000-00805f9b34fb";

  BleDevice bleDevice;
  List<Service>? services;
  List<Characteristic>? characteristics;
  final _mensajeEnviado = TextEditingController();
  late String _mensajesRecibidos = "";

  _DeviceViewState({required this.bleDevice});

  void _getServices() async {
    services = await bleDevice.peripheral.services();
  }

  void _monitor() async {
    await bleDevice.peripheral.discoverAllServicesAndCharacteristics();
    services = await bleDevice.peripheral.services();
    services?.forEach((element) {
      print("SERVICE: $element");
    });
    characteristics = await bleDevice.peripheral.characteristics(_serviceUuid);
    characteristics?.forEach((element) {
      print("CHARACTERISTIC: $element");
    });
    /*bleDevice.peripheral.writeDescriptor("0000dfb0-0000-1000-8000-00805f9b34fb",
        "0000dfb1-0000-1000-8000-00805f9b34fb", "2902", Uint8List(0x2902));*/
    bleDevice.peripheral
        .monitorCharacteristic(_serviceUuid, _characteristicUuid)
        .listen((event) {
      print(String.fromCharCodes(event.value));
      setState(() {
        _mensajesRecibidos =
            _mensajesRecibidos + String.fromCharCodes(event.value);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _monitor();
  }

  @override
  void dispose() {
    bleDevice.peripheral.disconnectOrCancelConnection();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(bleDevice.name),
      ),
      body: Column(
        children: [
          const Text("Mensaje enviado:"),
          TextField(
            keyboardType: TextInputType.text,
            controller: _mensajeEnviado,
          ),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  _mensajesRecibidos = '';
                });
                print(_mensajeEnviado.text.codeUnits.toString());
                bleDevice.peripheral.writeCharacteristic(
                    "0000dfb0-0000-1000-8000-00805f9b34fb",
                    "0000dfb1-0000-1000-8000-00805f9b34fb",
                    Uint8List.fromList(_mensajeEnviado.text.codeUnits),
                    false);
              },
              child: const Text("Enviar")),
          const Text("Mensajes recibidos:"),
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Text(
                _mensajesRecibidos,
                style: const TextStyle(fontSize: 16.0, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
