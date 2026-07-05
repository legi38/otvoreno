import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationResult {
  const LocationResult.success(this.location) : error = null;
  const LocationResult.failure(this.error) : location = null;

  final LatLng? location;
  final String? error;

  bool get isSuccess => location != null;
}

class LocationService {
  Future<LocationResult> getCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        return const LocationResult.failure('Lokacija nije uključena na uređaju.');
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return const LocationResult.failure('Dozvola za lokaciju nije odobrena.');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return LocationResult.success(
        LatLng(position.latitude, position.longitude),
      );
    } catch (_) {
      return const LocationResult.failure('Greška kod dohvaćanja lokacije.');
    }
  }
}
