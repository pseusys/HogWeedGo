import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:client/misc/converters.dart';
import 'package:client/models/user.dart';

part 'comment.g.dart';


@JsonSerializable()
class Comment extends Equatable {
  @JsonKey(name: 'report', fromJson: toNull) final int? report;
  @JsonKey(name: 'text') final String text;
  @JsonKey(name: 'subs', toJson: toNull, includeIfNull: false) final int? subsID;
  @JsonKey(ignore: true, toJson: toNull, includeIfNull: false) final User? subs;

  const Comment(this.report, this.text, this.subsID): subs = null;
  const Comment._(this.report, this.text, this.subsID, this.subs);
  const Comment.send(this.report, this.text): subsID = 0, subs = null;

  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);
  Map<String, dynamic> toJson() => _$CommentToJson(this);

  Comment copyWithUser(User subs) => Comment._(report, text, subsID, subs);

  @override
  List<Object?> get props => [report, text, subsID];
}
