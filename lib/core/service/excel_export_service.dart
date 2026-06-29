
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:ponto_eletronico/core/service/file_io/file_io_service.dart';
import 'package:ponto_eletronico/domain/entities/time_record_entity.dart';
import 'package:ponto_eletronico/domain/entities/user_entity.dart';

class ExcelExportService {
  static const int _workdayMinutes = 8 * 60;

  static const _mimeXlsx =
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

  final FileIoService _fileIo;

  ExcelExportService({FileIoService? fileIo})
      : _fileIo = fileIo ?? FileIoService();

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

  Uint8List _buildXlsx({
    required int month,
    required int year,
    required List<UserEntity> employees,
    required List<TimeRecordEntity> records,
  }) {
    final excel = Excel.createExcel();
    final sheet = excel['Relatório'];

    excel.setDefaultSheet('Relatório');

    _writeTitle(sheet, month, year);
    _writeHeader(sheet);

    _writeRows(
      sheet,
      month: month,
      year: year,
      employees: employees,
      records: records,
    );

    _configureColumns(sheet);

    final encoded = excel.encode();

    return Uint8List.fromList(encoded ?? []);
  }

  void _writeTitle(Sheet sheet, int month, int year) {
    sheet.merge(
      CellIndex.indexByString("A1"),
      CellIndex.indexByString("G1"),
    );

    final title = sheet.cell(
      CellIndex.indexByString("A1"),
    );

    title.value = TextCellValue(
      'RELATÓRIO MENSAL DE PONTO - $month/$year',
    );

    title.cellStyle = CellStyle(
      bold: true,
      fontSize: 18,
      horizontalAlign: HorizontalAlign.Center,
    );

    sheet.merge(
      CellIndex.indexByString("A2"),
      CellIndex.indexByString("G2"),
    );

    final subtitle = sheet.cell(
      CellIndex.indexByString("A2"),
    );

    subtitle.value = TextCellValue(
      'Gerado automaticamente pelo sistema',
    );

    subtitle.cellStyle = CellStyle(
      italic: true,
      horizontalAlign: HorizontalAlign.Center,
    );
  }

  void _writeHeader(Sheet sheet) {
    const headers = [
      'Funcionário',
      'E-mail',
      'Dias',
      'Horas Trabalhadas',
      'Horas Esperadas',
      'Hora Extra',
      'Horas Faltantes',
    ];

    for (var i = 0; i < headers.length; i++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(
          columnIndex: i,
          rowIndex: 3,
        ),
      );

      cell.value = TextCellValue(headers[i]);

      cell.cellStyle = CellStyle(
        bold: true,
        fontColorHex: ExcelColor.white,
        backgroundColorHex: ExcelColor.blue,
        horizontalAlign: HorizontalAlign.Center,
      );
    }
  }

  void _writeRows(
    Sheet sheet, {
    required int month,
    required int year,
    required List<UserEntity> employees,
    required List<TimeRecordEntity> records,
  }) {
    int row = 4;

    int totalDays = 0;
    int totalWorked = 0;
    int totalExtra = 0;
    int totalMissing = 0;

    for (final emp in employees) {
      final empRecords = records.where((r) {
        return r.userId == emp.uid &&
            r.date.month == month &&
            r.date.year == year;
      }).toList();

      final workedMinutes = empRecords.fold<int>(0, (acc, r) {
        if (r.exit == null) return acc;

        return acc + r.exit!.difference(r.entry).inMinutes;
      });

      final workedDays = empRecords.length;

      final expectedMinutes =
          workedDays * _workdayMinutes;

      final difference =
          workedMinutes - expectedMinutes;

      final extra =
          difference > 0 ? difference : 0;

      final missing =
          difference < 0 ? -difference : 0;

      totalDays += workedDays;
      totalWorked += workedMinutes;
      totalExtra += extra;
      totalMissing += missing;

      sheet
          .cell(CellIndex.indexByColumnRow(
            columnIndex: 0,
            rowIndex: row,
          ))
          .value = TextCellValue(emp.name);

      sheet
          .cell(CellIndex.indexByColumnRow(
            columnIndex: 1,
            rowIndex: row,
          ))
          .value = TextCellValue(emp.email);

      final daysCell = sheet.cell(
        CellIndex.indexByColumnRow(
          columnIndex: 2,
          rowIndex: row,
        ),
      );

      daysCell.value = IntCellValue(workedDays);

      daysCell.cellStyle = CellStyle(
        horizontalAlign: HorizontalAlign.Center,
      );

      sheet
          .cell(CellIndex.indexByColumnRow(
            columnIndex: 3,
            rowIndex: row,
          ))
          .value = TextCellValue(
        _fmt(workedMinutes),
      );

      sheet
          .cell(CellIndex.indexByColumnRow(
            columnIndex: 4,
            rowIndex: row,
          ))
          .value = TextCellValue(
        _fmt(expectedMinutes),
      );

      final extraCell = sheet.cell(
        CellIndex.indexByColumnRow(
          columnIndex: 5,
          rowIndex: row,
        ),
      );

      extraCell.value =
          TextCellValue(_fmt(extra));

      extraCell.cellStyle = CellStyle(
        fontColorHex: ExcelColor.green,
        bold: true,
        horizontalAlign: HorizontalAlign.Center,
      );

      final missingCell = sheet.cell(
        CellIndex.indexByColumnRow(
          columnIndex: 6,
          rowIndex: row,
        ),
      );

      missingCell.value =
          TextCellValue(_fmt(missing));

      missingCell.cellStyle = CellStyle(
        fontColorHex: ExcelColor.red,
        bold: true,
        horizontalAlign: HorizontalAlign.Center,
      );

      row++;
    }

    for (int col = 0; col < 7; col++) {
      sheet.cell(
        CellIndex.indexByColumnRow(
          columnIndex: col,
          rowIndex: row,
        ),
      ).cellStyle = CellStyle(
        backgroundColorHex: ExcelColor.green,
        bold: true,
      );
    }

    sheet.cell(
      CellIndex.indexByColumnRow(
        columnIndex: 0,
        rowIndex: row,
      ),
    ).value = TextCellValue('TOTAL');

    sheet.cell(
      CellIndex.indexByColumnRow(
        columnIndex: 2,
        rowIndex: row,
      ),
    ).value = IntCellValue(totalDays);

    sheet.cell(
      CellIndex.indexByColumnRow(
        columnIndex: 3,
        rowIndex: row,
      ),
    ).value = TextCellValue(
      _fmt(totalWorked),
    );

    sheet.cell(
      CellIndex.indexByColumnRow(
        columnIndex: 5,
        rowIndex: row,
      ),
    ).value = TextCellValue(
      _fmt(totalExtra),
    );

    sheet.cell(
      CellIndex.indexByColumnRow(
        columnIndex: 6,
        rowIndex: row,
      ),
    ).value = TextCellValue(
      _fmt(totalMissing),
    );
  }

  void _configureColumns(Sheet sheet) {
    sheet.setColumnWidth(0, 28);
    sheet.setColumnWidth(1, 35);
    sheet.setColumnWidth(2, 15);
    sheet.setColumnWidth(3, 20);
    sheet.setColumnWidth(4, 20);
    sheet.setColumnWidth(5, 18);
    sheet.setColumnWidth(6, 18);
  }

  String _fmt(int minutes) {
    final h = minutes ~/ 60;
    final m =
        (minutes % 60).toString().padLeft(2, '0');

    return '${h}h$m';
  }
}
