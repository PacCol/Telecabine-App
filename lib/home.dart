import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:telecabine/settings.dart';
import 'package:telecabine/sse.dart';

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

  void startSse() {
    final myStream = Sse.connect(
      uri: Uri.parse('http://192.168.1.20/listen'),
      closeOnError: true,
      withCredentials: false,
    ).stream;

    myStream.listen((event) {
      debugPrint('Received: $event');
      _currentSpeed = double.parse(event.split(",")[0].split("=")[1]);
      if (event.split(",")[1].split("=")[1] == "enabled") {
        _lightsEnabled = true;
      } else {
        _lightsEnabled = false;
      }
      showStatus();
    });
  }

  Future<http.Response> pingServer() {
    return http.post(
      Uri.parse('http://192.168.1.20/api/status'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: null,
    );
  }

  Future<http.Response> setSpeed(newSpeed) {
    return http.post(
      Uri.parse('http://192.168.1.20/api/speed'),
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
      Uri.parse('http://192.168.1.20/api/enablelights'),
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
        debugPrint("ERROR");
      }
    }
    if (enableLights != null) {
      _lightsEnabled = enableLights;
      try {
        await setLightsStatus(enableLights);
      } catch(e) {
        debugPrint("ERROR");
      }
    }

    debugPrint("SPEED: $_currentSpeed");
    debugPrint("LIGHTS: $_lightsEnabled");

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

  @override
  void initState() {
    super.initState();
    startSse();
    pingServer();
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
                      Navigator.of(context).push(SettingsPage.route()),
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

/*class MyAppBar extends StatelessWidget {
  const MyAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ;
  }
}

class MyContent extends StatelessWidget {
  const MyContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(left: 30, top: 32, bottom: 44),
            child: const Text(
              'Accueil',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 30),
            child: const Text(
              'À l\'arrêt',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 30, top: 24, bottom: 10),
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
                    debugPrint('Moins vite');
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
                ElevatedButton.icon(
                  onPressed: () {
                    debugPrint('Plus vite');
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
            child: const SpeedSlider(),
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
          Container(
              margin: const EdgeInsets.only(left: 30, right: 30),
              padding: const EdgeInsets.only(left: 14, right: 5),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              height: 46,
              child: Row(children: [
                const Text(
                  'Lumières',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                Spacer(),
                CupertinoSwitch(
                  activeColor: Colors.blue,
                  value: _switchValue,
                  onChanged: (value) {
                    setState(() {
                      _switchValue = value;
                    });
                  },
                ),
              ])),
        ],
      ),
    );
  }
}

class SpeedSlider extends StatefulWidget {
  const SpeedSlider({Key? key}) : super(key: key);

  @override
  State<SpeedSlider> createState() => _SpeedSliderState();
}

class _SpeedSliderState extends State<SpeedSlider> {

  double _currentSliderValue = 0;
  Color _currentSliderColor = Colors.blue;
  Color _currentSliderBackColor = Colors.blue.shade100;

  @override //
  Widget build(BuildContext context) {
    return Slider(
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
          debugPrint("Selected");
        });
      },
    );
  }
}

class LightsSwitch extends StatefulWidget {
  const LightsSwitch({Key? key}) : super(key: key);

  @override
  State<LightsSwitch> createState() => _LightsSwitchState();
}

class _LightsSwitchState extends State<LightsSwitch> {
  bool _switchValue = false;

  void _showLightsEnabled(bool newValue) {
    setState(() {
      _switchValue = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ;
  }
}*/
