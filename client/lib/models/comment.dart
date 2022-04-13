import 'package:json_annotation/json_annotation.dart';

part 'comment.g.dart';


@JsonSerializable()
class Comment {
  @JsonKey(name: 'text') final String text;
  @JsonKey(name: 'user') final int user;

  Comment(this.text, this.user);

  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);
  Map<String, dynamic> toJson() => _$CommentToJson(this);
}
