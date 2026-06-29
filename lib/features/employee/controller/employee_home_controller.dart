import 'package:flutter/foundation.dart';
import 'package:ponto_eletronico/domain/entities/time_record_entity.dart';
import 'package:ponto_eletronico/domain/usecases/register_point_usecase.dart';

enum PointStatus { idle, loading, error }

class EmployeeHomeController extends ChangeNotifier {
  final RegisterPointUsecase _registerPointUsecase;

  EmployeeHomeController(this._registerPointUsecase);

  PointStatus _status = PointStatus.idle;
  TimeRecordEntity? _todayRecord;
  String _errorMessage = '';

  PointStatus get status => _status;
  TimeRecordEntity? get todayRecord => _todayRecord;
  String get errorMessage => _errorMessage;

  bool get hasEntry      => _todayRecord != null;
  bool get isOnBreak     => _todayRecord?.isOnBreak ?? false;
  bool get hasExit       => _todayRecord?.hasExit ?? false;
  bool get isComplete    => _todayRecord?.isComplete ?? false;
  PunchStep get nextStep => _todayRecord?.nextStep ?? PunchStep.breakStart;

  Future<void> loadTodayRecord(String userId) async {
    _status = PointStatus.loading;
    notifyListeners();

    try {
      _todayRecord = await _registerPointUsecase.getTodayRecord(userId);
      _status = PointStatus.idle;
    } catch (e) {
      _errorMessage = 'Erro ao carregar ponto.';
      _status = PointStatus.error;
    }

    notifyListeners();
  }

  /// Avança o ponto para a próxima etapa e retorna qual etapa foi concluída.
  Future<PunchStep> registerPoint(String userId) async {
    _status = PointStatus.loading;
    notifyListeners();

    try {
      final completedStep = await _registerPointUsecase.execute(userId);
      _todayRecord = await _registerPointUsecase.getTodayRecord(userId);
      _status = PointStatus.idle;
      notifyListeners();
      return completedStep;
    } catch (e) {
      _errorMessage = 'Erro ao registrar ponto.';
      _status = PointStatus.error;
      notifyListeners();
      return PunchStep.done;
    }
  }
}