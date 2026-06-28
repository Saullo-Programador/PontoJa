import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:ponto_eletronico/core/service/file_io/file_io_service.dart';
import 'package:ponto_eletronico/domain/entities/time_record_entity.dart';
import 'package:ponto_eletronico/domain/entities/user_entity.dart';

/// Gera e salva o relatório mensal de horas em formato .xlsx.
class ExcelExportService {
  static const int _workdayMinutes = 8 * 60; // 8 h/dia
  static const _mimeXlsx =
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

  final FileIoService _fileIo;

  ExcelExportService({FileIoService? fileIo})
      : _fileIo = fileIo ?? FileIoService();

  /// Gera o Excel e o salva/disponibiliza via [FileIoService].
  ///
  /// Retorna [FileSaveResult] com sucesso/falha e o caminho salvo
  /// (somente em mobile/desktop; null na web).
  Future<FileSaveResult> exportMonthlyReport({
    required int month,
    required int year,
    required List<UserEntity> employees,
    required List<TimeRecordEntity> records,
  }) async {
    final bytes = _buildXlsx(
      month: month,
      year: year,
      employees: employees,
      records: records,
    );

    final monthStr = '$month'.padLeft(2, '0');
    final fileName = 'relatorio_ponto_${year}_$monthStr.xlsx';

    return _fileIo.saveBytes(
      bytes: bytes,
      fileName: fileName,
      mimeType: _mimeXlsx,
      subDir: 'PontoEletronico',
    );
  }

  // ── Construção do XLSX ──────────────────────────────────────────────────

  Uint8List _buildXlsx({
    required int month,
    required int year,
    required List<UserEntity> employees,
    required List<TimeRecordEntity> records,
  }) {
    final excel = Excel.createExcel();
    final sheet = excel['Relatório'];
    excel.setDefaultSheet('Relatório');

    _writeHeader(sheet);
    _writeRows(sheet, month: month, year: year, employees: employees, records: records);

    final encoded = excel.encode();
    return Uint8List.fromList(encoded ?? []);
  }

  void _writeHeader(Sheet sheet) {
    const headers = [
      'Funcionário',
      'E-mail',
      'Dias trabalhados',
      'Horas trabalhadas',
      'Horas esperadas',
      'Hora extra',
      'Horas faltantes',
    ];

    for (var i = 0; i < headers.length; i++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
      );
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = CellStyle(bold: true);
    }
  }

  void _writeRows(
    Sheet sheet, {
    required int month,
    required int year,
    required List<UserEntity> employees,
    required List<TimeRecordEntity> records,
  }) {
    var row = 1;

    for (final emp in employees) {
      final empRecords = records
          .where((r) =>
              r.userId == emp.uid &&
              r.date.month == month &&
              r.date.year == year)
          .toList();

      final workedMinutes = empRecords.fold<int>(0, (acc, r) {
        if (r.exit == null) return acc;
        return acc + r.exit!.difference(r.entry).inMinutes;
      });

      final workedDays = empRecords.length;
      final expectedMinutes = workedDays * _workdayMinutes;
      final extraMinutes =
          (workedMinutes - expectedMinutes).clamp(-999999, 999999);

      void w(int col, CellValue v) => sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row))
          .value = v;

      w(0, TextCellValue(emp.name));
      w(1, TextCellValue(emp.email));
      w(2, IntCellValue(workedDays));
      w(3, TextCellValue(_fmt(workedMinutes)));
      w(4, TextCellValue(_fmt(expectedMinutes)));
      w(5, TextCellValue(extraMinutes >= 0 ? _fmt(extraMinutes) : '0h00'));
      w(6, TextCellValue(extraMinutes < 0 ? _fmt(-extraMinutes) : '0h00'));

      row++;
    }
  }

  String _fmt(int minutes) {
    final h = minutes ~/ 60;
    final m = (minutes % 60).toString().padLeft(2, '0');
    return '${h}h$m';
  }
}