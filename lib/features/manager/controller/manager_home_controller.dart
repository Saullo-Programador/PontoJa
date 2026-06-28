import 'package:flutter/foundation.dart';
import 'package:ponto_eletronico/core/service/excel_export_service.dart';
import 'package:ponto_eletronico/core/service/file_io/file_save_result.dart';
import 'package:ponto_eletronico/domain/entities/time_record_entity.dart';
import 'package:ponto_eletronico/domain/entities/user_entity.dart';
import 'package:ponto_eletronico/domain/usecases/create_employee_usecase.dart';
import 'package:ponto_eletronico/domain/usecases/edit_point_usecase.dart';
import 'package:ponto_eletronico/domain/usecases/get_monthly_report_usecase.dart';
import 'package:ponto_eletronico/data/datasources/firestore_user_datasource.dart';

enum ManagerStatus { idle, loading, error }

class ManagerHomeController extends ChangeNotifier {
  final GetMonthlyReportUsecase _reportUsecase;
  final EditPointUsecase _editPointUsecase;
  final CreateEmployeeUsecase _createEmployeeUsecase;
  final _excelService = ExcelExportService();
  final _userDs = FirestoreUserDatasource();

  ManagerHomeController(
    this._reportUsecase,
    this._editPointUsecase,
    this._createEmployeeUsecase,
  );

  ManagerStatus _status = ManagerStatus.idle;
  String _error = '';
  List<UserEntity> _employees = [];
  List<TimeRecordEntity> _todayRecords = [];
  List<TimeRecordEntity> _monthlyRecords = [];

  ManagerStatus get status => _status;
  String get error => _error;
  List<UserEntity> get employees => _employees;
  List<TimeRecordEntity> get todayRecords => _todayRecords;
  List<TimeRecordEntity> get monthlyRecords => _monthlyRecords;

  Future<void> loadAll() async {
    _status = ManagerStatus.loading;
    notifyListeners();

    try {
      final now = DateTime.now();
      final results = await Future.wait([
        _userDs.getAllEmployees(),
        _reportUsecase.getTodayAll(),
        _reportUsecase.execute(month: now.month, year: now.year),
      ]);

      _employees = results[0] as List<UserEntity>;
      _todayRecords = results[1] as List<TimeRecordEntity>;
      _monthlyRecords = results[2] as List<TimeRecordEntity>;
      _status = ManagerStatus.idle;
    } catch (e) {
      _error = 'Erro ao carregar dados.';
      _status = ManagerStatus.error;
    }

    notifyListeners();
  }

  Future<void> editPoint(TimeRecordEntity record) async {
    await _editPointUsecase.execute(record);
    await loadAll();
  }

  Future<void> createEmployee({
    required String name,
    required String email,
    required String password,
    String role = 'employee',
  }) async {
    _status = ManagerStatus.loading;
    notifyListeners();

    try {
      await _createEmployeeUsecase.execute(
        name: name,
        email: email,
        password: password,
        role: role,
      );
      await loadAll();
    } catch (e) {
      _error = 'Erro ao criar usuário.';
      _status = ManagerStatus.error;
      notifyListeners();
    }
  }

  Future<FileSaveResult> exportExcelReport({required int month, required int year}) {
    return _excelService.exportMonthlyReport(
      month: month,
      year: year,
      employees: _employees,
      records: _monthlyRecords,
    );
  }

  TimeRecordEntity? getTodayRecordFor(String userId) {
    try {
      return _todayRecords.firstWhere((r) => r.userId == userId);
    } catch (_) {
      return null;
    }
  }
}