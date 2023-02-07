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

  Future<List<int>?> getTeams() async {
    final response = await dio.get(BASE_URL + "/strategy",
        queryParameters: {}, options: Options(headers: _tokenHeader));
    final List result = response.data;
    return result.map((e) => e as int).toList();
  }

  Future<dynamic> getTeamData(int team) async {
    const retString = """{
  "team": 118,
  "basicstat_rk": {
    "时间": "进攻144.52(1) / 防守0.00(1) / 放弃5.48(1)",
    "Cycle": "场均0.00(1) / 被防0.00",
    "得分": "pp10s 0.00(1) / tpp10s 0.00(1)",
    "爬升": "低0/0/0.0 中0/0/0.0 高0/0/0.0 顶0/0/0.0 ",
    "升钩": "14.3 (0.0)",
    "自动": "过线0% / 场均0.00(1)",
    "低框": "0.0/0.0/0.00(1)",
    "高框": "0.0/0.0/0.00(1)",
    "技术": "超吸0.0 / 犯规0.0 / PIN 0.0 / 技犯0 / 百秒失0.0"
  },
  "featstat": {
    "左起自动": "一射0.0/0.00  二射0.0/0.00  三射0.0/0.00",
    "右起自动": "一射0.0/0.00  二射0.0/0.00  三射0.0/0.00",
    "起步": "左0/右0",
    "停车": "左0/中0/右0",
    "吸球倾向": "对场0%/贴墙0%/混杂0%/盲区0%/异色0%",
    "出手倾向": "广告0%/安全0%/围栏0%",
    "异色": "自动0 / 射出0 / 放置0"
  }
}""";
    // final response = await dio.get(BASE_URL + "/strategy/team/$team",
    //     options: Options(headers: _tokenHeader));
    // final dynamic result = json.decode(response.data);
    // print(result);
    final dynamic result = json.decode(retString);
    return result;
  }
}
