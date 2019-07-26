import 'package:json_annotation/json_annotation.dart';
part 'picmodel.g.dart';
@JsonSerializable()
class PicModel{
  String createdAt;
  String publishedAt;
  String type;
  String url;

  PicModel(this.createdAt, this.publishedAt, this.type, this.url);

  factory PicModel.fromJson(Map<String,dynamic> json) => _$PicModelFromJson(json);
  Map<String,dynamic> toJson(PicModel model) => _$PicModelToJson(model);
}