import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleManager {
  BluetoothDevice? _device;
  BluetoothCharacteristic? _writeCharacteristic;

  final StreamController<List<int>> _rxController =
  StreamController<List<int>>.broadcast();

  Stream<List<int>> get rxStream => _rxController.stream;
  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;

  BluetoothDevice? get connectedDevice => _device;

  Future<void> startScan() async {
    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 5),
    );
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  Future<void> connect(ScanResult result) async {
    final device = result.device;

    await FlutterBluePlus.stopScan();

    _device = device;

    await device.connect(
      timeout: const Duration(seconds: 10),
      autoConnect: false,
    );

    await device.requestMtu(247);

    final services = await device.discoverServices();

    for (final service in services) {
      for (final c in service.characteristics) {
        if (_writeCharacteristic == null &&
            (c.properties.write || c.properties.writeWithoutResponse)) {
          _writeCharacteristic = c;
        }

        if (c.properties.notify || c.properties.indicate) {
          await c.setNotifyValue(true);
          c.lastValueStream.listen((value) {
            if (value.isNotEmpty) {
              _rxController.add(value);
            }
          });
        }
      }
    }
  }

  Future<void> write(List<int> data) async {
    final c = _writeCharacteristic;

    if (c == null) {
      throw StateError('Write characteristic is not ready.');
    }

    await c.write(data, withoutResponse: false);
  }

  Future<void> disconnect() async {
    await _device?.disconnect();
    _device = null;
    _writeCharacteristic = null;
  }
}