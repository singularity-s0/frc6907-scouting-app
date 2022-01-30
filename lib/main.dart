/*
 *     Copyright (C) 2021 singularity-s0
 *
 *     This program is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     This program is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:scouting_6907/models.dart';
import 'package:scouting_6907/widgets.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

void main() {
  runApp(const ScountingApp());
}

class ScountingApp extends StatelessWidget {
  const ScountingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Team 6907',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Team 6907 Scouting'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late SCData fields;

  final StopWatchTimer _stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countUp,
    onChange: (value) => print('onChange $value'),
    onChangeRawSecond: (value) => print('onChangeRawSecond $value'),
    onChangeRawMinute: (value) => print('onChangeRawMinute $value'),
  );

  @override
  void initState() {
    super.initState();
    fields = SCData.fromJson(jsonDecode(string));
  }

  @override
  void dispose() async {
    super.dispose();
    await _stopWatchTimer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(children: [
            StreamBuilder<int>(
                stream: _stopWatchTimer.rawTime,
                initialData: _stopWatchTimer.rawTime.value,
                builder: (context, snap) {
                  final value = snap.data!;
                  final displayTime =
                      StopWatchTimer.getDisplayTime(value, hours: false);
                  return Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          displayTime,
                          style: const TextStyle(
                              fontSize: 40,
                              fontFamily: 'Helvetica',
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          value.toString(),
                          style: const TextStyle(
                              fontSize: 16,
                              fontFamily: 'Helvetica',
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ],
                  );
                }),
            DynamicScoutingOptionsWidget(fields: fields.properties),
          ]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print(jsonEncode(fields));
        },
        tooltip: '保存',
        child: const Icon(Icons.save),
      ),
    );
  }
}

const string = r"""{
  "itemChn": "Test",
  "itemEng": "test",
  "auto": 0,
  "teleop": 0,
  "endgame": 0,
  "properties": [
    {
      "nameCn": "Option1",
      "nameEn": "Option1",
      "root": {
        "name": "Option1-Name",
        "type": "option",
        "sons": [
          {
            "name": "Button 1",
            "type": "null",
            "sons": []
          },
          {
            "name": "Button 2",
            "type": "null",
            "sons": []
          },
          {
            "name": "Button 3",
            "type": "null",
            "sons": []
          },
          {
            "name": "Button 4",
            "type": "null",
            "sons": []
          }
        ]
      }
    },
    {
      "nameCn": "TextField",
      "nameEn": "TextField",
      "root": {
        "name": "TextField-Double",
        "type": "double",
        "sons": []
      }
    },
    {
    "nameCn": "Option-With-Child",
    "nameEn": "Option-With-Child",
    "root": {
      "name": "Option-With-Child-1",
      "type": "option",
      "sons": [
        {
          "name": "first",
          "type": "null",
          "sons": [
            {
              "name": "Success",
              "type": "boolean",
              "sons": []
            },
            {
              "name": "Fail",
              "type": "boolean",
              "sons": []
            }
          ]
        },
        {
          "name": "Second",
          "type": "null",
          "sons": []
        }
      ]
    }
  }
]
}
    """;
