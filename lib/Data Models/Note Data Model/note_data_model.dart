import 'package:json_annotation/json_annotation.dart';


part 'note_data_model.g.dart';


@JsonSerializable()
class NoteDataModel{

  @JsonKey(name: 'id')
  var id;

  @JsonKey(name: 'olt')
  var olt;

  @JsonKey(name: 'onu')
  var onu;

  @JsonKey(name: 'note')
  var note;

  NoteDataModel({
    this.id,
    this.olt,
    this.onu,
    this.note
  });

  factory NoteDataModel.fromJson(Map<String, dynamic> json) => _$NoteDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$NoteDataModelToJson(this);
}