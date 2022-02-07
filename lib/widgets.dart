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

  Widget createWidget(BuildContext context, SCWidget widgetData,
      [bool enabled = true]) {
    switch (widgetData.type) {
      case 'int':
      case 'team':
        return TextFormField(
          enabled: enabled,
          decoration: InputDecoration(labelText: widgetData.name),
          initialValue: widgetData.data,
          onChanged: (value) => widgetData.data = value,
          keyboardType: const TextInputType.numberWithOptions(decimal: false),
          validator: (value) =>
              int.tryParse(value ?? "") == null ? null : value,
        );
      case 'double':
        return TextFormField(
          enabled: enabled,
          decoration: InputDecoration(labelText: widgetData.name),
          initialValue: widgetData.data,
          onChanged: (value) => widgetData.data = value,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) =>
              double.tryParse(value ?? "") == null ? null : value,
        );
      case 'text':
        return TextFormField(
          enabled: enabled,
          decoration: InputDecoration(labelText: widgetData.name),
          initialValue: widgetData.data,
          onChanged: (value) => widgetData.data = value,
        );
      case 'boolean':
        return Row(mainAxisSize: MainAxisSize.min, children: [
          Checkbox(
              value: widgetData.data ?? false,
              onChanged: enabled
                  ? (value) => setState(() {
                        widgetData.data = value;
                      })
                  : null),
          Text(widgetData.name,
              style: enabled
                  ? null
                  : TextStyle(color: Theme.of(context).hintColor)),
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
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: widgetData.sons
                              .map((e) => createWidget(context, e, enabled))
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
              onChanged: enabled
                  ? (value) {
                      setState(() {
                        radioButtonHostState.currentSelection = value;
                      });
                    }
                  : null,
            ),
            Text(widgetData.name,
                style: enabled
                    ? null
                    : TextStyle(color: Theme.of(context).hintColor)),
            if (widgetData.sons.isNotEmpty)
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: widgetData.sons
                    .map((e) => createWidget(
                        context,
                        e,
                        radioButtonHostState.currentSelection ==
                            widgetData.name))
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
      // widgets.add(Text(field.nameCn));
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

  /// Called every time user taps on a lap
  final void Function(int)? onSelectLap;

  /// This is called every time the user taps on the Lap button
  /// [onSelectLap] is always called immediately after. So there is no need to manually call this function.
  final void Function(TimelineDuration)? onCreateLap;

  /// Called when user resets the stopwatch
  final void Function()? onReset;

  const StopwatchTimeline(
      {Key? key,
      required this.timer,
      this.onSelectLap,
      this.onReset,
      this.onCreateLap})
      : super(key: key);

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
            child: InkWell(
              onTap: () => widget.onSelectLap?.call(e.id),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ColoredBox(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.2),
                    child: SizedBox(
                      width:
                          constraints.maxWidth * (e.end - e.start) / MATCH_TIME,
                      height: constraints.maxHeight,
                      child: Center(child: Text(e.id.toString())),
                    ),
                  ),
                  ColoredBox(
                    color: Theme.of(context).colorScheme.onSurface,
                    child: SizedBox(
                        width: SEPERATOR_WIDTH, height: constraints.maxHeight),
                  ),
                ],
              ),
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
              print("clock stop");
              widget.timer.onExecute.add(StopWatchExecute.stop);
              durations.add(TimelineDuration(
                  durations.length, lastStartTime, widget.timer.rawTime.value));
              widget.onSelectLap?.call(durations.length - 1);
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
                                      child: InkWell(
                                        onTap: () => widget.onSelectLap
                                            ?.call(durations.length),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ColoredBox(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary
                                                  .withOpacity(0.4),
                                              child: SizedBox(
                                                width: constraints.maxWidth *
                                                    (value - lastStartTime) /
                                                    MATCH_TIME,
                                                height: constraints.maxHeight,
                                              ),
                                            ),
                                            ColoredBox(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                              child: SizedBox(
                                                  width: SEPERATOR_WIDTH,
                                                  height:
                                                      constraints.maxHeight),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                            ))),
                // Current time text row
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
                // Laps start time row
                SizedBox(
                    height: 12,
                    child: LayoutBuilder(
                        builder: (BuildContext context,
                                BoxConstraints constraints) =>
                            Stack(
                              children: buildLapsStartTime(constraints),
                            ))),
                // Laps end time row
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
              final tlduration = TimelineDuration(
                  durations.length, lastStartTime, widget.timer.rawTime.value);
              durations.add(tlduration);
              lastStartTime = widget.timer.rawTime.value;
              widget.onCreateLap?.call(tlduration);
              widget.onSelectLap?.call(durations.length);
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
            onPressed: () async {
              if (await Noticing.showConfirmationDialog(
                      context, "所有已经记录的数据将被清空", "确认重置") ==
                  true) {
                durations = [];
                lastStartTime = 0;
                widget.timer.onExecute.add(StopWatchExecute.reset);
                widget.onReset?.call();
              }
            },
            child: const Text("重置"),
          ),
        ],
      ),
    ]);
  }
}
