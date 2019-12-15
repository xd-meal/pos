import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:async';
import 'package:usb_serial/usb_serial.dart';
import 'package:usb_serial/transaction.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  UsbPort _port;
  String _status = "Idle";
  String _serialData = "";
  List<Widget> _ports = [];
  StreamSubscription<String> _subscription;
  Transaction<String> _transaction;
  int _deviceId;

  Future<bool> _connectTo(device) async {
    if (_subscription != null) {
      _subscription.cancel();
      _subscription = null;
    }

    if (_transaction != null) {
      _transaction.dispose();
      _transaction = null;
    }

    if (_port != null) {
      _port.close();
      _port = null;
    }

    if (device == null) {
      _deviceId = null;
      setState(() {
        _status = "Disconnected";
      });
      return true;
    }

    _port = await device.create();
    if (!await _port.open()) {
      setState(() {
        _status = "Failed to open port";
      });
      return false;
    }

    _deviceId = device.deviceId;
    await _port.setDTR(true);
    await _port.setRTS(true);
    await _port.setPortParameters(
        115200, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);

    _transaction = Transaction.stringTerminated(
        _port.inputStream, Uint8List.fromList([13, 10]));

    _subscription = _transaction.stream.listen((String line) {
      setState(() {
        _serialData = line;
      });
    });

    setState(() {
      _status = "Connected";
    });
    return true;
  }

  void _getPorts() async {
    _ports = [];
    List<UsbDevice> devices = await UsbSerial.listDevices();

    devices.forEach((device) {
      _ports.add(ListTile(
          leading: Icon(Icons.usb),
          title: Text(device.productName),
          subtitle: Text(device.manufacturerName),
          trailing: RaisedButton(
            child:
                Text(_deviceId == device.deviceId ? "Disconnect" : "Connect"),
            onPressed: () {
              _connectTo(_deviceId == device.deviceId ? null : device)
                  .then((res) {
                _getPorts();
              });
            },
          )));
    });

    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    UsbSerial.usbEventStream.listen((UsbEvent event) {
      _getPorts();
    });

    _getPorts();
  }

  @override
  void dispose() {
    super.dispose();
    _connectTo(null);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(children: <Widget>[
          Text('device list: ' + _ports.length.toString(),
              style: Theme.of(context).textTheme.title),
          ..._ports,
          Text('Status: $_status\n'),
          GridView.count(
            primary: false,
            padding: const EdgeInsets.all(20),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            shrinkWrap: true,
            crossAxisCount: 4,
            children: <Widget>[
              RaisedButton(
                child: Text("Start Read"),
                onPressed: _port == null
                    ? null
                    : () async {
                        if (_port == null) {
                          return;
                        }
                        await _port.write(Uint8List.fromList(
                            [0x7E, 0x00, 0x01, 0x01, 0x00, 0xAB, 0xCD]));
                      },
              ),
              RaisedButton(
                child: Text("Stop Read"),
                onPressed: _port == null
                    ? null
                    : () async {
                        if (_port == null) {
                          return;
                        }
                        await _port.write(Uint8List.fromList(
                            [0x7E, 0x00, 0x01, 0x01, 0x01, 0xAB, 0xCD]));
                      },
              ),
              RaisedButton(
                child: Text("LED Off"),
                onPressed: _port == null
                    ? null
                    : () async {
                        if (_port == null) {
                          return;
                        }
                        await _port.write(Uint8List.fromList(
                            [0x7E, 0x00, 0x03, 0x01, 0x01, 0xAB, 0xCD]));
                      },
              ),
              RaisedButton(
                child: Text("LED White"),
                onPressed: _port == null
                    ? null
                    : () async {
                        if (_port == null) {
                          return;
                        }
                        await _port.write(Uint8List.fromList(
                            [0x7E, 0x00, 0x03, 0x01, 0x00, 0xAB, 0xCD]));
                      },
              ),
              RaisedButton(
                child: Text("LED Red"),
                onPressed: _port == null
                    ? null
                    : () async {
                        if (_port == null) {
                          return;
                        }
                        await _port.write(Uint8List.fromList(
                            [0x7E, 0x00, 0x03, 0x01, 0x02, 0xAB, 0xCD]));
                      },
              ),
              RaisedButton(
                child: Text("LED Cyan"),
                onPressed: _port == null
                    ? null
                    : () async {
                        if (_port == null) {
                          return;
                        }
                        await _port.write(Uint8List.fromList(
                            [0x7E, 0x00, 0x03, 0x01, 0x04, 0xAB, 0xCD]));
                      },
              ),
              RaisedButton(
                child: Text("LED Magenta"),
                onPressed: _port == null
                    ? null
                    : () async {
                        if (_port == null) {
                          return;
                        }
                        await _port.write(Uint8List.fromList(
                            [0x7E, 0x00, 0x03, 0x01, 0x05, 0xAB, 0xCD]));
                      },
              ),
              RaisedButton(
                child: Text("LED Green"),
                onPressed: _port == null
                    ? null
                    : () async {
                        if (_port == null) {
                          return;
                        }
                        await _port.write(Uint8List.fromList(
                            [0x7E, 0x00, 0x03, 0x01, 0x06, 0xAB, 0xCD]));
                      },
              ),
              RaisedButton(
                child: Text("LED Blue"),
                onPressed: _port == null
                    ? null
                    : () async {
                        if (_port == null) {
                          return;
                        }
                        await _port.write(Uint8List.fromList(
                            [0x7E, 0x00, 0x03, 0x01, 0x07, 0xAB, 0xCD]));
                      },
              ),
              RaisedButton(
                child: Text("LED Yellow"),
                onPressed: _port == null
                    ? null
                    : () async {
                        if (_port == null) {
                          return;
                        }
                        await _port.write(Uint8List.fromList(
                            [0x7E, 0x00, 0x03, 0x01, 0x03, 0xAB, 0xCD]));
                      },
              ),
            ],
          ),
          Text("Read result", style: Theme.of(context).textTheme.title),
          Text(_serialData),
        ]),
      ),
    ));
  }
}
