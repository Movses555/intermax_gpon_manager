// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catv_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CATVDataModel _$CATVDataModelFromJson(Map<String, dynamic> json) =>
    CATVDataModel(
      oltIp: json['olt_ip'],
      gponName: json['gpon_name'],
      reason: json['reason'],
      date: json['date'],
      admin: json['admin'],
    );

Map<String, dynamic> _$CATVDataModelToJson(CATVDataModel instance) =>
    <String, dynamic>{
      'olt_ip': instance.oltIp,
      'gpon_name': instance.gponName,
      'reason': instance.reason,
      'date': instance.date,
      'admin': instance.admin,
    };
