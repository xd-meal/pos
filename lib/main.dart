import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock/wakelock.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'clock_button.dart';
import 'settings.dart';
import 'dart:typed_data';
import 'dart:async';
import 'package:usb_serial/usb_serial.dart';
import 'package:usb_serial/transaction.dart';

void main() => runApp(Loader());

class Loader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Wakelock.enable();
    return MaterialApp(
      home: MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int tapCount = 0;
  String authKey = '';
  UsbPort _port;
  String _status = "就绪";
  String _serialData = "";
  StreamSubscription<String> _subscription;
  Transaction<String> _transaction;
  int _deviceId;

  RegExp keySetter = new RegExp(r"UG(.*)XG");
  RegExp tokenReg = new RegExp(r"XY(.*)XZ");

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
        _status = "与扫码器断开连接";
      });
      return true;
    }

    _port = await device.create();
    if (!await _port.open()) {
      setState(() {
        _status = "启动扫码器失败";
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
      if (keySetter.hasMatch(line)) {
        String key = line.substring(2, line.length - 2);
        setConfigKey(key);
      } else if (tokenReg.hasMatch(line)) {
        String token = line.substring(2, line.length - 2);
        // TODO:Send ajax from here
        _serialData = '此处应有取参请求发出(叹气';
      }
      setState(() {
        // _serialData = line;
      });
    });

    setState(() {
      _status = "已连接到扫码器";
    });
    return true;
  }

  void _getPorts() async {
    List<UsbDevice> devices = await UsbSerial.listDevices();
    _connectTo(devices[0]);

    setState(() {});
  }

  void fetchConfigKeys() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    authKey = (prefs.getInt('authKey') ?? '');
  }

  void setConfigKey(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    authKey = key;
    await prefs.setString('authKey', key);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("成功设置参数"),
          content: new Text("已设置服务器通讯校验码"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("关闭"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchConfigKeys();
    SystemChrome.setEnabledSystemUIOverlays([]);
    UsbSerial.usbEventStream.listen((UsbEvent event) {
      _getPorts();
    });

    _getPorts();
  }

  @override
  void dispose() {
    _connectTo(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Color(0xFF00000000),
      body: Container(
        constraints: BoxConstraints.expand(
          height: Theme.of(context).textTheme.display1.height,
        ),
        padding: EdgeInsets.only(bottom: 50),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Container(),
            ),
            Text(
              _serialData,
              style: TextStyle(fontSize: 40, color: Colors.white),
            ),
            Expanded(
              child: Container(),
            ),
            Text(
              // _status,
              authKey,
              style: TextStyle(fontSize: 40, color: Colors.white),
            ),
            ClockButton(
              label: _serialData,
              buttonType: ButtonType.FlatButton,
              color: Colors.black,
              activeTextStyle: TextStyle(color: Colors.white, fontSize: 60),
              disabledTextStyle: TextStyle(color: Colors.white, fontSize: 60),
              onPressed: () {
                this.tapCount++;
                if (this.tapCount > 0) {
                  this.tapCount = 0;
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SettingsPage()));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
