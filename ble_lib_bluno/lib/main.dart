import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:permission_handler/permission_handler.dart';

import 'bleDevice.dart';
import 'deviceCard.dart';

void main() {
  runApp(MaterialApp(
    builder: EasyLoading.init(),
    title: 'Flutter BLE lib with BLUNO',
    routes: {
      '/': (context) => MyHomePage(),
    },
  ));
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

enum BluetoothState {
  UNKNOWN,
  UNSUPPORTED,
  UNAUTHORIZED,
  POWERED_ON,
  POWERED_OFF,
  RESETTING,
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  List<BleDevice> bleDevices = <BleDevice>[];
  StreamSubscription<ScanResult>? _scanSubscription;
  BleManager _bleManager = BleManager();

  void _startScan() {
    print("Ble start scan");
    _scanSubscription = _bleManager.startPeripheralScan(
        uuids: ['0000dfb0-0000-1000-8000-00805f9b34fb']).listen((scanResult) {
      var bleDevice = BleDevice(scanResult);
      if (!bleDevices.contains(bleDevice)) {
        print(
            'found new device ${scanResult.advertisementData.localName} ${scanResult.peripheral.identifier}');
        setState(() {
          bleDevices.add(bleDevice);
        });
      }
    });
  }

  Future<void> _checkPermissions() async {
    if (Platform.isAndroid) {
      var locGranted = await Permission.location.isGranted;
      if (locGranted == false) {
        locGranted = (await Permission.location.request()).isGranted;
      }
      if (locGranted == false) {
        return Future.error(Exception("Location permission not granted"));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _bleManager.createClient();
    _checkPermissions();
    _startScan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FLUTTER APP"),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Dispositivos encontrados:',
              ),
              SingleChildScrollView(
                child: Column(
                  children:
                      bleDevices.map((d) => DeviceCard(bleDevice: d)).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: IconButton(
        onPressed: () {},
        tooltip: 'Increment',
        icon: const Icon(Icons.search),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
