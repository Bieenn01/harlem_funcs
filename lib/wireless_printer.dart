import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';

class FlutterThermalPrinter extends StatefulWidget {
  @override
  _FlutterThermalPrinterState createState() => new _FlutterThermalPrinterState();
}

class _FlutterThermalPrinterState extends State<FlutterThermalPrinter> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _device;
  bool _connected = false;
  TextEditingController _textController = TextEditingController();
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    bool? isConnected = await bluetooth.isConnected;
    List<BluetoothDevice> devices = [];
    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException {}

    bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          setState(() {
            _connected = true;
            Fluttertoast.showToast(msg: 'Connected to printer');
            print("bluetooth device state: connected");
          });
          break;
        case BlueThermalPrinter.DISCONNECTED:
          setState(() {
            _connected = false;
            Fluttertoast.showToast(msg: 'Disconnected from printer');
            print("bluetooth device state: disconnected");
          });
          break;
      }
    });

    if (!mounted) return;
    setState(() {
      _devices = devices;
    });

    if (isConnected == true) {
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
          title: const Text('Blue Thermal Printer'),
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
                      child: DropdownButton(
                        items: _getDeviceItems(),
                        onChanged: (BluetoothDevice? value) =>
                            setState(() => _device = value),
                        value: _device,
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
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
                      onPressed: () {
                        initPlatformState();
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
                          backgroundColor: _connected ? Colors.red : Colors.green),
                      onPressed: _connected ? _disconnect : _connect,
                      child: Text(
                        _connected ? 'Disconnect' : 'Connect',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 10.0, right: 10.0, top: 50),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
                    onPressed: () {
                      if (_connected) {
                        printText(_textController.text);
                      } else {
                        Fluttertoast.showToast(msg: 'Printer not connected');
                      }
                    },
                    child: const Text('PRINT TEXT', style: TextStyle(color: Colors.white)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      labelText: 'Enter Text',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: ElevatedButton(
                //     style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
                //     onPressed: _pickImage,
                //     child: const Text('SELECT IMAGE', style: TextStyle(color: Colors.white)),
                //   ),
                // ),
                // if (_imageBytes != null) Image.memory(_imageBytes!),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    items.add(const DropdownMenuItem(
      value: null,
      child: Text('Please Select Device'),
    ));

    // Add devices to the dropdown list
    for (var device in _devices) {
      items.add(DropdownMenuItem(
        value: device,
        child: Text(device.name ?? ""),
      ));
    }

    return items;
  }

  void _connect() {
    if (_device != null) {
      bluetooth.isConnected.then((isConnected) {
        if (isConnected == true) {
          print('Already connected');
          setState(() => _connected = true);
        } else {
          bluetooth.connect(_device!).then((value) {
            setState(() => _connected = value);
            if (_connected) {
              Fluttertoast.showToast(msg: 'Connected to printer');
            } else {
              Fluttertoast.showToast(msg: 'Failed to connect to printer');
            }
          }).catchError((error) {
            print('Error connecting: $error');
            setState(() => _connected = false);
            Fluttertoast.showToast(msg: 'Error connecting to printer');
          });
        }
      });
    } else {
      Fluttertoast.showToast(msg: 'No device selected');
    }
  }

  void _disconnect() {
    bluetooth.disconnect();
    setState(() => _connected = false);
  }

  void printText(String text) {
    if (_connected) {
      bluetooth.printCustom(text, 1, 1);
    } else {
      Fluttertoast.showToast(msg: 'Printer not connected');
    }
  }

//   Future<void> _pickImage() async {
//     final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       final bytes = await pickedFile.readAsBytes();
//       setState(() {
//         _imageBytes = Uint8List.fromList(bytes);
//       });
//       _printImage(_imageBytes!);
//     }
//   }

// void _printImage(Uint8List image) {
//   if (_connected) {
//     bluetooth.printImageBytes(image);
//     Fluttertoast.showToast(msg: 'Image printed successfully');
//   } else {
//     Fluttertoast.showToast(msg: 'Printer not connected');
//   }
// }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
