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
import 'package:scouting_6907/repository.dart';

class Noticing {
  static showAlert(BuildContext context, String message, String title) {
    return showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: Text(title),
              content: SingleChildScrollView(child: Text(message)),
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
}

class TimelineDuration {
  final int id;
  final int start;
  final int end;
  TimelineDuration(this.id, this.start, this.end);
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
