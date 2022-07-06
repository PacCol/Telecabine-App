import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:telecabine/home.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  static Route<dynamic> route() {
    return CupertinoPageRoute(
      builder: (BuildContext context) {
        return const SettingsPage();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Paramètres',
      theme: ThemeData(
        fontFamily: 'Montserrat',
      ),
      home: const Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(68),
          child: MySettingsAppBar(),
        ),
        body: Center(
          child: MyStatelessWidget(),
        ),
      ),
    );
  }
}

class MySettingsAppBar extends StatelessWidget {
  const MySettingsAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        'Télécabine',
        style: TextStyle(
          color: Colors.black54,
          fontWeight: FontWeight.w600,
          fontSize: 19,
        ),
      ),
      toolbarHeight: 70,
      backgroundColor: Colors.white,
      actions: <Widget>[
        Container(
          margin: const EdgeInsets.only(left: 9, right: 9),
          child: IconButton(
            icon: const Icon(
              Icons.undo,
              color: Colors.black54,
            ),
            iconSize: 30,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HomePage())),
          ),
        ),
      ],
    );
  }
}

class MyStatelessWidget extends StatelessWidget {
  const MyStatelessWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(left: 30, top: 32, bottom: 44),
          child: const Text(
            'Paramètres',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 21,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 30, right: 30),
          child: const Text(
            "Rien à afficher pour le moment...",
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}