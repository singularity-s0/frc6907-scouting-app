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

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:scouting_6907/repository.dart';
import 'package:scouting_6907/utils.dart';

class LoginDialog extends StatefulWidget {
  static Future<String?> showLoginDialog(BuildContext context) async {
    return await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => const LoginDialog());
  }

  const LoginDialog({Key? key}) : super(key: key);

  @override
  _LoginDialogState createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final TextEditingController _ipController =
      TextEditingController(text: "https://6907goat.cc:8443");
  final TextEditingController _nameController = TextEditingController(
      text: Settings.getInstance().preferences.getString("username"));
  final TextEditingController _pwdController = TextEditingController();

  /// Attempt to log in for verification.
  Future<void> login(String url, String id, String password) async {
    try {
      ScoutingRepository.getInstance().setServerAddress(url);
      final token = await ScoutingRepository.getInstance().login(id, password);
      Navigator.pop(context, token);
    } catch (error) {
      if (error is DioError && error.response?.data != null) {
        Noticing.showAlert(
            context, (error.response?.data).toString(), error.message);
      } else {
        if (error is DioError) {
          Noticing.showAlert(context, error.message, "错误");
        } else {
          Noticing.showAlert(context, error.toString(), "错误");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
            title: const Text("登录"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _ipController,
                    decoration: const InputDecoration(
                        labelText: "服务器", icon: Icon(Icons.settings_ethernet)),
                    autofocus: true,
                  ),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                        labelText: "用户名", icon: Icon(Icons.perm_identity)),
                    autofocus: true,
                  ),
                  const SizedBox(height: 2),
                  TextField(
                    controller: _pwdController,
                    decoration: const InputDecoration(
                        labelText: "密码", icon: Icon(Icons.lock_outline)),
                    obscureText: true,
                    onSubmitted: (_) {
                      Settings.getInstance()
                          .preferences
                          .setString("username", _nameController.text);
                      login(_ipController.text, _nameController.text,
                          _pwdController.text);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text("登录"),
                onPressed: () {
                  Settings.getInstance()
                      .preferences
                      .setString("username", _nameController.text);
                  login(_ipController.text, _nameController.text,
                      _pwdController.text);
                },
              ),
            ]));
  }
}
