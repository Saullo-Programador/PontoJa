// ignore: avoid_web_libraries_in_flutter
import 'dart:io';
import 'dart:typed_data';

import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import 'file_save_result.dart';

/// Implementação para Android, iOS, macOS, Windows e Linux.
///
/// Estratégia de diretório por plataforma:
/// - Android/iOS  → getApplicationDocumentsDirectory()
///   (acessível via Files / Arquivos e por compartilhamento)
/// - Desktop      → getDownloadsDirectory()
///   (pasta Downloads do SO)
///
/// Após salvar, abre o arquivo com o app padrão do SO via [OpenFilex].
class FileIoService {
  Future<FileSaveResult> saveBytes({
    required List<int> bytes,
    required String fileName,
    String mimeType = 'application/octet-stream',
    String? subDir,
  }) async {
    try {
      final dir = await _resolveDirectory(subDir);
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(Uint8List.fromList(bytes), flush: true);

      // Abre o arquivo com o app padrão do sistema operacional.
      await OpenFilex.open(file.path);

      return FileSaveResult.ok(file.path);
    } on FileSystemException catch (e) {
      return FileSaveResult.fail('Erro de sistema de arquivos: ${e.message}');
    } catch (e) {
      return FileSaveResult.fail('Erro ao salvar arquivo: $e');
    }
  }

  Future<Directory> _resolveDirectory(String? subDir) async {
    Directory base;

    if (Platform.isAndroid || Platform.isIOS) {
      base = await getApplicationDocumentsDirectory();
    } else {
      // Desktop: Windows, macOS, Linux
      base = await getDownloadsDirectory() ??
          await getApplicationDocumentsDirectory();
    }

    if (subDir != null && subDir.isNotEmpty) {
      final sub = Directory('${base.path}/$subDir');
      if (!sub.existsSync()) await sub.create(recursive: true);
      return sub;
    }

    return base;
  }
}