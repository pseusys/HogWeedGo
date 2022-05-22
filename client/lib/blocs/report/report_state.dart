import 'package:formz/formz.dart';
import 'package:latlong2/latlong.dart';

import 'package:client/blocs/report/report_form.dart';


class ReportState {
  final FormzStatus status;
  final Address address;
  final Comment comment;
  final List<Image> photos;
  final int probability;
  final LatLng place;

  const ReportState(this.place, this.photos, {
    this.status = FormzStatus.pure,
    this.address = const Address.pure(),
    this.comment = const Comment.pure(),
    this.probability = 0
  });

  ReportState copyWith({FormzStatus? status, Address? address, Comment? comment, List<Image>? photos, LatLng? place}) => ReportState(
    place ?? this.place,
    photos ?? this.photos,
    status: status ?? this.status,
    address: address ?? this.address,
    comment: comment ?? this.comment,
    probability: photos != null ? (photos.fold<int>(0, (previousValue, element) => previousValue + element.value.second) / photos.length).round() : probability,
  );
}
