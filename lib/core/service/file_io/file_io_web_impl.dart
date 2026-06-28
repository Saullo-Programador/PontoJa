// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'file_save_result.dart';

/// Implementação web: cria um Blob, gera uma URL temporária e dispara
/// o download via um AnchorElement oculto com `download` attribute.
///
/// O browser exibirá o diálogo nativo de "Salvar como" ou gravará
/// direto na pasta de downloads conforme as configurações do usuário.
class FileIoService {
  Future<FileSaveResult> saveBytes({
    required List<int> bytes,
    required String fileName,
    String mimeType = 'application/octet-stream',
    String? subDir, // ignorado na web
  }) async {
    try {
      final blob = html.Blob([bytes], mimeType);
      final url = html.Url.createObjectUrlFromBlob(blob);

      // Cria <a href="blob:..." download="fileName"> e clica programaticamente.
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..style.display = 'none';

      html.document.body!.append(anchor);
      anchor.click();
      anchor.remove();

      // Revoga a URL logo após o clique para liberar memória.
      // O setTimeout equivalente em Dart é um microtask com Future.delayed.
      Future.delayed(const Duration(seconds: 1), () {
        html.Url.revokeObjectUrl(url);
      });

      // Na web não há path em disco; retornamos sucesso sem path.
      return FileSaveResult.ok();
    } catch (e) {
      return FileSaveResult.fail('Erro ao iniciar download: $e');
    }
  }
}