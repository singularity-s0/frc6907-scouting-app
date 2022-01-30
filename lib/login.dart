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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();

  /// Attempt to log in for verification.
  Future<void> login(String id, String password) async {
    Navigator.pop(context, "token");
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("登录"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              onSubmitted: (_) =>
                  login(_nameController.text, _pwdController.text),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text("登录"),
          onPressed: () => login(_nameController.text, _pwdController.text),
        ),
      ],
    );
  }
}
