import 'package:mockito/annotations.dart';
import 'package:ponto_eletronico/domain/repositories/i_auth_repository.dart';
import 'package:ponto_eletronico/domain/repositories/i_time_record_repository.dart';
import 'package:ponto_eletronico/domain/repositories/i_user_repository.dart';

@GenerateMocks([
  IAuthRepository,
  ITimeRecordRepository,
  IUserRepository,
])
void main() {}