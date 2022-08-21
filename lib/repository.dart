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

class ScoutingRepository {
  static final _instance = ScoutingRepository._();

  factory ScoutingRepository.getInstance() => _instance;

  String BASE_URL = "";

  late Dio dio;
  String? _token;

  ScoutingRepository._() {
    dio = Dio();
    dio.options =
        BaseOptions(receiveDataWhenStatusError: true, connectTimeout: 5000);
  }

  bool get isUserInitialized => _token != null;
  Map<String, String> get _tokenHeader {
    if (_token == null) throw Exception("Repo not yet initialized");
    return {"Authorization": "Bearer $_token"};
  }

  void logout() {
    _token = null;
  }

  void setServerAddress(String url) {
    BASE_URL = url;
  }

  Future<String?> login(String username, String password) async {
    final response = await dio.post(BASE_URL + "/token", data: {
      "username": username,
      "password": password,
    });
    return _token = response.data['access'];
  }

  Future<List?> loadInGameJson() async {
    final response = await dio.get(BASE_URL + "/template/",
        queryParameters: {}, options: Options(headers: _tokenHeader));
    // final List result = response.data['data'];
    final List result = response.data;
    return result;
    //return result.map((e) => SCData.fromJson(e)).toList();
  }

  Future<dynamic> loadGameSpec(String team, String match) async {
    final response = await dio.get(BASE_URL + "/api/gamespec/get",
        queryParameters: {}, options: Options(headers: _tokenHeader));
    print(response.data);
  }

  Future<void> postGameSpec(
      int team, String match, dynamic gameData, String evaluation) async {
    await dio.post(BASE_URL + "/scouting/match/update",
        data: {
          "team": team,
          "match": match,
          "gamedata": gameData,
          "evaluation": evaluation,
        },
        options: Options(headers: _tokenHeader));
  }
}
