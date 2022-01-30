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

  Widget createWidget(BuildContext context, SCWidget widgetData) {
    switch (widgetData.type) {
      case 'int':
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
    print(jsonEncode(fields));
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
