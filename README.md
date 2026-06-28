# Ponto Eletrônico

Sistema de controle de ponto eletrônico desenvolvido com **Flutter + Firebase**, com dois perfis de acesso: **Funcionário** (somente app mobile) e **Gerente** (app mobile + web).

---

## Funcionalidades

### Funcionário (mobile)
- Login com e-mail e senha
- Visualização do status do ponto do dia (entrada / saída)
- Registro de entrada e saída com um toque
- Tema claro / escuro

### Gerente (mobile + web)
- Login com e-mail e senha
- Listagem de todos os funcionários com status do ponto do dia
- Visualização dos registros mensais de cada funcionário
- Edição de horários de entrada e saída
- Cadastro de novos funcionários ou gerentes
- Exportação de relatório mensal em `.xlsx` com horas trabalhadas, esperadas e extras
- Tema claro / escuro

---

## Arquitetura

O projeto segue **Clean Architecture** com organização **Feature-first**, padrão adotado em times profissionais no mercado Flutter.

```
lib/
├── main.dart                          # Entrada + MultiProvider + AuthGuard
├── app/
│   ├── di/injection.dart              # Injeção de dependências (IoC)
│   └── router/
│       ├── app_pages.dart             # Mapa de rotas
│       └── app_routes.dart            # Constantes de rota
│
├── core/                              # Infraestrutura compartilhada
│   ├── constants/firestore_constants.dart
│   ├── exceptions/app_exception.dart  # AuthException, DataException…
│   ├── service/
│   │   ├── excel_export_service.dart
│   │   └── file_io/                   # I/O multiplataforma
│   │       ├── file_io_service.dart   # Conditional import (entry point)
│   │       ├── file_io_stub.dart      # Fallback / interface
│   │       ├── file_io_io_impl.dart   # Mobile + Desktop (path_provider)
│   │       ├── file_io_web_impl.dart  # Web (dart:html Blob download)
│   │       └── file_save_result.dart  # Value object de resultado
│   └── utils/
│       ├── date_utils.dart            # Extensions em DateTime
│       └── validators.dart
│
├── domain/                            # Regras de negócio puras
│   ├── entities/
│   │   ├── user_entity.dart
│   │   └── time_record_entity.dart
│   ├── repositories/                  # Contratos (interfaces abstratas)
│   │   ├── i_auth_repository.dart
│   │   ├── i_time_record_repository.dart
│   │   └── i_user_repository.dart
│   └── usecases/
│       ├── register_point_usecase.dart
│       ├── get_monthly_report_usecase.dart
│       ├── edit_point_usecase.dart
│       └── create_employee_usecase.dart
│
├── data/                              # Implementações concretas (Firebase)
│   ├── datasources/
│   │   ├── firebase_auth_datasource.dart
│   │   ├── firestore_user_datasource.dart
│   │   └── firestore_point_datasource.dart
│   ├── models/                        # DTOs com fromFirestore / toMap
│   │   ├── user_model.dart
│   │   └── time_record_model.dart
│   └── repositories/
│       ├── auth_repository_impl.dart
│       ├── user_repository_impl.dart
│       └── time_record_repository_impl.dart
│
├── features/
│   ├── auth/
│   │   ├── controller/login_controller.dart
│   │   └── view/
│   │       ├── splash_screen.dart
│   │       ├── login_screen.dart      # Responsivo (mobile / web)
│   │       └── first_setup_screen.dart # Primeiro acesso (sem usuários)
│   ├── employee/
│   │   ├── controller/employee_home_controller.dart
│   │   └── view/employee_home_screen.dart
│   └── manager/
│       ├── controller/manager_home_controller.dart
│       └── view/
│           ├── manager_home_screen.dart
│           ├── edit_point_dialog.dart
│           └── create_employee_dialog.dart
│
└── shared/
    ├── theme/
    │   ├── app_theme.dart             # ThemeData claro e escuro
    │   └── theme_controller.dart      # Gerencia ThemeMode + SharedPreferences
    └── widgets/
        ├── responsive_layout.dart     # Alterna mobile / desktop
        ├── custom_button.dart
        ├── custom_input.dart
        ├── loading_widget.dart
        └── theme_toggle_button.dart   # Botão claro/escuro do AppBar
```

