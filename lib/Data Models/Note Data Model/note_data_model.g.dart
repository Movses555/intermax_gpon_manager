// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NoteDataModel _$NoteDataModelFromJson(Map<String, dynamic> json) =>
    NoteDataModel(
      id: json['id'],
      olt: json['olt'],
      onu: json['onu'],
      note: json['note'],
    );

Map<String, dynamic> _$NoteDataModelToJson(NoteDataModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'olt': instance.olt,
      'onu': instance.onu,
      'note': instance.note,
    };
