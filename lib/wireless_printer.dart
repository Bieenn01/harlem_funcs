import 'dart:async';
import 'dart:typed_data';

import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:permission_handler/permission_handler.dart';

class FlutterThermalPrinter extends StatefulWidget {
  @override
  _FlutterThermalPrinterState createState() => _FlutterThermalPrinterState();
}

class _FlutterThermalPrinterState extends State<FlutterThermalPrinter> {
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;

  String tips = 'no device connected';
  BluetoothDevice? _device;
  bool _connected = false;
  TextEditingController _textController = TextEditingController();
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) => initBluetooth());
  }

  Future<void> initBluetooth() async {
    bool isConnected = await bluetoothPrint.isConnected ?? false;

    bluetoothPrint.state.listen((state) {
      print('******************* cur device status: $state');

      switch (state) {
        case BluetoothPrint.CONNECTED:
          setState(() {
            _connected = true;
            tips = 'connect success';
          });
          break;
        case BluetoothPrint.DISCONNECTED:
          setState(() {
            _connected = false;
            tips = 'disconnect success';
          });
          break;
        default:
          break;
      }
    });

    if (isConnected) {
      setState(() {
        _connected = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Bluetooth Thermal Printer'),
        ),
        body: Container(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(
                      width: 10,
                    ),
                    const Text(
                      'Device:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      width: 30,
                    ),
                    Expanded(
                      child: StreamBuilder<List<BluetoothDevice>>(
                        stream: bluetoothPrint.scanResults,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Text('No devices found');
                          }
                          return DropdownButton<BluetoothDevice>(
                            items: _getDeviceItems(snapshot.data!),
                            onChanged: (BluetoothDevice? value) {
                              setState(() {
                                _device = value;
                              });
                            },
                            value: _device,
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                      ),
                      onPressed: () {
                        setState(() {
                          _device = null; // Reset selected device
                        });
                        bluetoothPrint.startScan(
                            timeout: Duration(milliseconds: 500));
                      },
                      child: const Text(
                        'Refresh',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _connected ? Colors.red : Colors.green,
                      ),
                      onPressed: _connected ? _disconnect : _connect,
                      child: Text(
                        _connected ? 'Disconnect' : 'Connect',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _textController,
                    onSubmitted: (String value) {
                      if (_connected) {
                        // Prepare data for printReceipt method
                        Map<String, dynamic> config = {
                          'key1': 'value1',
                          'key2': 'value2',
                          // Add any configuration parameters needed
                        };
                        List<LineText> data = [
                          LineText(
                            type: LineText.TYPE_TEXT,
                            content: value,
                            weight: LineText.ALIGN_CENTER,
                            align: LineText.ALIGN_LEFT,
                            size: LineText.ALIGN_RIGHT,
                            linefeed: 1,
                          ),
                          // You can add more LineText objects as needed
                        ];

                        printReceipt(config, data);
                      } else {
                        Fluttertoast.showToast(msg: 'Printer not connected');
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Enter Text and press Enter',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems(
      List<BluetoothDevice> devices) {
    List<DropdownMenuItem<BluetoothDevice>> items = [];

    items.add(DropdownMenuItem(
      value: null,
      child: Text('Please Select Device'),
    ));

    for (var device in devices) {
      items.add(DropdownMenuItem(
        value: device,
        child: Text(device.name ?? ""),
      ));
    }
    return items;
  }

  void _connect() async {
    if (_device != null) {
      PermissionStatus status = await Permission.bluetooth.status;
      if (status != PermissionStatus.granted) {
        status = await Permission.bluetooth.request();
        if (status != PermissionStatus.granted) {
          Fluttertoast.showToast(msg: 'Bluetooth permission denied');
          return;
        }
      }

      try {
        await bluetoothPrint.connect(_device!);
      } catch (e) {
        print('Error connecting: $e');
        Fluttertoast.showToast(msg: 'Failed to connect to printer');
      }
    } else {
      Fluttertoast.showToast(msg: 'No device selected');
    }
  }

  void _disconnect() {
    bluetoothPrint.disconnect();
    setState(() => _connected = false);
  }

  Future<void> printReceipt(
      Map<String, dynamic> config, List<LineText> data) async {
    try {
      await bluetoothPrint.printReceipt(config, data);
    } catch (e) {
      print('Error printing receipt: $e');
      Fluttertoast.showToast(msg: 'Failed to print receipt');
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
