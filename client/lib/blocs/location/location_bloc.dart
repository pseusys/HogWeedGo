import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:latlong2/latlong.dart';

import 'package:client/repositories/location_repository.dart';
import 'package:client/misc/const.dart';
import 'package:client/blocs/location/location_event.dart';
import 'package:client/blocs/location/location_state.dart';


class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationRepository _locationRepository;

  late StreamSubscription<LatLng?> _locationSubscription;

  LocationBloc(this._locationRepository) : super(LocationState(STP, "")) {
    on<EnsureLocation>((event, emit) => _locationRepository.ensureLocation());
    on<LocationChanged>((event, emit) => emit(state.setMe(event.current)));

    _locationSubscription = _locationRepository.location.listen((current) => add(LocationChanged(current)));
  }

  @override
  Future<void> close() {
    _locationSubscription.cancel();
    return super.close();
  }
}
