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

import 'package:flutter/material.dart';
import 'package:scouting_6907/models.dart';
import 'package:scouting_6907/utils.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

// 2023/2024: 3s delay between auto and teleop
const MATCH_TIME = 153000;

class ScoutingFieldsForm extends StatefulWidget {
  const ScoutingFieldsForm(
      {Key? key, required this.fields, required this.formKey})
      : super(key: key);

  final List<SCField> fields;

  /// A [GlobalKey] for the [Form] of this widget. It can be used to validate the input before submitting.
  final GlobalKey<FormState> formKey;

  @override
  State<ScoutingFieldsForm> createState() => _ScoutingFieldsFormState();
}

class _ScoutingFieldsFormState extends State<ScoutingFieldsForm> {
  late List<SCField> fields;

  @override
  void initState() {
    super.initState();
    fields = widget.fields;
  }

  @override
  void didUpdateWidget(covariant ScoutingFieldsForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    fields = widget.fields;
  }

  Widget createWidget(BuildContext context, SCWidget widgetData,
      [bool enabled = true]) {
    switch (widgetData.type) {
      case 'int':
      case 'team':
        return TextFormField(
          key: UniqueKey(),
          enabled: enabled,
          //decoration: InputDecoration(labelText: widgetData.name),
          initialValue: widgetData.data?.toString(),
          onChanged: (value) => widgetData.data = int.tryParse(value),
          keyboardType: const TextInputType.numberWithOptions(decimal: false),
          validator: (value) =>
              int.tryParse(value ?? "") == null ? "请输入数字" : null,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        );
      case 'double':
        return TextFormField(
          key: UniqueKey(),
          enabled: enabled,
          //decoration: InputDecoration(labelText: widgetData.name),
          initialValue: widgetData.data?.toString(),
          onChanged: (value) => widgetData.data = double.tryParse(value),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) =>
              double.tryParse(value ?? "") == null ? "请输入数字" : null,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        );
      case 'text':
        widgetData.data ??= "";
        return TextFormField(
          key: UniqueKey(),
          enabled: enabled,
          //decoration: InputDecoration(labelText: widgetData.name),
          initialValue: widgetData.data,
          onChanged: (value) => widgetData.data = value,
          //validator: (value) => value?.isNotEmpty == true ? null : "请输入内容",
          //autovalidateMode: AutovalidateMode.onUserInteraction,
        );
      case 'boolean':
        widgetData.data ??= false;
        return Row(mainAxisSize: MainAxisSize.min, children: [
          Checkbox(
              key: UniqueKey(),
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
      case 'count':
        widgetData.data ??= 0;
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
                icon: const Icon(Icons.remove),
                onPressed: enabled
                    ? () {
                        setState(() {
                          widgetData.data--;
                        });
                      }
                    : null),
            IntrinsicWidth(
              child: Text("${widgetData.name}: ${widgetData.data}"),
            ),
            const SizedBox(width: 8),
            IconButton(
                icon: const Icon(Icons.add),
                onPressed: enabled
                    ? () {
                        setState(() {
                          widgetData.data++;
                        });
                      }
                    : null),
          ],
        );
      case 'option':
        widgetData.data ??= widgetData.sons?.first.name;
        return FormField(
          key: UniqueKey(),
          validator: (value) => widgetData.data == null ? "请选择选项" : null,
          builder: (state) => Padding(
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
                        children: (widgetData.sons
                                ?.map((e) => createWidget(context, e, enabled))
                                .toList()) ??
                            [const Text("数据格式错误 RadioHost 必须具有 sons")]),
                  ),
                ),
                if (state.hasError)
                  Text(
                    state.errorText ?? "错误",
                    style: TextStyle(color: Theme.of(context).errorColor),
                  )
              ],
            ),
          ),
        );
      case 'group':
        return Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: (widgetData.sons
                    ?.map((e) => createWidget(context, e, enabled))
                    .toList()) ??
                [const Text("数据格式错误 group 必须具有 sons")]);
      case 'option_child':
      case 'null':
      case null:
        var radioButtonHostState =
            context.findAncestorStateOfType<RadioButtonHostState>()!;
        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Radio(
              key: UniqueKey(),
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
            if (widgetData.sons?.isNotEmpty == true)
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: widgetData.sons!
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
    return Text("未知控件类型${widgetData.type}：请更新软件");
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];
    for (var field in fields) {
      if (Settings.getInstance().preferences.getBool("showname") == true) {
        widgets.add(Text(field.nameCn));
      }
      widgets.add(createWidget(context, field.root));
      widgets.add(const Divider());
    }
    return Form(
      key: widget.formKey,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: widgets),
    );
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
  final int? selectedTimelineDuration;

  /// Called every time user taps on a lap
  final void Function(int)? onSelectLap;

  final void Function(int)? onLapCreationStarted;

  final void Function(int)? onLapCreationAborted;

  /// This is called in addition to [onLapCreationAborted]
  final void Function()? onFinalLapCreationAborted;

  /// This is called every time the user taps on the Lap button and when the timer starts
  final void Function(TimelineDuration)? onLapCreationCompleted;

  /// Called when the timer stops. Note that [onLapCreationCompleted] will also be called so there is no need to call that manually.
  final void Function()? onTimerStop;

  /// Called when user resets the stopwatch
  final void Function()? onReset;

  /// Called when user go back one duration
  final void Function()? onGoPrevDuration;

  /// Called when user deletes a duration
  final void Function(int)? onDeleteDuration;

  const StopwatchTimeline(
      {Key? key,
      required this.timer,
      this.onSelectLap,
      this.onReset,
      this.onGoPrevDuration,
      this.onLapCreationCompleted,
      this.onTimerStop,
      this.selectedTimelineDuration,
      this.onLapCreationStarted,
      this.onLapCreationAborted,
      this.onFinalLapCreationAborted,
      this.onDeleteDuration})
      : super(key: key);

  @override
  State<StopwatchTimeline> createState() => StopwatchTimelineState();
}

