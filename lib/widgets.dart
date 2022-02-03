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

import 'package:flutter/material.dart';
import 'package:scouting_6907/models.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

const MATCH_TIME = 150000;

class DynamicScoutingOptionsWidget extends StatefulWidget {
  const DynamicScoutingOptionsWidget({Key? key, required this.fields})
      : super(key: key);

  final List<SCField> fields;

  @override
  State<DynamicScoutingOptionsWidget> createState() =>
      _DynamicScoutingOptionsWidgetState();
}

class _DynamicScoutingOptionsWidgetState
    extends State<DynamicScoutingOptionsWidget> {
  late List<SCField> fields;

  @override
  void initState() {
    super.initState();
    fields = widget.fields;
  }

  @override
  void didUpdateWidget(covariant DynamicScoutingOptionsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // TODO: prompt to save data
    fields = widget.fields;
  }

  Widget createWidget(BuildContext context, SCWidget widgetData) {
    switch (widgetData.type) {
      case 'int':
      case 'team':
        return TextFormField(
          decoration: InputDecoration(labelText: widgetData.name),
          onChanged: (value) => widgetData.data = value,
          keyboardType: const TextInputType.numberWithOptions(decimal: false),
        );
      case 'double':
        return TextFormField(
          decoration: InputDecoration(labelText: widgetData.name),
          onChanged: (value) => widgetData.data = value,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) =>
              double.tryParse(value ?? "") == null ? null : value,
        );
      case 'text':
        return TextFormField(
          decoration: InputDecoration(labelText: widgetData.name),
          onChanged: (value) => widgetData.data = value,
        );
      case 'boolean':
        return Row(mainAxisSize: MainAxisSize.min, children: [
          Checkbox(
              value: widgetData.data ?? false,
              onChanged: (value) => setState(() {
                    widgetData.data = value;
                  })),
          Text(widgetData.name),
        ]);
      case 'option':
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widgetData.name),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  RadioButtonHost(
                    widgetData: widgetData,
                    child: Builder(
                      builder: (context) => Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: widgetData.sons
                              .map((e) => createWidget(context, e))
                              .toList()),
                    ),
                  ),
                ],
              ),
            )
          ],
        );
      case 'option_child':
      case 'null':
      case null:
        var radioButtonHostState =
            context.findAncestorStateOfType<RadioButtonHostState>()!;
        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Radio(
              value: widgetData.name,
              groupValue: radioButtonHostState.currentSelection,
              onChanged: (value) {
                setState(() {
                  radioButtonHostState.currentSelection = value;
                });
              },
            ),
            Text(widgetData.name),
            if (widgetData.sons.isNotEmpty &&
                radioButtonHostState.currentSelection == widgetData.name)
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: widgetData.sons
                    .map((e) => createWidget(context, e))
                    .toList(),
              ),
          ],
        );
    }
    return const Text("未知控件类型：请更新软件");
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];
    for (var field in fields) {
      widgets.add(Text(field.nameCn));
      widgets.add(createWidget(context, field.root));
      widgets.add(const Divider());
    }
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: widgets);
  }
}

/// The purpose of this host is to store the [groupValue] data for its child radio buttons.
/// It will return the child as-is.
class RadioButtonHost extends StatefulWidget {
  final Widget child;
  final SCWidget widgetData;
  const RadioButtonHost(
      {Key? key, required this.child, required this.widgetData})
      : super(key: key);
  @override
  State<RadioButtonHost> createState() => RadioButtonHostState();
}

class RadioButtonHostState extends State<RadioButtonHost> {
  Object? get currentSelection => widget.widgetData.data;
  set currentSelection(Object? value) => widget.widgetData.data = value;

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class StopwatchTimeline extends StatefulWidget {
  final StopWatchTimer timer;
  const StopwatchTimeline({Key? key, required this.timer}) : super(key: key);

  @override
  State<StopwatchTimeline> createState() => StopwatchTimelineState();
}

class StopwatchTimelineState extends State<StopwatchTimeline> {
  List<int> laps = [];

  Widget buildLaps() {
    List<Widget> widgets = [];
    for (var element in widget.timer.records.value) {
      widgets.add(SizedBox(
          width: MediaQuery.of(context).size.width *
              element.rawValue! /
              MATCH_TIME));
      widgets.add(const ColoredBox(
          color: Colors.red, child: SizedBox(width: 2, height: 4)));
    }
    return Row(children: widgets);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      StreamBuilder<int>(
          stream: widget.timer.rawTime,
          initialData: widget.timer.rawTime.value,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width *
                          (value / MATCH_TIME),
                    ),
                    const ColoredBox(
                        color: Colors.black,
                        child: SizedBox(width: 2, height: 4))
                  ],
                ),
                buildLaps()
                /*Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    value.toString(),
                    style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Helvetica',
                        fontWeight: FontWeight.w400),
                  ),
                ),*/
              ],
            );
          }),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ElevatedButton(
            onPressed: () {
              widget.timer.onExecute.add(StopWatchExecute.start);
            },
            child: const Text("开始"),
          ),
          ElevatedButton(
            onPressed: () {
              widget.timer.onExecute.add(StopWatchExecute.lap);
            },
            child: const Text("记圈"),
          ),
          ElevatedButton(
            onPressed: () {
              widget.timer.onExecute.add(StopWatchExecute.stop);
            },
            child: const Text("停止"),
          ),
          ElevatedButton(
            onPressed: () {
              widget.timer.onExecute.add(StopWatchExecute.reset);
            },
            child: const Text("重置"),
          ),
        ],
      ),
    ]);
  }
}
