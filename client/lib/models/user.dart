import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';


@JsonSerializable()
class User extends Equatable {
  @JsonKey(name: 'last_login') final DateTime? lastLogin;
  @JsonKey(name: 'first_name') final String? firstName;
  @JsonKey(name: 'email') final String? email;
  @JsonKey(name: 'is_staff') final bool isStaff;
  @JsonKey(name: 'photo') final Uri? photo;
  @JsonKey(name: 'thumbnail') final Uri? thumbnail;

  const User(this.lastLogin, this.firstName, this.email, this.isStaff, this.photo, this.thumbnail);

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  @override
  List<Object?> get props => [lastLogin, firstName, email, isStaff, photo, thumbnail];
}
