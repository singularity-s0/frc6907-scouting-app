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

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:scouting_6907/models.dart';

class ScoutingRepository {
  static final _instance = ScoutingRepository._();

  factory ScoutingRepository.getInstance() => _instance;

  String BASE_URL = "https://124.223.41.26:8000";

  late Dio dio;
  String? _token;

  ScoutingRepository._() {
    dio = Dio();
    //Pin HTTPS cert
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      final SecurityContext sc = SecurityContext(withTrustedRoots: true);
      HttpClient httpClient = HttpClient(context: sc);
      httpClient.badCertificateCallback =
          (X509Certificate certificate, String host, int port) {
        if (certificate.pem.trim() == PINNED_CERT) {
          return true;
        }
        return false;
      };
      return httpClient;
    };
    dio.options =
        BaseOptions(receiveDataWhenStatusError: true, connectTimeout: 5000);
  }

  bool get isUserInitialized => _token != null;
  Map<String, String> get _tokenHeader {
    if (_token == null) throw Exception("Repo not yet initialized");
    return {"Authorization": "Bearer $_token"};
  }

  void setServerAddress(String url) {
    BASE_URL = url;
  }

  Future<String?> login(String username, String password) async {
    final response = await dio.post(BASE_URL + "/token/", data: {
      "username": username,
      "password": password,
    });
    return _token = response.data['access'];
  }

  Future<List<SCData>?> loadInGameData() async {
    final response = await dio.get(BASE_URL + "/api/ingameitem/get",
        queryParameters: {}, options: Options(headers: _tokenHeader));
    final List result = response.data['data'];
    print(response.data['data']);
    return result.map((e) => SCData.fromJson(e)).toList();
  }

  Future<dynamic> loadGameSpec(String team, String match) async {
    final response = await dio.get(BASE_URL + "/api/gamespec/get",
        queryParameters: {}, options: Options(headers: _tokenHeader));
    print(response.data);
  }
}

const PINNED_CERT = r"""-----BEGIN CERTIFICATE-----
MIIFazCCA1OgAwIBAgIUG93/SElgvz3qmBKwAn1O4b1wwAcwDQYJKoZIhvcNAQEL
BQAwRTELMAkGA1UEBhMCQVUxEzARBgNVBAgMClNvbWUtU3RhdGUxITAfBgNVBAoM
GEludGVybmV0IFdpZGdpdHMgUHR5IEx0ZDAeFw0yMjAxMzExMzQxNTJaFw0yMzAx
MzExMzQxNTJaMEUxCzAJBgNVBAYTAkFVMRMwEQYDVQQIDApTb21lLVN0YXRlMSEw
HwYDVQQKDBhJbnRlcm5ldCBXaWRnaXRzIFB0eSBMdGQwggIiMA0GCSqGSIb3DQEB
AQUAA4ICDwAwggIKAoICAQDeWm0c7GiFSe1TL6Dr+W2mEiJfEG3tfrZasVQ73eMq
U70sUIZIzD16MGtYdS1Rsi++Tt7GNnL0bC5kIe9xNRV/JGVPpK0xafdMsc4SvTfH
0cSGx4G3xSPB0jqscbleIs8x8uqSPgcrsn+INbvpMUruRSiTPbqY7AX0peEZSo1x
86z1qtAXOcMosMQpLnKsHdZS7xRrKia68MotfFumJ18RtlWCx6363TV36T9ehgGJ
lFJOkROuLyV9rAVnQ3ZU7mjvNMReVMRXi2D0kjZrg2P4CEKlP/ZYvxF25CCODdGq
wF83TRC06ivocwfbgqSrsb+QdR+T6BDMQAgM20QGPEmT5EU1BtWidjO4JFZXZqBZ
Kp0YjonBrt8eDV5X46MQNQ9ZQcinM4PdqRDBWegiW/N9Dec5mHsv6TK2srQfYoBg
g6FSoGM3YNicOntrAB8uPXce288ScuJB+cEG8peC+NQCkXIbHZgiwX4bBN+s1BXA
s1Vw1FrBkIYMxYsAI+bX3nO4KcUCYuQBQCiz+zP6/QjRyxSKocBzP+xE+FbYiUWH
Nxl2mKaoty1j5lWgc840JuLoZFDAEV4qqG3pEPvI/eqppttUrvgxgBzd6GuCTdoy
rMk8tkFs7t8AOSsClNU9arcZ10a4tzAYDLnzoV5NG1fw4HFeEfNDp3+IoPpthCLz
mwIDAQABo1MwUTAdBgNVHQ4EFgQUZBsJnBZyciCjrBnKQwqMk2kyLTcwHwYDVR0j
BBgwFoAUZBsJnBZyciCjrBnKQwqMk2kyLTcwDwYDVR0TAQH/BAUwAwEB/zANBgkq
hkiG9w0BAQsFAAOCAgEAc3F6PLN+mK0M36j6kIb0J8WDFXQwqM4hajRB5mzlu+cv
M12oIJ24J+86aWt09fo15MNng7ZUvgjK+W/igsh2BUn8PSE4apcv5h5JZnlzvbgX
uVmULhX+mP7qA0202snAywPxqAsaT8BxkbFc8ALk6T1GQ0WbyBRLFCTcaDhe7tTp
ci+q5MjgJ83rKKEk/LDlop8DMDSDmlwAjf2Lq4eJVgY6neklu0r5cQD2CsN0pudG
BHOk+GXlj8KzN/tlHtlhO0HRBMcI9deTEVxYiazhyLwwrX46P7FdWOIqZF6VLUnC
gTQlKnglz79f8BrQ35pOFqkPz3uYBPNuq+AjkXbyNEhxM46nHUvckUeIOt7SWp5H
ptJrAtOwtRFkBpXy19ydF5nizpKiUIgNJxZr3fcFecl3Oj+6tRKJFGmQOY7OsSCL
lXuBBOVNoqb8RZooP4upd0F/OuTTPiKqpA/UrjMrMJ6vkoLGoksf7MGXW7gnpQpc
I1+VQ7yfcA02itE86UvrXytgLch4Mresrm9O/P6zn9eMBRCfi2BuxGA8KJ1H/ILd
B0AN8MPIVnCkIHA7JKI5vcELx4w9FvSchW45BpKvQ2N8dj7LLTEw6ZRFCMWfCgwb
Uh+nDQMdFckgviMZZm3GvwY+uR9n0c7e1oEGnT6lORy9AEZh02EkJRwCNlfDTQ4=
-----END CERTIFICATE-----""";
