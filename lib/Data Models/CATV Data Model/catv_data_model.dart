import 'package:json_annotation/json_annotation.dart';

part 'catv_data_model.g.dart';

@JsonSerializable()
class CATVDataModel{

  @JsonKey(name: 'olt_ip')
  var oltIp;

  @JsonKey(name: 'gpon_name')
  var gponName;

  @JsonKey(name: 'reason')
  var reason;

  @JsonKey(name: 'date')
  var date;

  @JsonKey(name: 'admin')
  var admin;

  CATVDataModel({
    this.oltIp,
    this.gponName,
    this.reason,
    this.date,
    this.admin
  });

  factory CATVDataModel.fromJson(Map<String, dynamic> json) => _$CATVDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$CATVDataModelToJson(this);
}