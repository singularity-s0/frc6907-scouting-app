// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SCData _$SCDataFromJson(Map<String, dynamic> json) => SCData(
      json['itemEng'] as String,
      json['itemChn'] as String,
      json['auto'] as int,
      json['teleop'] as int,
      json['endgame'] as int,
      (json['properties'] as List<dynamic>)
          .map((e) => SCField.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SCDataToJson(SCData instance) => <String, dynamic>{
      'itemEng': instance.itemEng,
      'itemChn': instance.itemChn,
      'auto': instance.auto,
      'teleop': instance.teleop,
      'endgame': instance.endgame,
      'properties': instance.properties,
    };

SCField _$SCFieldFromJson(Map<String, dynamic> json) => SCField(
      json['nameEn'] as String,
      json['nameCn'] as String,
      SCWidget.fromJson(json['root'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SCFieldToJson(SCField instance) => <String, dynamic>{
      'nameEn': instance.nameEn,
      'nameCn': instance.nameCn,
      'root': instance.root,
    };

SCWidget _$SCWidgetFromJson(Map<String, dynamic> json) => SCWidget(
      json['name'] as String,
      json['type'] as String,
      (json['sons'] as List<dynamic>)
          .map((e) => SCWidget.fromJson(e as Map<String, dynamic>))
          .toList(),
    )..data = json['data'];

Map<String, dynamic> _$SCWidgetToJson(SCWidget instance) => <String, dynamic>{
      'name': instance.name,
      'type': instance.type,
      'sons': instance.sons,
      'data': instance.data,
    };
