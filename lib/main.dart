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

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:scouting_6907/login.dart';
import 'package:scouting_6907/models.dart';
import 'package:scouting_6907/repository.dart';
import 'package:scouting_6907/utils.dart';
import 'package:scouting_6907/widgets.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = SelfSignedCertHttpOverrides();
  runApp(const ScountingApp());
}

class ScountingApp extends StatelessWidget {
  const ScountingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Team 6907',
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF182181), brightness: Brightness.light),
      ),
      darkTheme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF182181), brightness: Brightness.dark),
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
  late String title;

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
    title = widget.title;
    unawaited(initialize());
  }

  Future<void> initialize() async {
    if (!ScoutingRepository.getInstance().isUserInitialized) {
      WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
        await LoginDialog.showLoginDialog(context);
        await loadData();
      });
    } else {
      await loadData();
    }
  }

  @override
  void dispose() async {
    super.dispose();
    await _stopWatchTimer.dispose();
  }

  Future<void> loadData() async {
    fields_json =
        (await ScoutingRepository.getInstance().loadInGameJson()) ?? [];
    setState(() {
      currentField = SCData.fromJson(fields_json.first);
    });
  }

  void saveData() {
    if (currentSelectedLap == userData.length) {
      userData.add(currentField);
    } else {
      userData[currentSelectedLap] = currentField;
    }
  }

  void showSCDataSelector() {
    bool isCurrentPhase(SCData scData) {
      final phase = MatchPhase.fromTime(_stopWatchTimer.rawTime.value);
      switch (phase) {
        case MatchPhase.auto:
          return scData.Auto;
        case MatchPhase.teleop:
          return scData.Teleop;
        case MatchPhase.endgame:
          return scData.Endgame;
      }
      return false;
    }

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
                          enabled: isCurrentPhase(e),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          TextButton(
              onPressed: showSCDataSelector,
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
                  showSCDataSelector();
                },
                onTimerStop: (tlduration) {
                  currentField.startTime = tlduration.start;
                  currentField.endTime = tlduration.end;
                  saveData();
                },
              ),
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
        onPressed: () async {
          saveData();
          if (await Noticing.showConfirmationDialog(
                  context, "数据将会上传到服务器", "提交数据") ==
              true) {
            try {
              final eval = await Noticing.showInputDialog(context, "评价本场比赛");
              if (eval?.isNotEmpty == true) {
                await ScoutingRepository.getInstance().postGameSpec(
                    6907,
                    "qm16",
                    jsonEncode(userData),
                    eval!); // TODO: Ask user for input
                Noticing.showAlert(context, "数据已经上传", "提交成功");
              } else {
                Noticing.showAlert(context, "比赛评价不能为空", "无法提交");
                return;
              }
            } catch (error) {
              if (error is DioError && error.response?.data != null) {
                Noticing.showAlert(
                    context, (error.response?.data).toString(), error.message);
              } else {
                if (error is DioError) {
                  Noticing.showAlert(context, error.message, "错误");
                } else {
                  Noticing.showAlert(context, error.toString(), "错误");
                }
              }
            }
          }
        },
        tooltip: '保存',
        child: const Icon(Icons.save),
      ),
    );
  }
}
