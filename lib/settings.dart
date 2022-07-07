import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:telecabine/main.dart';
import 'package:telecabine/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  static Route<dynamic> route() {
    return CupertinoPageRoute(
      builder: (BuildContext context) {
        return const SettingsPage();
      },
    );
  }

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  final TextEditingController _textEditingController = TextEditingController();

  String _cpuTempStr = "Température du CPU: -";

  String _version = "-";
  String _buildNumber = "-";

  void saveIPAdress() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('serverUri', _textEditingController.text);
    serverUri = prefs.getString('serverUri');
  }
  
  void displaySettingsOnDeviceScreen() async {
    try {
      await http.post(
        Uri.parse('http://$serverUri/api/settings'),
      );
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text(
            "Paramètres ouverts",
            style: TextStyle(
              fontFamily: "Montserrat",
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            "Les paramètres ont bien été ouverts sur l'écran de votre appareil.",
            style: TextStyle(
              fontFamily: "Montserrat",
            ),
          ),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          actions: <Widget>[
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                onPrimary: Colors.white,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 10, bottom: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              label: const Text(
                "Fermer",
                style: TextStyle(
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.w600,
                ),
              ),
              icon: const Icon(
                Icons.close,
                size: 20,
              ),
            ),
          ],
        ),
      );
    }
    catch(e) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text(
            "Erreur réseau",
            style: TextStyle(
              fontFamily: "Montserrat",
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            "Une erreur réseau s'est produite, veuillez réessayer plus tard...",
            style: TextStyle(
              fontFamily: "Montserrat",
            ),
          ),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          actions: <Widget>[
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).push(SettingsPage.route());
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                onPrimary: Colors.white,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 10, bottom: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              label: const Text(
                "Paramètres",
                style: TextStyle(
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.w600,
                ),
              ),
              icon: const Icon(
                Icons.settings,
                size: 20,
              ),
            ),
          ],
        ),
      );
      return;
    }
  }

  void getCPUTemp() async {
    try {
      http.Response response = await http.get(Uri.parse('http://$serverUri/api/cpuTemp'));
      setState(() {
        _cpuTempStr = "Température du CPU: ${response.body}";
      });
    } catch(e) {
      setState(() {
        _cpuTempStr = "Température du CPU: ?";
      });
    }
  }

  void displaySettings() async {
    getCPUTemp();
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      setState(() {
        _version = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    displaySettings();
  }

  void setIPAdress() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          "Définir l'adresse",
          style: TextStyle(
            fontFamily: "Montserrat",
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          "Vous pouvez entrer ici soit l'adresse ip locale de votre boîtier, soit le nom d'hôte du boîtier (telecabine.local). Veillez à être connecté au même réseau WiFi que lui.",
          style: TextStyle(
            fontFamily: "Montserrat",
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        actions: <Widget>[
          Container(
            margin: const EdgeInsets.only(left: 12, right: 12, bottom: 18),
            child: TextField(
              controller: _textEditingController,
              obscureText: false,
              decoration: const InputDecoration(
                prefix: Text('http://'),
                suffix: Text('/'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
                labelText: 'ex: http://telecabine.local/',
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 12, bottom: 7),
            child: ElevatedButton.icon(
              onPressed: () {
                saveIPAdress();
                Navigator.of(ctx).pop();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                onPrimary: Colors.white,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 10, bottom: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              label: const Text(
                'Définir',
                style: TextStyle(
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.w600,
                ),
              ),
              icon: const Icon(
                Icons.link,
                size: 20,
              ),
            ),
          ),
        ],
      ),
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
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(68),
          child: AppBar(
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
                  onPressed: () => Navigator.of(context).push(HomePage.route()),
                ),
              ),
            ],
          ),
        ),
        body: Center(
          child: Container(
            color: Colors.white,
            child: ListView(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(left: 30, top: 32, bottom: 24),
                  child: const Text(
                    'Paramètres',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 21,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 30, right: 30, bottom: 4, top: 24),
                  child: const Text(
                    "Hardware",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setIPAdress();
                  },
                  child: Container(
                      margin:
                          const EdgeInsets.only(left: 30, right: 30, top: 6),
                      padding: const EdgeInsets.only(left: 14, right: 5),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                      ),
                      height: 46,
                      child: Row(children: [
                        const Text(
                          'Adresse réseau',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(
                            Icons.link,
                            color: Colors.black54,
                          ),
                          iconSize: 28,
                          splashColor: Colors.transparent,
                          onPressed: () {
                            setIPAdress();
                          },
                        ),
                      ])),
                ),
                GestureDetector(
                  onTap: () {
                    displaySettingsOnDeviceScreen();
                  },
                  child: Container(
                      margin:
                      const EdgeInsets.only(left: 30, right: 30, top: 6),
                      padding: const EdgeInsets.only(left: 14, right: 5),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius:
                        const BorderRadius.all(Radius.circular(10)),
                      ),
                      height: 46,
                      child: Row(children: [
                        const Text(
                          'Ouvrir les paramètres',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(
                            Icons.settings_applications,
                            color: Colors.black54,
                          ),
                          iconSize: 28,
                          splashColor: Colors.transparent,
                          onPressed: () {
                            displaySettingsOnDeviceScreen();
                          },
                        ),
                      ])),
                ),
                GestureDetector(
                  onTap: () {
                    getCPUTemp();
                  },
                  child: Container(
                      margin:
                      const EdgeInsets.only(left: 30, right: 30, top: 6),
                      padding: const EdgeInsets.only(left: 14, right: 5),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius:
                        const BorderRadius.all(Radius.circular(10)),
                      ),
                      height: 46,
                      child: Row(children: [
                        Text(
                          _cpuTempStr,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.black54,
                          ),
                          iconSize: 28,
                          splashColor: Colors.transparent,
                          onPressed: () {
                            getCPUTemp();
                          },
                        ),
                      ])),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 30, right: 30, bottom: 4, top: 24),
                  child: const Text(
                    "Application",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                    margin:
                    const EdgeInsets.only(left: 30, right: 30, top: 6),
                    padding: const EdgeInsets.only(left: 14, right: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius:
                      const BorderRadius.all(Radius.circular(10)),
                    ),
                    height: 46,
                    child: Row(children: [
                      const Text(
                        'Version',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _version,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ])),
                Container(
                    margin:
                    const EdgeInsets.only(left: 30, right: 30, top: 6),
                    padding: const EdgeInsets.only(left: 14, right: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius:
                      const BorderRadius.all(Radius.circular(10)),
                    ),
                    height: 46,
                    child: Row(children: [
                      const Text(
                        'Numéro de build',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _buildNumber,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ])),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
