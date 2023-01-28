// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'privileges_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrivilegesModel _$PrivilegesModelFromJson(Map<String, dynamic> json) =>
    PrivilegesModel(
      addOlt: json['add_olt'],
      addUsers: json['add_users'],
      changeCATV: json['change_catv'],
      deleteGPON: json['delete_gpon'],
      changeReasons: json['change_reasons'],
      seeOLTDevices: json['see_olt_devices'],
      changePasswords: json['change_passwords'],
      changePrivileges: json['change_privileges'],
      changePortDescription: json['change_port_description'],
    );

Map<String, dynamic> _$PrivilegesModelToJson(PrivilegesModel instance) =>
    <String, dynamic>{
      'add_olt': instance.addOlt,
      'add_users': instance.addUsers,
      'change_catv': instance.changeCATV,
      'delete_gpon': instance.deleteGPON,
      'change_reasons': instance.changeReasons,
      'see_olt_devices': instance.seeOLTDevices,
      'change_passwords': instance.changePasswords,
      'change_privileges': instance.changePrivileges,
      'change_port_description': instance.changePortDescription,
    };
