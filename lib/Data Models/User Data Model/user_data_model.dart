import 'package:json_annotation/json_annotation.dart';

part 'user_data_model.g.dart';

@JsonSerializable()
class User{

  @JsonKey(name: 'id')
  var id;

  @JsonKey(name: 'name')
  var name;

  @JsonKey(name: 'password')
  var password;

  User({this.name, this.password});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

}