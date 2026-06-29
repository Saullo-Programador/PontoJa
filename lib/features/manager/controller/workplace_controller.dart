import 'package:flutter/foundation.dart';
import 'package:ponto_eletronico/core/service/location_service.dart';
import 'package:ponto_eletronico/data/datasources/workplace_datasource.dart';
import 'package:ponto_eletronico/data/models/workplace_model.dart';
import 'package:ponto_eletronico/domain/entities/workplace_entity.dart';

enum WorkplaceStatus { idle, loading, success, error }

class WorkplaceController extends ChangeNotifier {
  final WorkplaceDatasource _datasource;
  final LocationService _locationService;

  WorkplaceController(this._datasource, this._locationService);

  WorkplaceStatus _status = WorkplaceStatus.idle;
  WorkplaceEntity? _workplace;
  String _errorMessage = '';

  WorkplaceStatus get status       => _status;
  WorkplaceEntity? get workplace   => _workplace;
  String get errorMessage          => _errorMessage;
  bool get hasWorkplace            => _workplace != null;

  Future<void> load() async {
    _status = WorkplaceStatus.loading;
    notifyListeners();
    try {
      _workplace = await _datasource.getWorkplace();
      _status = WorkplaceStatus.idle;
    } catch (_) {
      _errorMessage = 'Erro ao carregar configuração.';
      _status = WorkplaceStatus.error;
    }
    notifyListeners();
  }

  /// Salva uma localização digitada manualmente pelo gerente.
  Future<void> saveManual({
    required String name,
    required double latitude,
    required double longitude,
    required double radiusMeters,
  }) async {
    _status = WorkplaceStatus.loading;
    notifyListeners();
    try {
      final model = WorkplaceModel(
        name: name,
        latitude: latitude,
        longitude: longitude,
        radiusMeters: radiusMeters,
      );
      await _datasource.saveWorkplace(model);
      _workplace = model;
      _status = WorkplaceStatus.success;
    } catch (_) {
      _errorMessage = 'Erro ao salvar localização.';
      _status = WorkplaceStatus.error;
    }
    notifyListeners();
  }

  /// Usa o GPS atual do gerente como localização do trabalho.
  Future<void> saveCurrentLocation({
    required String name,
    required double radiusMeters,
  }) async {
    _status = WorkplaceStatus.loading;
    notifyListeners();
    try {
      final position = await _locationService.getCurrentPosition();
      final model = WorkplaceModel(
        name: name,
        latitude: position.latitude,
        longitude: position.longitude,
        radiusMeters: radiusMeters,
      );
      await _datasource.saveWorkplace(model);
      _workplace = model;
      _status = WorkplaceStatus.success;
    } on LocationException catch (e) {
      _errorMessage = e.message;
      _status = WorkplaceStatus.error;
    } catch (_) {
      _errorMessage = 'Erro ao obter localização.';
      _status = WorkplaceStatus.error;
    }
    notifyListeners();
  }
}