import 'package:flutter/material.dart';
import 'scanner_debug.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('扫码器设置'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ScannerDebug()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.vpn_key),
            title: Text('密钥设置'),
          ),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('关于'),
          ),
        ],
      ),
    );
  }
}
