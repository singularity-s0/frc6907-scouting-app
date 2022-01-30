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
import 'package:scouting_6907/models.dart';

class ScoutingRepository {
  static final _instance = ScoutingRepository._();

  static get shared => _instance;

  static const String BASE_URL = "https://api.fduhole.com";

  Dio dio = Dio();
  String? _token;

  ScoutingRepository._() {
    dio.options = BaseOptions(receiveDataWhenStatusError: true);
  }

  Future<void> initializeRepo({required String token}) async {
    _token = token;
  }

  bool get isUserInitialized => _token != null;
  Map<String, String> get _tokenHeader {
    if (_token == null) throw Exception("Repo not yet initialized");
    return {"Authorization": "Token $_token"};
  }

  Future<SCData?> loadData() async {
    final response = await dio.get(BASE_URL + "/api",
        queryParameters: {}, options: Options(headers: _tokenHeader));
    return SCData.fromJson(response.data);
  }
}
