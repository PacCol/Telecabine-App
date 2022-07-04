import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Télécabine',
      theme: ThemeData(
          fontFamily: 'Montserrat',
      ),
      home: const Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(68),
            child: MyAppBar(),
        ),
        body: Center(
          child: MyStatelessWidget(),
        ),
      ),
    );
  }
}

class MyAppBar extends StatelessWidget {
  const MyAppBar({Key? key}) : super(key: key);

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
          margin: const EdgeInsets.only(top: 11, bottom: 11),
          child: Directionality(
              textDirection: TextDirection.rtl,
              child: ElevatedButton.icon(
                onPressed: () {
                  debugPrint('Arrêter la télécabine');
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.red[100],
                  onPrimary: Colors.red,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.only(left: 19, right: 19),
                  shape: RoundedRectangleBorder( //to set border radius to button
                      borderRadius: BorderRadius.circular(8)
                  ),
                ),
                label: const Text(
                  'Arrêt',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                icon: const Icon(Icons.pan_tool,
                  size: 17,
                ),
              ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 9, right: 9),
          child: IconButton(
            icon: const Icon(
              Icons.settings,
              color: Colors.black54,
            ),
            iconSize: 30,
            onPressed: () {
              debugPrint("Ouvrir les paramètres");
            },
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
          margin: const EdgeInsets.only(left: 20, top: 24),
          height: 50,
          child: const Text(
            'Accueil',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 22,
            ),
          ),
        ),
        Container(
          height: 50,
          color: Colors.amber[500],
          child: const Center(child: Text('Entry B')),
        ),
        Container(
          height: 50,
          color: Colors.amber[100],
          child: const Center(child: Text('Entry C')),
        ),
      ],
    );
  }
}