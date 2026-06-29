import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Solicita permissão (se necessário) e retorna a posição atual.
  /// Lança [LocationException] se a permissão for negada ou GPS desligado.
  Future<Position> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationException(
          'O GPS está desativado. Ative-o para bater o ponto.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocationException(
            'Permissão de localização negada. Permita o acesso para bater o ponto.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
          'Permissão de localização negada permanentemente. '
          'Acesse as configurações do dispositivo para habilitar.');
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );
  }

  double distanceBetween({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) =>
      Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
}

class LocationException implements Exception {
  final String message;
  const LocationException(this.message);

  @override
  String toString() => message;
}