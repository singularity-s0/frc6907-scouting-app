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
  List<SCData> fields = [];
  SCData currentField = SCData("Select Table", "选择表", false, false, false, []);

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
    fields = (await ScoutingRepository.getInstance().loadInGameData()) ?? [];
    setState(() {
      currentField = fields.first;
    });
    //await ScoutingRepository.getInstance().loadGameSpec("6907", "qm16");
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
                            children: fields
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
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: StopwatchTimeline(timer: _stopWatchTimer),
            ),
            DynamicScoutingOptionsWidget(fields: currentField.Properties),
          ]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          loadData();
        },
        tooltip: '保存',
        child: const Icon(Icons.save),
      ),
    );
  }
}
