import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';


abstract class ReportEvent {
  const ReportEvent();
}

class ReportAddressChanged extends ReportEvent {
  final String address;
  const ReportAddressChanged(this.address);
}

class ReportCommentChanged extends ReportEvent {
  final String comment;
  const ReportCommentChanged(this.comment);
}

class ReportPlaceChanged extends ReportEvent {
  final LatLng place;
  const ReportPlaceChanged(this.place);
}

class ReportPhotosChanged extends ReportEvent {
  final List<XFile> photos;
  const ReportPhotosChanged(this.photos);
}

class ReportSubmitted extends ReportEvent {
  const ReportSubmitted();
}
