import 'package:flutter/foundation.dart';
import 'package:ponto_eletronico/domain/entities/time_record_entity.dart';
import 'package:ponto_eletronico/domain/usecases/register_point_usecase.dart';

enum PointStatus { idle, loading, error, locationBlocked }

class EmployeeHomeController extends ChangeNotifier {
  final RegisterPointUsecase _registerPointUsecase;

  EmployeeHomeController(this._registerPointUsecase);

  PointStatus _status = PointStatus.idle;
  TimeRecordEntity? _todayRecord = null;
  String _errorMessage = '';

  PointStatus get status => _status;
  TimeRecordEntity? get todayRecord => _todayRecord;
  String get errorMessage     => _errorMessage;

  bool get hasEntry   => _todayRecord != null;
  bool get isOnBreak  => _todayRecord?.isOnBreak ?? false;
  bool get hasExit    => _todayRecord?.hasExit ?? false;
  bool get isComplete => _todayRecord?.isComplete ?? false;
  int get breakCount => _todayRecord?.breaks.length ?? 0;
  PunchStep get nextStep => _todayRecord?.nextStep ?? PunchStep.breakStart;

  Future<void> loadTodayRecord(String userId) async {
    _status = PointStatus.loading;
    notifyListeners();
    try {
      _todayRecord = await _registerPointUsecase.getTodayRecord(userId);
      _status = PointStatus.idle;
    } catch (_) {
      _errorMessage = 'Erro ao carregar ponto.';
      _status = PointStatus.error;
    }
    notifyListeners();
  }

  Future<PunchStep> registerPoint(String userId) async {
    _status = PointStatus.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final step = await _registerPointUsecase.execute(userId);
      _todayRecord = await _registerPointUsecase.getTodayRecord(userId);
      _status = PointStatus.idle;
      notifyListeners();
      return step;
    } on LocationPunchException catch (e) {
      _errorMessage = e.message;
      _status = PointStatus.locationBlocked;
      notifyListeners();
      return PunchStep.done;
    } catch (_) {
      _errorMessage = 'Erro ao registrar ponto.';
      _status = PointStatus.error;
      notifyListeners();
      return PunchStep.done;
    }
  }
}

