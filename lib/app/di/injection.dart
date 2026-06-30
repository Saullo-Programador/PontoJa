import 'package:ponto_eletronico/core/service/location_service.dart';
import 'package:ponto_eletronico/data/datasources/workplace_datasource.dart';
import 'package:ponto_eletronico/domain/usecases/check_location_usecase.dart';
import 'package:ponto_eletronico/domain/usecases/delete_employee_usecase.dart';
import 'package:ponto_eletronico/domain/usecases/delete_point_usecase.dart';
import 'package:ponto_eletronico/domain/usecases/update_employee_usecase.dart';
import 'package:ponto_eletronico/features/manager/controller/workplace_controller.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'package:ponto_eletronico/data/datasources/firebase_auth_datasource.dart';
import 'package:ponto_eletronico/data/datasources/firestore_point_datasource.dart';
import 'package:ponto_eletronico/data/datasources/firestore_user_datasource.dart';
import 'package:ponto_eletronico/data/repositories/auth_repository_impl.dart';
import 'package:ponto_eletronico/data/repositories/time_record_repository_impl.dart';
import 'package:ponto_eletronico/data/repositories/user_repository_impl.dart';
import 'package:ponto_eletronico/domain/usecases/create_employee_usecase.dart';
import 'package:ponto_eletronico/domain/usecases/edit_point_usecase.dart';
import 'package:ponto_eletronico/domain/usecases/get_monthly_report_usecase.dart';
import 'package:ponto_eletronico/domain/usecases/register_point_usecase.dart';
import 'package:ponto_eletronico/features/auth/controller/login_controller.dart';
import 'package:ponto_eletronico/features/employee/controller/employee_home_controller.dart';
import 'package:ponto_eletronico/features/manager/controller/manager_home_controller.dart';

List<SingleChildWidget> appProviders = [
  // ── Datasources ──────────────────────────────────────────
  Provider(create: (_) => FirebaseAuthDatasource()),
  Provider(create: (_) => FirestoreUserDatasource()),
  Provider(create: (_) => FirestorePointDatasource()),
  Provider(create: (_) => WorkplaceDatasource()),
  Provider(create: (_) => LocationService()),

  // ── Repositories ─────────────────────────────────────────
  ProxyProvider<FirebaseAuthDatasource, AuthRepositoryImpl>(
    update: (_, ds, __) => AuthRepositoryImpl(ds),
  ),
  ProxyProvider<FirestoreUserDatasource, UserRepositoryImpl>(
    update: (_, ds, __) => UserRepositoryImpl(ds),
  ),
  ProxyProvider<FirestorePointDatasource, TimeRecordRepositoryImpl>(
    update: (_, ds, __) => TimeRecordRepositoryImpl(ds),
  ),

  // ── Use cases ────────────────────────────────────────────
  ProxyProvider2<WorkplaceDatasource, LocationService, CheckLocationUsecase>(
    update: (_, wp, loc, __) => CheckLocationUsecase(wp, loc),
  ),
  ProxyProvider2<
    TimeRecordRepositoryImpl,
    CheckLocationUsecase,
    RegisterPointUsecase
  >(
    update: (_, repo, check, __) =>
        RegisterPointUsecase(repo, checkLocation: check),
  ),
  ProxyProvider<TimeRecordRepositoryImpl, GetMonthlyReportUsecase>(
    update: (_, repo, __) => GetMonthlyReportUsecase(repo),
  ),
  ProxyProvider<TimeRecordRepositoryImpl, EditPointUsecase>(
    update: (_, repo, __) => EditPointUsecase(repo),
  ),
  ProxyProvider<TimeRecordRepositoryImpl, DeletePointUsecase>(
    update: (_, repo, __) => DeletePointUsecase(repo),
  ),
  ProxyProvider<UserRepositoryImpl, CreateEmployeeUsecase>(
    update: (_, repo, __) => CreateEmployeeUsecase(repo),
  ),
  ProxyProvider<UserRepositoryImpl, UpdateEmployeeUsecase>(
    update: (_, repo, __) => UpdateEmployeeUsecase(repo),
  ),
  ProxyProvider<UserRepositoryImpl, DeleteEmployeeUsecase>(
    update: (_, repo, __) => DeleteEmployeeUsecase(repo),
  ),

  // ── Controllers (ChangeNotifierProvider) ─────────────────
  ChangeNotifierProxyProvider2<
    AuthRepositoryImpl,
    UserRepositoryImpl,
    LoginController
  >(
    create: (_) => LoginController(
      AuthRepositoryImpl(FirebaseAuthDatasource()),
      UserRepositoryImpl(FirestoreUserDatasource()),
    ),
    update: (_, auth, user, __) => LoginController(auth, user),
  ),
  ChangeNotifierProxyProvider<RegisterPointUsecase, EmployeeHomeController>(
    create: (context) =>
        EmployeeHomeController(context.read<RegisterPointUsecase>()),
    update: (_, uc, controller) => controller ?? EmployeeHomeController(uc),
  ),
  ChangeNotifierProxyProvider6<
    GetMonthlyReportUsecase,
    EditPointUsecase,
    DeletePointUsecase,
    CreateEmployeeUsecase,
    UpdateEmployeeUsecase,
    DeleteEmployeeUsecase,
    ManagerHomeController
  >(
    create: (context) => ManagerHomeController(
      context.read<GetMonthlyReportUsecase>(),
      context.read<DeletePointUsecase>(),
      context.read<DeleteEmployeeUsecase>(),
      context.read<EditPointUsecase>(),
      context.read<UpdateEmployeeUsecase>(),
      context.read<CreateEmployeeUsecase>(),
    ),
    update:
        (
          _,
          report,
          edit,
          delete,
          createEmployee,
          updateEmployee,
          deleteEmployee,
          controller,
        ) =>
            controller ??
            ManagerHomeController(
              report,
              delete,
              deleteEmployee,
              edit,
              updateEmployee,
              createEmployee,
            ),
  ),
  ChangeNotifierProxyProvider2<
    WorkplaceDatasource,
    LocationService,
    WorkplaceController
  >(
    create: (_) =>
        WorkplaceController(WorkplaceDatasource(), LocationService()),
    update: (_, ds, loc, __) => WorkplaceController(ds, loc),
  ),
];
