import 'package:json_annotation/json_annotation.dart';

part 'disconnect_reason_model.g.dart';

@JsonSerializable()
class DisconnectReasonModel{

  @JsonKey(name: 'id')
  var id;

  @JsonKey(name: 'reason')
  var reason;

  DisconnectReasonModel({this.id, this.reason});

  factory DisconnectReasonModel.fromJson(Map<String, dynamic> json) => _$DisconnectReasonModelFromJson(json);

  Map<String, dynamic> toJson() => _$DisconnectReasonModelToJson(this);
}