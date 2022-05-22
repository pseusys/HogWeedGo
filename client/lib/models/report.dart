import 'package:json_annotation/json_annotation.dart';
import 'package:latlong2/latlong.dart';

import 'package:client/misc/converters.dart';
import 'package:client/models/comment.dart';
import 'package:client/models/user.dart';

part 'report.g.dart';


enum ReportStatus {
  RECEIVED, APPROVED, INVALID
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
  @JsonKey(name: 'address') final String? address;
  @JsonKey(name: 'init_comment') final String initComment;
  @JsonKey(name: 'place', toJson: latLngToObject, fromJson: latLngFromObject) final LatLng place;
  @JsonKey(name: 'date', toJson: toNull, fromJson: dateTimeFromNumber, includeIfNull: false) final DateTime date;
  @JsonKey(name: 'status', toJson: toNull, includeIfNull: false) final ReportStatus status;
  @JsonKey(name: 'subs', toJson: toNull, includeIfNull: false) final int subsID;
  @JsonKey(ignore: true, toJson: toNull, includeIfNull: false) User? subs;
  @JsonKey(name: 'id') final int id;
  @JsonKey(name: 'type') final String type;
  @JsonKey(name: 'photos', toJson: toNull, includeIfNull: false) final List<Photo> photos;
  @JsonKey(name: 'comments', toJson: toNull, includeIfNull: false) final List<Comment> comments;

  Report(this.address, this.initComment, this.place, this.date, this.status, this.subsID, this.type, this.id, this.photos, this.comments);
  Report.send(this.address, this.initComment, this.place, this.type): date = DateTime.now(), status = ReportStatus.RECEIVED, subsID = 0, id = 0, photos = [], comments = [];

  factory Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);
  Map<String, dynamic> toJson() => _$ReportToJson(this);

  Report copyWithUser(User subs) {
    var report = Report(address, initComment, place, date, status, subsID, type, id, photos, comments);
    report.subs = subs;
    return report;
  }
}
