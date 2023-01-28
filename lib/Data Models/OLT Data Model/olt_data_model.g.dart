// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'olt_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OltDevice _$OltDeviceFromJson(Map<String, dynamic> json) => OltDevice(
      id: json['id'],
      ip: json['ip'],
      username: json['username'],
      password: json['password'],
      description: json['description'],
    );

Map<String, dynamic> _$OltDeviceToJson(OltDevice instance) => <String, dynamic>{
      'id': instance.id,
      'ip': instance.ip,
      'username': instance.username,
      'password': instance.password,
      'description': instance.description,
    };
