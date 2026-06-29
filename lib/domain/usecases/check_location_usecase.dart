import 'package:ponto_eletronico/core/service/location_service.dart';
import 'package:ponto_eletronico/data/datasources/workplace_datasource.dart';
import 'package:ponto_eletronico/domain/entities/workplace_entity.dart';

class LocationCheckResult {
  final bool allowed;
  final double? distanceMeters;
  final String? errorMessage;

  const LocationCheckResult._({
    required this.allowed,
    this.distanceMeters,
    this.errorMessage,
  });

  factory LocationCheckResult.ok(double distance) =>
      LocationCheckResult._(allowed: true, distanceMeters: distance);

  factory LocationCheckResult.blocked(String message, [double? distance]) =>
      LocationCheckResult._(
          allowed: false,
          distanceMeters: distance,
          errorMessage: message);
}

class CheckLocationUsecase {
  final WorkplaceDatasource _workplaceDs;
  final LocationService _locationService;

  CheckLocationUsecase(this._workplaceDs, this._locationService);

  Future<LocationCheckResult> execute() async {
    // Se não há localização configurada, libera (gerente ainda não configurou)
    final workplace = await _workplaceDs.getWorkplace();
    if (workplace == null) return LocationCheckResult.ok(0);

    try {
      final position = await _locationService.getCurrentPosition();

      final distance = _locationService.distanceBetween(
        startLat: position.latitude,
        startLng: position.longitude,
        endLat: workplace.latitude,
        endLng: workplace.longitude,
      );

      if (distance <= workplace.radiusMeters) {
        return LocationCheckResult.ok(distance);
      }

      return LocationCheckResult.blocked(
        'Você está a ${distance.toStringAsFixed(0)} m do local de trabalho.\n'
        'Máximo permitido: ${workplace.radiusMeters.toStringAsFixed(0)} m.',
        distance,
      );
    } on LocationException catch (e) {
      return LocationCheckResult.blocked(e.message);
    } catch (_) {
      return LocationCheckResult.blocked(
          'Não foi possível obter sua localização. Tente novamente.');
    }
  }

  Future<WorkplaceEntity?> getWorkplace() => _workplaceDs.getWorkplace();
}