class StopwatchTimelineState extends State<StopwatchTimeline> {
  int lastStartTime = 0;
  List<TimelineDuration> durations = [];

  /// This bool is an indicator of whether the user has confirmed or dismissed the final duration after the timer stopped
  /// Used as a signal to disable the 提交/放弃 button
  bool finalInfoTimelineDurationNotYetCommited = false;

  static const double SEPERATOR_WIDTH = 2;

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
                    color: Theme.of(context).colorScheme.secondary,
                    child: SizedBox(
                        width: SEPERATOR_WIDTH, height: constraints.maxHeight),
                  ),
                  ColoredBox(
                    color: widget.selectedTimelineDuration != e.id
                        ? Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.2)
                        : Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.4),
                    child: SizedBox(
                      width: (constraints.maxWidth *
                                  (e.end - e.start) /
                                  MATCH_TIME -
                              SEPERATOR_WIDTH * 2)
                          .positiveValueOrZero(),
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

  int get currentTime => widget.timer.rawTime.value <= MATCH_TIME
      ? widget.timer.rawTime.value
      : MATCH_TIME;

  bool get isSessionStarted => currentTime > 0 || widget.timer.isRunning;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      StreamBuilder<int>(
          stream: widget.timer.rawTime,
          initialData: currentTime,
          builder: (context, snap) {
            final value = currentTime;
            if (value >= MATCH_TIME && widget.timer.isRunning) {
              // Stop timer
              widget.timer.onExecute.add(StopWatchExecute.stop);
              widget.onTimerStop?.call();
              finalInfoTimelineDurationNotYetCommited = true;
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
                                                .secondary,
                                            child: SizedBox(
                                                width: SEPERATOR_WIDTH,
                                                height:
                                                    constraints.maxHeight))),
                                    Positioned(
                                        right: 0,
                                        child: ColoredBox(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
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
                                                  .primary,
                                              child: SizedBox(
                                                  width: SEPERATOR_WIDTH,
                                                  height:
                                                      constraints.maxHeight),
                                            ),
                                            ColoredBox(
                                              color:
                                                  (widget.selectedTimelineDuration ??
                                                              0) <
                                                          durations.length
                                                      ? Theme.of(context)
                                                          .colorScheme
                                                          .secondary
                                                          .withOpacity(0.2)
                                                      : Theme.of(context)
                                                          .colorScheme
                                                          .primary
                                                          .withOpacity(0.4),
                                              child: SizedBox(
                                                width: (constraints.maxWidth *
                                                            (value -
                                                                lastStartTime) /
                                                            MATCH_TIME -
                                                        SEPERATOR_WIDTH * 2)
                                                    .positiveValueOrZero(),
                                                height: constraints.maxHeight,
                                              ),
                                            ),
                                            ColoredBox(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
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
                    child: LayoutBuilder(builder:
                        (BuildContext context, BoxConstraints constraints) {
                      final TextPainter textPainter = TextPainter(
                          textDirection: TextDirection.ltr,
                          text: TextSpan(
                            text: StopWatchTimer.getDisplayTime(value,
                                hours: false, milliSecond: false),
                          ));
                      final location =
                          constraints.maxWidth * (value / MATCH_TIME);
                      textPainter.layout();
                      return Stack(
                        children: [
                          if (textPainter.size.width + location <=
                              constraints.maxWidth) ...[
                            Positioned(
                                left: location,
                                child: Text(StopWatchTimer.getDisplayTime(value,
                                    hours: false, milliSecond: false))),
                          ] else ...[
                            Positioned(
                                right: constraints.maxWidth - location,
                                child: Text(StopWatchTimer.getDisplayTime(value,
                                    hours: false, milliSecond: false))),
                          ]
                        ],
                      );
                    })),
                /*
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
                            ))),*/
              ],
            );
          }),
      const SizedBox(height: 4),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ElevatedButton(
            onPressed: isSessionStarted
                ? null
                : () {
                    lastStartTime = 0;
                    widget.timer.onExecute.add(StopWatchExecute.start);
                    widget.onLapCreationStarted?.call(lastStartTime);
                    setState(() {});
                  },
            child: const Text("开始"),
          ),
          ElevatedButton(
            onPressed: (isSessionStarted)
              ? () {
                  widget.onGoPrevDuration?.call();
                }
              : null,
            child: const Text("⬅️"),
          ),
          ElevatedButton(
            onPressed: (widget.timer.isRunning ||
                    finalInfoTimelineDurationNotYetCommited)
                ? () {
                    final tlduration = TimelineDuration(
                        durations.length, lastStartTime, currentTime);
                    durations.add(tlduration);
                    lastStartTime = currentTime;
                    widget.onLapCreationCompleted?.call(tlduration);
                    if (widget.timer.isRunning) {
                      widget.onLapCreationStarted?.call(lastStartTime);
                    } else {
                      setState(() {});
                    }
                    finalInfoTimelineDurationNotYetCommited = false;
                  }
                : null,
            child: const Text("计次"),
          ),
          ElevatedButton(
            onPressed: (widget.timer.isRunning ||
                    finalInfoTimelineDurationNotYetCommited)
                ? () {
                    lastStartTime = currentTime;
                    widget.onLapCreationAborted?.call(lastStartTime);
                    if (widget.timer.isRunning) {
                      widget.onLapCreationStarted?.call(lastStartTime);
                    } else {
                      widget.onFinalLapCreationAborted?.call();
                    }
                    finalInfoTimelineDurationNotYetCommited = false;
                  }
                : null,
            child: const Text("放弃"),
          ),
          ElevatedButton(
            onPressed: (widget.selectedTimelineDuration == null ||
                    widget.selectedTimelineDuration! >= durations.length)
                ? null
                : () async {
                    if (await Noticing.showConfirmationDialog(
                            context, "删除选中的时间段？", "确认删除") ==
                        true) {
                      durations.removeAt(widget.selectedTimelineDuration!);
                      for (int i = widget.selectedTimelineDuration!;
                          i < durations.length;
                          i++) {
                        durations[i].id--;
                      }
                      widget.onDeleteDuration
                          ?.call(widget.selectedTimelineDuration!);
                    }
                  },
            child: const Text("删除"),
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

extension NoLessThanZero on double {
  double positiveValueOrZero() {
    final value = this;
    if (value >= 0) return value;
    return 0;
  }
}
