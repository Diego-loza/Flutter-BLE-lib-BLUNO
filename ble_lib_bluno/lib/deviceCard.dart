import 'package:flutter/material.dart';

import 'bleDevice.dart';
import 'deviceView.dart';

class DeviceCard extends StatelessWidget {
  BleDevice bleDevice;
  DeviceCard({Key? key, required this.bleDevice}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        print('presionado $bleDevice');
        bleDevice.peripheral
            .observeConnectionState(
                emitCurrentValue: true, completeOnDisconnect: true)
            .listen((connectionState) {
          print(
              "Peripheral ${bleDevice.peripheral.identifier} connection state is $connectionState");
        });
        await bleDevice.peripheral.connect();
        bool connected = await bleDevice.peripheral.isConnected();
        print(
            "Peripheral ${bleDevice.peripheral.identifier} connection state is $connected");
        if (connected) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DeviceView(bleDevice: bleDevice)));
        }
      },
      child: Card(
        margin: const EdgeInsets.fromLTRB(10.0, 2.5, 10.0, 2.5),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            children: [
              const Icon(
                Icons.bluetooth,
              ),
              Text(
                bleDevice.name,
                style: const TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
