/// Serviço de I/O de arquivos com suporte a mobile, desktop e web.
///
/// O import condicional seleciona automaticamente a implementação correta
/// em tempo de compilação:
///   - `dart:html` disponível  → web_impl.dart  (usa AnchorElement + Blob)
///   - caso contrário           → io_impl.dart   (usa path_provider + open_filex)
///
/// Uso:
/// ```dart
/// final service = FileIoService();
/// final result = await service.saveBytes(
///   bytes: xlsxBytes,
///   fileName: 'relatorio_junho_2025.xlsx',
///   mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
/// );
/// if (result.success) print('Salvo em ${result.path}');
/// ```
library file_io_service;

export 'file_save_result.dart';

// Seleciona implementação de plataforma em compile time.
export 'file_io_stub.dart'
    if (dart.library.html) 'file_io_web_impl.dart'
    if (dart.library.io) 'file_io_io_impl.dart';