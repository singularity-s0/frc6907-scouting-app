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
  //HttpOverrides.global = SelfSignedCertHttpOverrides();
  Settings.getInstance().init().then((value) {
    runApp(const ScountingApp());
  });
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
  MatchInfo? matchInfo;

  GlobalKey<FormState> mainFormKey = GlobalKey<FormState>();

  /// Since Dart does not support object cloning,
  /// we store fields in JSON format and create instances of SCData only when needed
  /// so that we can have multiple instances of the same SCData
  List fields_json = [];
  SCData _currentField = SCData("Select Table", "选择表", false, false, false, []);
  SCData _lastField = SCData("Select Table", "选择表", false, false, false, []);

  SCData get currentField => _currentField;
  set currentField(SCData value) {
    // This gets called every time currentfield is parsed from json
    // To keep track of what was the last field
    _currentField = value;
    _lastField = SCData.fromJson(
        jsonDecode(jsonEncode(value))); // FIXME: Hack to clone object
  }

  int currentSelectedLap = 0;

  /// Storage for all data involved during scouting
  /// The index of the list is the lap ID
  List<SCTimelineItem> userData = [];

  final StopWatchTimer _stopWatchTimer =
      StopWatchTimer(mode: StopWatchMode.countUp);

  int get currentTime => _stopWatchTimer.rawTime.value <= MATCH_TIME
      ? _stopWatchTimer.rawTime.value
      : MATCH_TIME;

  @override
  void initState() {
    super.initState();
    title = widget.title;
    unawaited(initialize());
  }

  Future<void> initialize() async {
    if (!ScoutingRepository.getInstance().isUserInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
        await LoginDialog.showLoginDialog(context);
        await loadData();
        if (matchInfo == null) {
          await showMatchStringDialog(context);
        }
      });
    } else {
      await loadData();
      if (matchInfo == null) {
        await showMatchStringDialog(context);
      }
    }
  }

  Future<void> showMatchStringDialog(BuildContext context,
      {bool canDismiss = false}) async {
    final info =
        await Noticing.showMatchStringInput(context, canDismiss: canDismiss);
    if (info != null) matchInfo = info;
    setState(() {
      title = "${matchInfo?.team} ${matchInfo?.match}";
    });
  }

  @override
  void dispose() async {
    super.dispose();
    await _stopWatchTimer.dispose();
  }

  SCData getFirstLegalField() {
    try {
      return fields_json
          .map((e) => SCData.fromJson(e))
          .firstWhere((element) => isCurrentPhase(element));
    } catch (e) {
      return SCData.fromJson(fields_json.first);
    }
  }

  Future<void> loadData() async {
    fields_json =
        (await ScoutingRepository.getInstance().loadInGameJson()) ?? [];
    setState(() {
      currentField = getFirstLegalField();
    });
  }

  void saveData() {
    if (userData.length > currentSelectedLap) {
      userData[currentSelectedLap].data = currentField;
    } else {
      Noticing.showAlert(context, "请选择时间段", "错误");
    }
  }

  bool isCurrentPhase(SCData scData) {
    final phase =
        MatchPhase.fromTime(currentSelectedLapStartTime ?? currentTime);
    switch (phase) {
      case MatchPhase.auto:
        return scData.Auto;
      case MatchPhase.teleop:
        return scData.Teleop;
      case MatchPhase.endgame:
        return scData.Endgame;
    }
    return true;
  }

  void showSCDataSelector() {
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

  int? get currentSelectedLapStartTime {
    if (currentSelectedLap >= userData.length) {
      return null;
    }
    return userData[currentSelectedLap].startTime;
  }

  void confirmFormData() {
    if (mainFormKey.currentState?.validate() == true) {
      saveData();
      if (currentSelectedLap + 1 < userData.length) {
        setState(() {
          currentSelectedLap++;
          if (userData[currentSelectedLap].data != null) {
            currentField = userData[currentSelectedLap].data!;
          } else {
            if (isCurrentPhase(currentField)) {
              currentField = _lastField;
            } else {
              currentField = fields_json
                  .map((e) => SCData.fromJson(e))
                  .firstWhere((element) => isCurrentPhase(element));
            }
          }
        });
      } else if (!_stopWatchTimer.isRunning) {
        // Fix no setstate called after timer is stopped
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          child: Text(title),
          onTap: () {
            showMatchStringDialog(context, canDismiss: true);
          },
        ),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Settings.getInstance().preferences.getBool("showname") ==
                        true
                    ? const Text("隐藏项目名称")
                    : const Text("显示项目名称"),
                onTap: () {
                  setState(() {
                    Settings.getInstance().preferences.setBool(
                        "showname",
                        !(Settings.getInstance()
                                .preferences
                                .getBool("showname") ??
                            false));
                  });
                },
              ),
              PopupMenuItem(
                child: const Text("退出登录"),
                onTap: () {
                  ScoutingRepository.getInstance().logout();
                  matchInfo = null;
                  currentSelectedLap = 0;
                  userData.clear();
                  currentField = getFirstLegalField();
                  initialize();
                },
              ),
              PopupMenuItem(
                child: const Text("关于本应用"),
                onTap: () async {
                  await Noticing.showAbout(context);
                },
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 16, left: 16, right: 16, bottom: 4),
              child: StopwatchTimeline(
                timer: _stopWatchTimer,
                selectedTimelineDuration: currentSelectedLap,
                onSelectLap: (id) {
                  saveData();
                  setState(
                    () {
                      currentSelectedLap = id;
                      if (userData[id].data != null) {
                        currentField = userData[id].data!;
                      }
                    },
                  );
                },
                onReset: () async {
                  await showMatchStringDialog(context, canDismiss: true);
                  setState(() {
                    currentSelectedLap = 0;
                    userData.clear();
                    currentField = getFirstLegalField();
                  });
                },
                onLapCreationCompleted: (tlduration) {
                  saveData();
                  userData.last.startTime = tlduration.start;
                  userData.last.endTime = tlduration.end;
                },
                onLapCreationStarted: (newStartTime) {
                  userData.add(SCTimelineItem.empty());
                  userData.last.startTime = newStartTime;
                  setState(() {});
                },
                onLapCreationAborted: (newStartTime) {
                  if (currentSelectedLap >= userData.length) {
                    currentSelectedLap--;
                  }
                  userData.removeLast();
                },
                onFinalLapCreationAborted: () {
                  setState(() {
                    if (userData.isEmpty) {
                      currentSelectedLap = 0;
                      userData.clear();
                      currentField = getFirstLegalField();
                    } else if (currentSelectedLap >= userData.length) {
                      currentSelectedLap--;
                    }
                  });
                },
                onTimerStop: () {
                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                    // Enable Submit button
                    setState(() {});
                  });
                },
              ),
            ),
            const Divider(height: 0),
            Wrap(
              children: fields_json
                  .map((e) => SCData.fromJson(e))
                  .map((e) => TextButton(
                        child: Text(e.ItemChn),
                        onPressed: isCurrentPhase(e)
                            ? () {
                                setState(() {
                                  currentField = e;
                                });
                              }
                            : null,
                      ))
                  .toList(),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16),
                      child: ScoutingFieldsForm(
                        fields: currentField.Properties,
                        formKey: mainFormKey,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: confirmFormData,
                          child: const Text("确认"),
                        ),
                        ElevatedButton(
                          onPressed: (currentTime >= MATCH_TIME &&
                                  userData.isNotEmpty &&
                                  userData.last.endTime != null &&
                                  userData.last.data != null)
                              ? () async {
                                  if (mainFormKey.currentState?.validate() ==
                                          true &&
                                      await Noticing.showConfirmationDialog(
                                              context, "数据将会上传到服务器", "提交数据") ==
                                          true) {
                                    confirmFormData();
                                    try {
                                      final eval =
                                          await Noticing.showInputDialog(
                                              context, "评价本场比赛",
                                              maxLength: 250);
                                      if (eval?.isNotEmpty == true) {
                                        await ScoutingRepository.getInstance()
                                            .postGameSpec(
                                                matchInfo!.team,
                                                matchInfo!.match,
                                                userData,
                                                eval!);
                                        Noticing.showAlert(
                                            context, "数据已经上传", "提交成功");
                                      } else {
                                        Noticing.showAlert(
                                            context, "比赛评价不能为空", "无法提交");
                                        return;
                                      }
                                    } catch (error) {
                                      if (error is DioError &&
                                          error.response?.data != null) {
                                        Noticing.showAlert(
                                            context,
                                            (error.response?.data).toString(),
                                            error.message);
                                      } else {
                                        if (error is DioError) {
                                          Noticing.showAlert(
                                              context, error.message, "错误");
                                        } else {
                                          Noticing.showAlert(
                                              context, error.toString(), "错误");
                                        }
                                      }
                                    }
                                  }
                                }
                              : null,
                          child: const Text("提交"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
