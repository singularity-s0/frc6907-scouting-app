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
import 'package:scouting_6907/utils.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

const MATCH_TIME = 50000; // 150000

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
  int lastStartTime = 0;
  List<TimelineDuration> durations = [];
  static const double SEPERATOR_WIDTH = 4;

  List<Positioned> buildLaps(BoxConstraints constraints) {
    return durations
        .map(
          (e) => Positioned(
            left: constraints.maxWidth * (e.start / MATCH_TIME),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ColoredBox(
                  color:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.4),
                  child: SizedBox(
                    width:
                        constraints.maxWidth * (e.end - e.start) / MATCH_TIME,
                    height: constraints.maxHeight,
                    child: Center(child: Text(e.id.toString())),
                  ),
                ),
                ColoredBox(
                  color: Theme.of(context).colorScheme.secondary,
                  child: SizedBox(
                      width: SEPERATOR_WIDTH, height: constraints.maxHeight),
                ),
              ],
            ),
          ),
        )
        .toList();
  }

  List<Positioned> buildLapsStartTime(BoxConstraints constraints) {
    return durations
        .map(
          (e) => Positioned(
              left: constraints.maxWidth * (e.start / MATCH_TIME),
              child: Text(
                  StopWatchTimer.getDisplayTime(e.start,
                      hours: false, milliSecond: false),
                  textScaleFactor: 0.5)),
        )
        .toList();
  }

  List<Positioned> buildLapsEndTime(BoxConstraints constraints) {
    return durations
        .map(
          (e) => Positioned(
              left: constraints.maxWidth * (e.end / MATCH_TIME),
              child: Text(
                  StopWatchTimer.getDisplayTime(e.end,
                      hours: false, milliSecond: false),
                  textScaleFactor: 0.5)),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      StreamBuilder<int>(
          stream: widget.timer.rawTime,
          initialData: widget.timer.rawTime.value,
          builder: (context, snap) {
            final value = snap.data!;
            if (value >= MATCH_TIME) {
              widget.timer.onExecute.add(StopWatchExecute.stop);
            }
            return Column(
              children: <Widget>[
                SizedBox(
                    height: 12,
                    child: LayoutBuilder(
                        builder: (BuildContext context,
                                BoxConstraints constraints) =>
                            Stack(
                              children: [
                                const Positioned(
                                    left: 0,
                                    child: Text(
                                      "00:00",
                                      textScaleFactor: 0.5,
                                    )),
                                Positioned(
                                    right: 0,
                                    child: Text(
                                        StopWatchTimer.getDisplayTime(
                                            MATCH_TIME,
                                            hours: false,
                                            milliSecond: false),
                                        textScaleFactor: 0.5))
                              ],
                            ))),
                SizedBox(
                    height: 24,
                    child: LayoutBuilder(
                        builder: (BuildContext context,
                                BoxConstraints constraints) =>
                            Stack(
                              children: buildLaps(constraints) +
                                  [
                                    Positioned(
                                        left: 0,
                                        child: ColoredBox(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                            child: SizedBox(
                                                width: SEPERATOR_WIDTH,
                                                height:
                                                    constraints.maxHeight))),
                                    Positioned(
                                        right: 0,
                                        child: ColoredBox(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                            child: SizedBox(
                                                width: SEPERATOR_WIDTH,
                                                height:
                                                    constraints.maxHeight))),
                                    Positioned(
                                        left: constraints.maxWidth *
                                            (lastStartTime / MATCH_TIME),
                                        child: ColoredBox(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            child: SizedBox(
                                                width: SEPERATOR_WIDTH * 0.5,
                                                height:
                                                    constraints.maxHeight))),
                                    Positioned(
                                        left: constraints.maxWidth *
                                            (value / MATCH_TIME),
                                        child: ColoredBox(
                                            color:
                                                Theme.of(context).primaryColor,
                                            child: SizedBox(
                                                width: SEPERATOR_WIDTH,
                                                height:
                                                    constraints.maxHeight))),
                                  ],
                            ))),
                SizedBox(
                    height: 24,
                    child: LayoutBuilder(
                        builder: (BuildContext context,
                                BoxConstraints constraints) =>
                            Stack(
                              children: [
                                Positioned(
                                    left: constraints.maxWidth *
                                        (value / MATCH_TIME),
                                    child: Text(StopWatchTimer.getDisplayTime(
                                        value,
                                        hours: false))),
                              ],
                            ))),
                SizedBox(
                    height: 12,
                    child: LayoutBuilder(
                        builder: (BuildContext context,
                                BoxConstraints constraints) =>
                            Stack(
                              children: buildLapsStartTime(constraints),
                            ))),
                SizedBox(
                    height: 12,
                    child: LayoutBuilder(
                        builder: (BuildContext context,
                                BoxConstraints constraints) =>
                            Stack(
                              children: buildLapsEndTime(constraints),
                            ))),
              ],
            );
          }),
      const SizedBox(
        height: 16,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ElevatedButton(
            onPressed: () {
              lastStartTime = 0;
              widget.timer.onExecute.add(StopWatchExecute.start);
            },
            child: const Text("开始"),
          ),
          ElevatedButton(
            onPressed: () {
              durations.add(TimelineDuration(
                  durations.length, lastStartTime, widget.timer.rawTime.value));
              lastStartTime = widget.timer.rawTime.value;
            },
            child: const Text("计次"),
          ),
          ElevatedButton(
            onPressed: () {
              lastStartTime = widget.timer.rawTime.value;
            },
            child: const Text("放弃"),
          ),
          ElevatedButton(
            onPressed: () {
              durations = [];
              lastStartTime = 0;
              widget.timer.onExecute.add(StopWatchExecute.reset);
            },
            child: const Text("重置"),
          ),
        ],
      ),
    ]);
  }
}
