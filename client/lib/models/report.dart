import 'package:json_annotation/json_annotation.dart';
import 'package:latlong2/latlong.dart';

import 'package:client/misc/converters.dart';
import 'package:client/models/comment.dart';

part 'report.g.dart';


enum ReportStatus {
  RECEIVED
}

@JsonSerializable()
class Photo {
  @JsonKey(name: 'photo', fromJson: uriFromString) final Uri photo;
  @JsonKey(name: 'thumbnail', fromJson: uriFromString) final Uri thumbnail;

  Photo(this.photo, this.thumbnail);

  factory Photo.fromJson(Map<String, dynamic> json) => _$PhotoFromJson(json);
}

@JsonSerializable(explicitToJson: true)
class Report {
  @JsonKey(name: 'address') final String address;
  @JsonKey(name: 'init_comment') final String initComment;
  @JsonKey(name: 'date', toJson: toNull, includeIfNull: false) final DateTime date;
  @JsonKey(name: 'status', toJson: toNull, includeIfNull: false) final ReportStatus status;
  @JsonKey(name: 'subs', toJson: toNull, includeIfNull: false) final String subs;
  @JsonKey(name: 'type') final String type;
  @JsonKey(name: 'photos', toJson: toNull, includeIfNull: false) final List<Photo> photos;
  @JsonKey(name: 'comments', toJson: toNull, includeIfNull: false) final List<Comment> comments;

  @JsonKey(name: 'lat') final double lat;
  @JsonKey(name: 'lng') final double lng;
  LatLng get place => LatLng(lat, lng);

  Report(this.address, this.initComment, this.date, this.status, this.subs, this.type, this.lng, this.lat, this.photos, this.comments);

  factory Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);
  Map<String, dynamic> toJson() => _$ReportToJson(this);
}
