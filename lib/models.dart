/*
 *     Copyright (C) 2021  singularity-s0
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

// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';

part 'models.g.dart';

@JsonSerializable()
class SCData {
  final String itemEng;
  final String itemChn;
  final int auto;
  final int teleop;
  final int endgame;
  final List<SCField> properties;

  factory SCData.fromJson(Map<String, dynamic> json) => _$SCDataFromJson(json);
  SCData(this.itemEng, this.itemChn, this.auto, this.teleop, this.endgame,
      this.properties);
  Map<String, dynamic> toJson() => _$SCDataToJson(this);
}

@JsonSerializable()
class SCField {
  final String nameEn;
  final String nameCn;
  final SCWidget root;

  factory SCField.fromJson(Map<String, dynamic> json) =>
      _$SCFieldFromJson(json);
  SCField(this.nameEn, this.nameCn, this.root);
  Map<String, dynamic> toJson() => _$SCFieldToJson(this);
}

@JsonSerializable()
class SCWidget {
  final String name;
  final String type;
  final List<SCWidget> sons;
  dynamic data;

  SCWidget(this.name, this.type, this.sons);
  factory SCWidget.fromJson(Map<String, dynamic> json) =>
      _$SCWidgetFromJson(json);
  Map<String, dynamic> toJson() => _$SCWidgetToJson(this);
}
