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
import 'package:scouting_6907/login.dart';
import 'package:scouting_6907/models.dart';
import 'package:scouting_6907/repository.dart';
import 'package:scouting_6907/utils.dart';
import 'package:scouting_6907/widgets.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ScountingApp());
}

class ScountingApp extends StatelessWidget {
  const ScountingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Team 6907',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(title: 'Team 6907 Scouting'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// Since Dart does not support object cloning,
  /// we store fields in JSON format and create instances of SCData only when needed
  /// so that we can have multiple instances of the same SCData
  List fields_json = [];
  SCData currentField = SCData("Select Table", "选择表", false, false, false, []);

  int currentSelectedLap = 0;

  /// Storage for all data involved during scouting
  /// The index of the list is the lap ID
  List<SCData> userData = [];

  final StopWatchTimer _stopWatchTimer =
      StopWatchTimer(mode: StopWatchMode.countUp);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() async {
    super.dispose();
    await _stopWatchTimer.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!ScoutingRepository.getInstance().isUserInitialized) {
      WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
        LoginDialog.showLoginDialog(context).then((value) {
          loadData();
        });
      });
    } else {
      loadData();
    }
  }

  void loadData() async {
    fields_json =
        (await ScoutingRepository.getInstance().loadInGameJson()) ?? [];
    setState(() {
      currentField = SCData.fromJson(fields_json.first);
    });
    //await ScoutingRepository.getInstance().loadGameSpec("6907", "qm16");
  }

  void saveData() {
    if (currentSelectedLap == userData.length) {
      userData.add(currentField);
    } else {
      userData[currentSelectedLap] = currentField;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          TextButton(
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    builder: (context) => BottomSheet(
                        onClosing: () {},
                        builder: (context) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: fields_json
                                .map((e) => SCData.fromJson(e))
                                .map((e) => ListTile(
                                      title: Text(e.ItemChn),
                                      onTap: () {
                                        Navigator.pop(context);
                                        setState(() {
                                          currentField = e;
                                        });
                                      },
                                    ))
                                .toList(),
                          );
                        }));
              },
              child: Text(
                currentField.ItemChn,
                style: Theme.of(context).primaryTextTheme.bodyText1,
              ))
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: StopwatchTimeline(
                  timer: _stopWatchTimer,
                  onSelectLap: (id) {
                    saveData();
                    setState(
                      () {
                        currentSelectedLap = id;
                        if (id < userData.length) {
                          currentField = userData[id];
                        }
                      },
                    );
                  },
                  onReset: () {
                    setState(() {
                      currentSelectedLap = 0;
                      userData.clear();
                      currentField = SCData.fromJson(fields_json.first);
                    });
                  },
                  onCreateLap: (tlduration) {
                    currentField.startTime = tlduration.start;
                    currentField.endTime = tlduration.end;
                  }),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child:
                  DynamicScoutingOptionsWidget(fields: currentField.Properties),
            ),
          ]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          saveData();
          print(jsonEncode(userData));
          Noticing.showAlert(context, jsonEncode(userData), "Data");
        },
        tooltip: '保存',
        child: const Icon(Icons.save),
      ),
    );
  }
}
