import 'file_save_result.dart';

/// Stub usado como fallback e como referência de interface.
/// Em produção, o conditional export em file_io_service.dart
/// substitui por file_io_io_impl.dart ou file_io_web_impl.dart.
class FileIoService {
  /// Salva [bytes] em disco (mobile/desktop) ou dispara download (web).
  ///
  /// [fileName]  Nome do arquivo com extensão, ex.: `relatorio_junho.xlsx`.
  /// [mimeType]  MIME type do arquivo.
  /// [subDir]    Subdiretório opcional dentro de Downloads/Documents.
  Future<FileSaveResult> saveBytes({
    required List<int> bytes,
    required String fileName,
    String mimeType = 'application/octet-stream',
    String? subDir,
  }) async {
    return FileSaveResult.fail('FileIoService: plataforma não suportada.');
  }
}