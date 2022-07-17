import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:telecabine/main.dart';
import 'package:telecabine/settings.dart';

bool _networkErrorShown = false;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  double _currentSpeed = 0;
  bool _lightsEnabled = false;

  String _currentSpeedStr = "À l'arrêt";

  double _currentSliderValue = 0;
  Color _currentSliderColor = Colors.blue;
  Color _currentSliderBackColor = Colors.blue.shade100;

  bool _lightSwitchValue = false;

  late http.Client _client;

  void startSse() async {
    _client = http.Client();

    var request = http.Request("GET", Uri.parse("http://$serverUri/listen"));
    request.headers["Cache-Control"] = "no-cache";
    request.headers["Accept"] = "text/event-stream";

    void Wesh() {
      debugPrint("GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG");
    }

    Future<http.StreamedResponse> response = _client.send(request).catchError(Wesh);

    response.asStream().listen((streamedResponse) {
        streamedResponse.stream.listen((data) {
          _currentSpeed =
              double.parse(utf8.decode(data).split(",")[0].split("=")[1]);
          if (utf8.decode(data).split(",")[1].split("=")[1] == "enabled") {
            _lightsEnabled = true;
          } else if (utf8.decode(data).split(",")[1].split("=")[1] == "disabled") {
            _lightsEnabled = false;
          }
          debugPrint("============================================================ " + utf8.decode(data));
          showStatus();
        });
    });
  }

  Future<void> pingServer() async {
    try {
      await http.post(
        Uri.parse('http://$serverUri/api/status'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: null,
      );
    } catch (e) {
      networkError();
    }
  }

  Future<http.Response> setSpeed(newSpeed) {
    return http.post(
      Uri.parse('http://$serverUri/api/speed'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, int>{
        'speed': newSpeed.round(),
      }),
    );
  }

  Future<http.Response> setLightsStatus(enableLights) {
    return http.post(
      Uri.parse('http://$serverUri/api/enablelights'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, bool>{
        'enable': enableLights,
      }),
    );
  }

  Future<void> setStatus(newSpeed, enableLights) async {
    if (newSpeed != null) {
      _currentSpeed = newSpeed;
      try {
        await setSpeed(newSpeed);
      } catch(e) {
        networkError();
      }
    }
    if (enableLights != null) {
      _lightsEnabled = enableLights;
      try {
        await setLightsStatus(enableLights);
      } catch(e) {
        networkError();
      }
    }
    showStatus();
  }

  void showStatus() {
    setState(() {
      if (_currentSpeed == 0) {
        _currentSpeedStr = "À l'arrêt";
      } else {
        _currentSpeedStr = 'Vitesse ${_currentSpeed.round()}';
      }
      _currentSliderValue = _currentSpeed;
      if (_currentSliderValue == 0) {
        _currentSliderColor = Colors.blue;
        _currentSliderBackColor = Colors.blue.shade100;
      } else if (_currentSliderValue <= 2) {
        _currentSliderColor = Colors.red;
        _currentSliderBackColor = Colors.red.shade100;
      } else if (_currentSliderValue <= 5) {
        _currentSliderColor = Colors.orange;
        _currentSliderBackColor = Colors.orange.shade100;
      } else if (_currentSliderValue <= 9) {
        _currentSliderColor = Colors.green;
        _currentSliderBackColor = Colors.green.shade100;
      } else {
        _currentSliderColor = Colors.orange;
        _currentSliderBackColor = Colors.orange.shade100;
      }
      _lightSwitchValue = _lightsEnabled;
    });
  }

  void networkError() {
    if (_networkErrorShown) {
      return;
    }
    _networkErrorShown = true;
    showDialog(
      barrierDismissible: false,
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
          Container(
            margin: const EdgeInsets.only(right: 12, left: 12, bottom: 7),
            child: Row(children: [
              ElevatedButton.icon(
                onPressed: () {
                  _networkErrorShown = false;
                  // to remove
                  Navigator.of(context).pop();
                  //SystemNavigator.pop();
                  //exit(0);
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                  onPrimary: Colors.white,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, top: 10, bottom: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                label: const Text(
                  'Fermer',
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
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(SettingsPage.route()).then((value) {
                    startSse();
                    pingServer();
                  });
                  _networkErrorShown = false;
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
            ]),
          ),
        ],
      ),
    );
  }

  Future<void> getSavedUri() async {
    final prefs = await SharedPreferences.getInstance();
    serverUri = prefs.getString('serverUri');
    if (serverUri == null || serverUri == "") {
      prefs.setString('serverUri', 'telecabine.local');
      serverUri = 'telecabine.local';
    }
  }

  void startNetwork() async {
    await getSavedUri();
    startSse();
    pingServer();
  }

  @override
  void initState() {
    super.initState();
    startNetwork();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Télécabine',
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
                padding: const EdgeInsets.only(top: 9, bottom: 9),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (_currentSpeed != 0) {
                        setStatus(0.0, null);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red[100],
                      onPrimary: Colors.red,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.only(
                          left: 19, right: 19, top: 12, bottom: 12),
                      shape: RoundedRectangleBorder(
                          //to set border radius to button
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    label: const Text(
                      'Arrêt',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    icon: const Icon(
                      Icons.pan_tool,
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
                  onPressed: () =>
                      Navigator.of(context).push(SettingsPage.route()).then((value) {
                        startSse();
                        pingServer();
                      }),
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
                  margin: const EdgeInsets.only(left: 30, top: 32, bottom: 44),
                  child: const Text(
                    'Accueil',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 21,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 30, right: 30),
                  child: const Text(
                    "Le temps de fonctionnement n'est pas encore disponible dans cette version.",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 30, top: 26, bottom: 10),
                  child: const Text(
                    'Vitesse',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                    ),
                  ),
                ),
                Container(
                    margin: const EdgeInsets.only(left: 30, right: 30),
                    child: Row(children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          if (_currentSpeed != 0) {
                            setStatus(_currentSpeed - 1, null);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.blue,
                          onPrimary: Colors.white,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.only(
                              left: 24, right: 16, top: 10, bottom: 10),
                          shape: RoundedRectangleBorder(
                              //to set border radius to button
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        label: const Text(''),
                        icon: const Icon(
                          Icons.arrow_back,
                          size: 23,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _currentSpeedStr,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (_currentSpeed != 10) {
                            setStatus(_currentSpeed + 1, null);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.blue,
                          onPrimary: Colors.white,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.only(
                              left: 24, right: 16, top: 10, bottom: 10),
                          shape: RoundedRectangleBorder(
                              //to set border radius to button
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        label: const Text(''),
                        icon: const Icon(
                          Icons.arrow_forward,
                          size: 23,
                        ),
                      ),
                    ])),
                Container(
                  margin: const EdgeInsets.only(left: 14, top: 5, right: 14),
                  child: Slider(
                    value: _currentSliderValue,
                    max: 10,
                    divisions: 10,
                    activeColor: _currentSliderColor,
                    inactiveColor: _currentSliderBackColor,
                    label: _currentSliderValue.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        _currentSliderValue = value;
                        if (_currentSliderValue == 0) {
                          _currentSliderColor = Colors.blue;
                          _currentSliderBackColor = Colors.blue.shade100;
                        } else if (_currentSliderValue <= 2) {
                          _currentSliderColor = Colors.red;
                          _currentSliderBackColor = Colors.red.shade100;
                        } else if (_currentSliderValue <= 5) {
                          _currentSliderColor = Colors.orange;
                          _currentSliderBackColor = Colors.orange.shade100;
                        } else if (_currentSliderValue <= 9) {
                          _currentSliderColor = Colors.green;
                          _currentSliderBackColor = Colors.green.shade100;
                        } else {
                          _currentSliderColor = Colors.orange;
                          _currentSliderBackColor = Colors.orange.shade100;
                        }
                      });
                    },
                    onChangeEnd: (double value) {
                      setState(() {
                        setStatus(value, null);
                      });
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 30, top: 30, bottom: 10),
                  child: const Text(
                    'Lumières',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _lightSwitchValue = !_lightSwitchValue;
                      setStatus(null, _lightSwitchValue);
                    });
                  },
                  child: Container(
                      margin: const EdgeInsets.only(left: 30, right: 30),
                      padding: const EdgeInsets.only(left: 14, right: 5),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                      ),
                      height: 46,
                      child: Row(children: [
                        const Text(
                          'Lumières',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        CupertinoSwitch(
                          activeColor: Colors.blue,
                          value: _lightSwitchValue,
                          onChanged: (value) {
                            setState(() {
                              setStatus(null, value);
                            });
                          },
                        )
                      ])),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}