import 'package:json_annotation/json_annotation.dart';

import 'package:client/misc/converters.dart';
import 'package:client/models/user.dart';

part 'comment.g.dart';


@JsonSerializable()
class Comment {
  @JsonKey(name: 'report') final int report;
  @JsonKey(name: 'text') final String text;
  @JsonKey(name: 'subs', toJson: toNull, includeIfNull: false) final int subsID;
  @JsonKey(ignore: true, toJson: toNull, includeIfNull: false) User? subs;

  Comment(this.report, this.text, this.subsID);

  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);
  Map<String, dynamic> toJson() => _$CommentToJson(this);

  Comment copyWithUser(User subs) {
    var comment = Comment(report, text, subsID);
    comment.subs = subs;
    return comment;
  }
}
