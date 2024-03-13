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

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:scouting_6907/repository.dart';
import 'package:scouting_6907/utils.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({Key? key, this.arguments}) : super(key: key);

  final Map<String, dynamic>? arguments;

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  int compareViewCount = 2;

  final LinkedScrollControllerGroup _linkedScrollControllerGroup =
      LinkedScrollControllerGroup();
  final List<ScrollController> _scrollControllers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("统计"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              setState(() {
                //disposeAllScrollControllers();
                compareViewCount++;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: () {
              setState(() {
                //disposeAllScrollControllers();
                compareViewCount--;
              });
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: ScoutingRepository.getInstance().getTeams(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else if (snapshot.hasData) {
            final List<int> teams = snapshot.data as List<int>;
            final List<Widget> compareViews = [];
            //disposeAllScrollControllers();
            for (int i = 0; i < compareViewCount; i++) {
              final sc = _linkedScrollControllerGroup.addAndGet();
              _scrollControllers.add(sc);
              compareViews.add(
                Container(
                  decoration: const BoxDecoration(),
                  clipBehavior: Clip.hardEdge,
                  width: MediaQuery.of(context).size.width / compareViewCount,
                  child: Navigator(
                    onGenerateRoute: (settings) => MaterialPageRoute(
                      builder: (context) => SelectAndCompareView(
                        teams: teams,
                        linkedScrollController: sc,
                      ),
                    ),
                  ),
                ),
              );
            }
            return Row(
              children: compareViews,
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  void disposeAllScrollControllers() {
    for (final controller in _scrollControllers) {
      controller.dispose();
    }
    _scrollControllers.clear();
  }

  @override
  void dispose() {
    disposeAllScrollControllers();
    super.dispose();
  }
}

class SelectAndCompareView extends StatelessWidget {
  final List<int> teams;
  final ScrollController linkedScrollController;

  const SelectAndCompareView(
      {Key? key, required this.teams, required this.linkedScrollController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    ValueNotifier<List<int>> filtered = ValueNotifier(teams);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: const InputDecoration(
              hintText: "搜索队伍",
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              filtered.value = teams
                  .where((element) => element.toString().startsWith(value))
                  .toList();
              filtered.notifyListeners();
            },
          ),
        ),
        ValueListenableBuilder(
          valueListenable: filtered,
          builder: (context, value, child) => ListView.builder(
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(filtered.value[index].toString()),
                onTap: () async {
                  try {
                    final data = await ScoutingRepository.getInstance()
                        .getTeamData(filtered.value[index]);
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                StatsDetailView(
                                    linkedScrollController:
                                        linkedScrollController,
                                    arguments: {
                                      'team': filtered.value[index].toString(),
                                      'data': data
                                    })));
                  } catch (e) {
                    Noticing.showAlert(context, e.toString(), "错误");
                  }
                },
              );
            },
            itemCount: filtered.value.length,
            shrinkWrap: true,
          ),
        ),
      ],
    );
  }
}

class StatsDetailView extends StatelessWidget {
  const StatsDetailView(
      {Key? key, required this.arguments, required this.linkedScrollController})
      : super(key: key);

  final Map<String, dynamic>? arguments;
  final ScrollController linkedScrollController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(arguments!["team"].toString()),
      ),
      body: SingleChildScrollView(
        controller: linkedScrollController,
        child: Column(
          children: buildStatsTables(),
        ),
      ),
    );
  }

  List<Widget> buildStatsTables() {
    Map<String, dynamic> data = arguments!["data"];
    final List<Widget> tables = [];
    for (final key in data.keys) {
      if (data[key] is Map) {
        tables.add(Padding(
          padding: const EdgeInsets.fromLTRB(4, 16, 4, 4),
          child: Text(key),
        ));
        tables.add(buildStatsTable(key, data[key]));
      }
    }
    return tables;
  }

  Widget buildStatsTable(String key, dynamic data) {
    final List<TableRow> rows = [];
    for (final key in data.keys) {
      rows.add(TableRow(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.withAlpha(100),
                width: 0.5,
              ),
            ),
          ),
          children: [
            Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  key,
                  style: const TextStyle(
                    fontFamily: "monospace",
                    // fontFeatures: <FontFeature>[
                    //   FontFeature.tabularFigures(),
                    // ],
                  ),
                )),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                data[key].toString(),
                style: const TextStyle(
                  fontFamily: "monospace",
                  // fontFeatures: <FontFeature>[
                  //   FontFeature.tabularFigures(),
                  // ],
                ),
              ),
            )
          ]));
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(2),
        }, // First column takes 1/3 of space, second column takes 2/3
        children: rows,
      ),
    );
  }
}
