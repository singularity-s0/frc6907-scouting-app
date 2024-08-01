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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Noticing {
  static showAlert(BuildContext context, String message, String title) {
    return showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              scrollable: true,
              title: Text(title),
              content: Text(message),
              actions: <Widget>[
                TextButton(
                    child: const Text("好"),
                    onPressed: () => Navigator.pop(context)),
              ],
            ));
  }

  static Future<bool?> showConfirmationDialog(
      BuildContext context, String message, String title) {
    return showDialog<bool>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              scrollable: true,
              title: Text(title),
              content: Text(message),
              actions: <Widget>[
                TextButton(
                    child: const Text("取消"),
                    onPressed: () => Navigator.pop(context, false)),
                TextButton(
                    child: const Text("好"),
                    onPressed: () => Navigator.pop(context, true)),
              ],
            ));
  }

  static Future<String?> showInputDialog(BuildContext context, String title,
      {int? maxLength}) {
    var text = "";
    return showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text(title),
              content: TextField(
                onChanged: (value) => text = value,
                onSubmitted: (value) => Navigator.pop(context, value),
                maxLength: maxLength,
                maxLengthEnforcement:
                    MaxLengthEnforcement.truncateAfterCompositionEnds,
                maxLines: maxLength == null ? 1 : null,
                expands: maxLength == null ? false : true,
              ),
              actions: <Widget>[
                TextButton(
                    child: const Text("好"),
                    onPressed: () => Navigator.pop(context, text)),
              ],
            ));
  }

  static Future<MatchInfo?> showMatchStringInput(BuildContext context,
      {bool canDismiss = false}) {
    return showDialog<MatchInfo>(
        barrierDismissible: canDismiss,
        context: context,
        builder: (BuildContext context) =>
            MatchInfoSelector(canDismiss: canDismiss));
  }

  static showAbout(BuildContext context) {
    return showAlert(
        context,
        "Copyright 2022 FRC Team 6907\n\nProject Open Source at https://github.com/singularity-s0/frc6907-scouting-app",
        "关于本应用");
  }
}

class Settings {
  late SharedPreferences preferences;

  Settings._();
  static final _instance = Settings._();
  factory Settings.getInstance() => _instance;

  Future<void> init() async {
    preferences = await SharedPreferences.getInstance();
  }
}

class MatchInfoSelector extends StatefulWidget {
  const MatchInfoSelector({Key? key, required this.canDismiss})
      : super(key: key);

  final bool canDismiss;

  @override
  State<MatchInfoSelector> createState() => _MatchInfoSelectorState();
}

class _MatchInfoSelectorState extends State<MatchInfoSelector> {
  int? team;
  String? matchType, matchCount, roundCount;

  final formKey = GlobalKey<FormState>();

  void submit() {
    if (formKey.currentState?.validate() == true &&
        matchType != null &&
        matchCount != null &&
        team != null) {
      String matchString = MATCH_NAME_CODE[matchType]! + matchCount!;
      if (roundCount != null) {
        matchString += 'm$roundCount';
      }
      Navigator.pop(context, MatchInfo(team!, matchString));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: AlertDialog(
        title: const Text("比赛信息"),
        content: Form(
          key: formKey,
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              TextFormField(
                autofocus: true,
                onChanged: (value) => team = int.tryParse(value),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: false),
                validator: (value) =>
                    int.tryParse(value ?? "") == null ? "请输入数字" : null,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: const InputDecoration(labelText: "比赛队伍"),
              ),
              IntrinsicWidth(
                child: DropdownButtonFormField<String>(
                  hint: const Text("选择比赛"),
                  validator: (value) =>
                      value?.isNotEmpty == true ? null : "请选择比赛",
                  items: MATCH_NAME_CODE.keys
                      .map((e) =>
                          DropdownMenuItem<String>(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      matchType = value;
                      if (MATCH_HAS_ROUND_COUNT[matchType] != true) {
                        roundCount = null;
                      }
                    });
                  },
                ),
              ),
              const SizedBox(width: 4),
              Row(mainAxisSize: MainAxisSize.min, children: [
                const Text("第"),
                const SizedBox(width: 4),
                IntrinsicWidth(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 24),
                    child: TextFormField(
                      onChanged: (value) => matchCount = value,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: false),
                      validator: (value) =>
                          int.tryParse(value ?? "") == null ? "请输入数字" : null,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Text("场"),
              ]),
              if (MATCH_HAS_ROUND_COUNT[matchType] == true) ...[
                const SizedBox(width: 4),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  const Text("第"),
                  const SizedBox(width: 4),
                  IntrinsicWidth(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 24),
                      child: TextFormField(
                        onChanged: (value) => roundCount = value,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: false),
                        validator: (value) =>
                            int.tryParse(value ?? "") == null ? "请输入数字" : null,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text("局"),
                ]),
              ]
            ],
          ),
        ),
        actions: <Widget>[
          if (widget.canDismiss)
            TextButton(
                child: const Text("取消"),
                onPressed: () => Navigator.pop(context)),
          TextButton(child: const Text("好"), onPressed: submit),
        ],
      ),
    );
  }
}

class TimelineDuration {
  int id;
  final int start;
  final int end;
  TimelineDuration(this.id, this.start, this.end);
}

class MatchInfo {
  final int team;
  final String match;
  MatchInfo(this.team, this.match);
}

class SelfSignedCertHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) {
        // TODO: WARNING this basically disables https security
        // DO NOT USE IN PRODUCTION
        return true;
      });
  }
}

const Map<String, String> MATCH_NAME_CODE = {
  "练习赛": "p",
  "资格赛": "qm",
  "淘汰赛": "pf",
  "决赛": "f"
};
const Map<String, bool> MATCH_HAS_ROUND_COUNT = {
  "练习赛": false,
  "资格赛": false,
  "淘汰赛": false,
  "决赛": false
};

class MatchPhase {
  final String _value;
  const MatchPhase._internal(this._value);

  @override
  toString() => _value;

  static const auto = MatchPhase._internal('auto');
  static const teleop = MatchPhase._internal('teleop');
  static const endgame = MatchPhase._internal('endgame');

  // 2023: 3s delay between auto and teleop
  static MatchPhase fromTime(int matchTime) {
    if (matchTime <= 15000) {
      return MatchPhase.auto;
    } else if (matchTime <= 123000) {
      return MatchPhase.teleop;
    } else {
      return MatchPhase.endgame;
    }
  }
}
