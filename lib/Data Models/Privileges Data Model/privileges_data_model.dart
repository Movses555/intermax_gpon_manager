import 'package:json_annotation/json_annotation.dart';

part 'privileges_data_model.g.dart';

@JsonSerializable()
class PrivilegesModel{

  @JsonKey(name: 'add_olt')
  var addOlt;

  @JsonKey(name: 'add_users')
  var addUsers;

  @JsonKey(name: 'change_catv')
  var changeCATV;

  @JsonKey(name: 'delete_gpon')
  var deleteGPON;

  @JsonKey(name: 'change_reasons')
  var changeReasons;

  @JsonKey(name: 'see_olt_devices')
  var seeOLTDevices;

  @JsonKey(name: 'change_passwords')
  var changePasswords;

  @JsonKey(name: 'change_privileges')
  var changePrivileges;

  @JsonKey(name: 'change_port_description')
  var changePortDescription;


  PrivilegesModel({
    this.addOlt,
    this.addUsers,
    this.changeCATV,
    this.deleteGPON,
    this.changeReasons,
    this.seeOLTDevices,
    this.changePasswords,
    this.changePrivileges,
    this.changePortDescription
  });


  factory PrivilegesModel.fromJson(Map<String, dynamic> json) => _$PrivilegesModelFromJson(json);

  Map<String, dynamic> toJson() => _$PrivilegesModelToJson(this);
}