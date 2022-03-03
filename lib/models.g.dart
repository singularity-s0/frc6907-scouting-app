// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SCTimelineItem _$SCTimelineItemFromJson(Map<String, dynamic> json) =>
    SCTimelineItem(
      json['data'] == null
          ? null
          : SCData.fromJson(json['data'] as Map<String, dynamic>),
      json['startTime'] as int?,
      json['endTime'] as int?,
    );

Map<String, dynamic> _$SCTimelineItemToJson(SCTimelineItem instance) =>
    <String, dynamic>{
      'data': instance.data,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
    };

SCData _$SCDataFromJson(Map<String, dynamic> json) => SCData(
      json['ItemEng'] as String,
      json['ItemChn'] as String,
      json['Auto'] as bool,
      json['Teleop'] as bool,
      json['Endgame'] as bool,
      (json['Properties'] as List<dynamic>)
          .map((e) => SCField.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SCDataToJson(SCData instance) => <String, dynamic>{
      'ItemEng': instance.ItemEng,
      'ItemChn': instance.ItemChn,
      'Auto': instance.Auto,
      'Teleop': instance.Teleop,
      'Endgame': instance.Endgame,
      'Properties': instance.Properties,
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
      json['type'] as String?,
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
