import 'package:json_annotation/json_annotation.dart';

import 'package:client/misc/converters.dart';

part 'comment.g.dart';


@JsonSerializable()
class Comment {
  @JsonKey(name: 'report') final String report;
  @JsonKey(name: 'text') final String text;
  @JsonKey(name: 'subs', toJson: toNull, includeIfNull: false) final int user;

  Comment(this.report, this.text, this.user);

  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);
  Map<String, dynamic> toJson() => _$CommentToJson(this);
}
