
export 'file_save_result.dart';

// Seleciona implementação de plataforma em compile time.
export 'file_io_stub.dart'
    if (dart.library.html) 'file_io_web_impl.dart'
    if (dart.library.io) 'file_io_io_impl.dart';