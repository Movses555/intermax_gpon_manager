import 'package:json_annotation/json_annotation.dart';

part 'olt_data_model.g.dart';

@JsonSerializable()
class OltDevice{

  @JsonKey(name: 'id')
  var id;

  @JsonKey(name: 'ip')
  var ip;

  @JsonKey(name: 'username')
  var username;

  @JsonKey(name: 'password')
  var password;

  @JsonKey(name: 'description')
  var description;

  OltDevice({this.id, this.ip, this.username, this.password, this.description});

  factory OltDevice.fromJson(Map<String, dynamic> json) => _$OltDeviceFromJson(json);

  Map<String, dynamic> toJson() => _$OltDeviceToJson(this);
}