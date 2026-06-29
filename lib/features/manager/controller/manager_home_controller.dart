import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:ponto_eletronico/core/service/excel_export_service.dart';
import 'package:ponto_eletronico/core/service/file_io/file_save_result.dart';
import 'package:ponto_eletronico/domain/entities/time_record_entity.dart';
import 'package:ponto_eletronico/domain/entities/user_entity.dart';
import 'package:ponto_eletronico/domain/usecases/create_employee_usecase.dart';
import 'package:ponto_eletronico/domain/usecases/delete_point_usecase.dart';
import 'package:ponto_eletronico/domain/usecases/edit_point_usecase.dart';
import 'package:ponto_eletronico/domain/usecases/get_monthly_report_usecase.dart';
import 'package:ponto_eletronico/data/datasources/firestore_user_datasource.dart';

enum ManagerStatus { idle, loading, error }

class ManagerHomeController extends ChangeNotifier {
  final GetMonthlyReportUsecase _reportUsecase;
  final EditPointUsecase _editPointUsecase;
  final DeletePointUsecase _deletePointUsecase;
  final CreateEmployeeUsecase _createEmployeeUsecase;
  final _excelService = ExcelExportService();
  final _userDs = FirestoreUserDatasource();

  // Subscriptions dos streams — canceladas no dispose()
  StreamSubscription<List<TimeRecordEntity>>? _todaySub;
  StreamSubscription<List<TimeRecordEntity>>? _monthlySub;

  ManagerHomeController(
    this._reportUsecase,
    this._deletePointUsecase,
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

  /// Inicia os streams em tempo real.
  /// Chamado uma vez no initState da tela — os dados se atualizam
  /// automaticamente sempre que um funcionário bate o ponto.
  Future<void> loadAll() async {
    _status = ManagerStatus.loading;
    notifyListeners();

    try {
      // Funcionários: lista estática (muda só quando criar/editar usuário)
      _employees = await _userDs.getAllEmployees();

      final now = DateTime.now();

      // ── Stream: ponto do dia ─────────────────────────────────────────
      _todaySub?.cancel();
      _todaySub = _reportUsecase.watchTodayAll().listen(
        (records) {
          _todayRecords = records;
          _status = ManagerStatus.idle;
          notifyListeners(); // ← UI atualiza automaticamente
        },
        onError: (_) {
          _error = 'Erro ao ouvir registros do dia.';
          _status = ManagerStatus.error;
          notifyListeners();
        },
      );

      // ── Stream: ponto do mês ─────────────────────────────────────────
      _monthlySub?.cancel();
      _monthlySub = _reportUsecase
          .watchMonthly(month: now.month, year: now.year)
          .listen(
        (records) {
          _monthlyRecords = records;
          notifyListeners();
        },
        onError: (_) {
          _error = 'Erro ao ouvir registros do mês.';
          _status = ManagerStatus.error;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = 'Erro ao inicializar dados.';
      _status = ManagerStatus.error;
      notifyListeners();
    }
  }

  Future<void> editPoint(TimeRecordEntity record) async {
    await _editPointUsecase.execute(record);
    // Não precisa chamar loadAll() — os streams atualizam sozinhos
  }

  Future<void> deletePoint(TimeRecordEntity record) async {
    await _deletePointUsecase.execute(record);
    // Não precisa chamar loadAll() — os streams atualizam sozinhos
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
      // Recarrega lista de funcionários (não é stream)
      _employees = await _userDs.getAllEmployees();
      _status = ManagerStatus.idle;
    } catch (e) {
      _error = 'Erro ao criar usuário.';
      _status = ManagerStatus.error;
    }

    notifyListeners();
  }

  Future<FileSaveResult> exportExcelReport({
    required int month,
    required int year,
  }) {
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

  /// Cancela os streams ao descartar o controller.
  @override
  void dispose() {
    _todaySub?.cancel();
    _monthlySub?.cancel();
    super.dispose();
  }
}