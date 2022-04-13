import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';


@JsonSerializable()
class User {
  @JsonKey(name: 'last_login') final DateTime? lastLogin;
  @JsonKey(name: 'first_name') final String firstName;
  @JsonKey(name: 'is_staff') final bool isStaff;
  @JsonKey(name: 'is_active') final bool isActive;
  @JsonKey(name: 'photo') final Uri? photo;
  @JsonKey(name: 'thumbnail') final Uri? thumbnail;

  User(this.lastLogin, this.firstName, this.isStaff, this.isActive, this.photo, this.thumbnail);

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
