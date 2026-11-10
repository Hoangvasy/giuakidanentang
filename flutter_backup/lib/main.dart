import 'package:flutter/material.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'services/firebase_service.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo dịch vụ cơ sở dữ liệu Firebase
  final firebaseService = FirebaseService();

  // Kiểm tra trạng thái đăng nhập của Admin
  final bool loggedIn = await AuthService.isLoggedIn();

  runApp(AdminApp(
    firebaseService: firebaseService,
    initialLoggedIn: loggedIn,
  ));
}

class AdminApp extends StatelessWidget {
  final FirebaseService firebaseService;
  final bool initialLoggedIn;

  const AdminApp({
    super.key,
    required this.firebaseService,
    required this.initialLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppConstants.primaryColor,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey.withOpacity(0.04),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppConstants.primaryColor,
          brightness: Brightness.dark,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
        ),
      ),
      themeMode: ThemeMode.system,
      home: initialLoggedIn
          ? AdminDashboardScreen(firebaseService: firebaseService)
          : LoginScreen(firebaseService: firebaseService),
    );
  }
}

