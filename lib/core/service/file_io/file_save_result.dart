/// Resultado de uma operação de salvamento de arquivo.
class FileSaveResult {
  /// `true` se o arquivo foi salvo com êxito.
  final bool success;

  /// Caminho completo do arquivo salvo (mobile/desktop).
  /// `null` na web, onde o download é iniciado diretamente pelo browser.
  final String? path;

  /// Mensagem de erro, preenchida apenas quando [success] é `false`.
  final String? errorMessage;

  const FileSaveResult._({
    required this.success,
    this.path,
    this.errorMessage,
  });

  /// Constrói um resultado de sucesso.
  factory FileSaveResult.ok([String? path]) =>
      FileSaveResult._(success: true, path: path);

  /// Constrói um resultado de falha.
  factory FileSaveResult.fail(String message) =>
      FileSaveResult._(success: false, errorMessage: message);

  @override
  String toString() => success
      ? 'FileSaveResult.ok(path: $path)'
      : 'FileSaveResult.fail($errorMessage)';
}