---

## Fluxo de navegação

```
SplashScreen
 ├── Firestore vazio         → FirstSetupScreen (cria gerente master)
 ├── sem sessão              → LoginScreen
 ├── logado + manager        → ManagerHomeScreen  (mobile e web)
 ├── logado + employee       → EmployeeHomeScreen (somente mobile)
 └── logado + employee + web → LoginScreen (acesso bloqueado)
```

O `_AuthGuard` no `main.dart` ouve o stream `authStateChanges()` e redireciona para o login automaticamente caso a sessão expire ou o logout seja feito em outro dispositivo.

---

## Firestore — estrutura das coleções

```
users/{uid}
  name:   string
  email:  string
  role:   "employee" | "manager"

time_records/{auto-id}
  userId: string     (uid do funcionário)
  date:   timestamp  (início do dia — usado nas queries de intervalo)
  entry:  timestamp
  exit:   timestamp | null
```

---

## Dependências

| Pacote | Versão | Uso |
|--------|--------|-----|
| `firebase_core` | ^4.11.0 | Inicialização do Firebase |
| `firebase_auth` | ^6.5.4 | Autenticação |
| `cloud_firestore` | ^6.6.0 | Banco de dados |
| `provider` | ^6.1.5+1 | Gerenciamento de estado |
| `excel` | ^4.0.6 | Geração do relatório .xlsx |
| `path_provider` | ^2.1.5 | Diretório de destino (mobile/desktop) |
| `open_filex` | ^1.4.0 | Abre o arquivo após salvar |
| `shared_preferences` | ^2.3.2 | Persistência do tema escolhido |
| `geolocator` | ^13.0.4 | Localização ao bater ponto (opcional) |

**Dev:**

| Pacote | Uso |
|--------|-----|
| `mockito` | Geração de mocks para testes |
| `build_runner` | Geração de código (`mocks.mocks.dart`) |
| `flutter_lints` | Análise estática |

---

## Como configurar

### 1. Firebase
```bash
# Instale o FlutterFire CLI (se ainda não tiver)
dart pub global activate flutterfire_cli

# Configure o projeto (gera firebase_options.dart)
flutterfire configure
```

Ative no console do Firebase:
- **Authentication** → método E-mail/Senha
- **Firestore Database** → modo produção (ajuste as regras abaixo)

### 2. Regras do Firestore recomendadas
```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Somente usuários autenticados leem/escrevem o próprio perfil
    match /users/{uid} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
      // Gerente pode ler todos
      allow read: if request.auth != null
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'manager';
    }

    // Registros de ponto
    match /time_records/{recordId} {
      // Funcionário lê/escreve apenas os seus
      allow read, write: if request.auth != null
        && resource.data.userId == request.auth.uid;
      // Gerente lê e edita qualquer registro
      allow read, write: if request.auth != null
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'manager';
    }
  }
}
```

### 3. Instalar e rodar
```bash
flutter pub get
flutter run
```

---

## Testes

```
test/
├── mocks.dart                          # @GenerateMocks — gera mocks automáticos
├── mocks.mocks.dart                    # gerado pelo build_runner
├── unit/
│   ├── models/
│   │   ├── time_record_entity_test.dart
│   │   ├── user_entity_test.dart
│   │   ├── validators_test.dart
│   │   └── date_utils_test.dart
│   ├── usecases/
│   │   ├── register_point_usecase_test.dart
│   │   ├── edit_point_usecase_test.dart
│   │   ├── create_employee_usecase_test.dart
│   │   └── get_monthly_report_usecase_test.dart
│   └── controllers/
│       ├── employee_home_controller_test.dart
│       └── theme_controller_test.dart
└── widget/
    ├── login_screen_test.dart
    └── employee_home_screen_test.dart
```

### Gerar mocks e rodar
```bash
# 1. Gera mocks.mocks.dart
flutter pub run build_runner build --delete-conflicting-outputs

# 2. Roda todos os testes
flutter test

# 3. Roda com cobertura
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## Tema claro / escuro

O app suporta tema claro, escuro e segue o sistema por padrão. A escolha é persistida com `SharedPreferences` e pode ser alterada pelo botão 🌙 / ☀️ no AppBar de qualquer tela logada.