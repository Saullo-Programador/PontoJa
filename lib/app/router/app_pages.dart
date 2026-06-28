import 'package:flutter/material.dart';

import 'package:ponto_eletronico/app/router/app_routes.dart';
import 'package:ponto_eletronico/features/auth/view/login_screen.dart';
import 'package:ponto_eletronico/features/employee/view/employee_home_screen.dart';
import 'package:ponto_eletronico/features/manager/view/manager_home_screen.dart';
import 'package:ponto_eletronico/features/auth/view/splash_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  AppRoutes.splash:   (_) => const SplashScreen(),
  AppRoutes.login:    (_) => const LoginScreen(),
  AppRoutes.employee: (_) => const EmployeeHomeScreen(),
  AppRoutes.manager:  (_) => const ManagerHomeScreen(),
};