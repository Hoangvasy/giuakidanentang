import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../utils/constants.dart';
import 'admin_dashboard_screen.dart';

/// Màn hình Đăng nhập Quản trị viên (Admin Login Screen)
/// Yêu cầu số 2 của đề thi: "Thực hiện đăng nhập, xóa, sửa, các chức năng nâng cao khác... (1.5 điểm)"
class LoginScreen extends StatefulWidget {
  final FirebaseService firebaseService;

  const LoginScreen({super.key, required this.firebaseService});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Tự động điền tài khoản Admin mẫu để chấm bài nhanh
  void _fillAdminCredentials() {
    setState(() {
      _emailController.text = AppConstants.defaultAdminEmail;
      _passwordController.text = AppConstants.defaultAdminPassword;
      _errorMessage = null;
    });
  }

  /// Thực hiện đăng nhập
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await AuthService.login(
      email: _emailController.text,
      password: _passwordController.text,
      dbService: widget.firebaseService,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => AdminDashboardScreen(
              firebaseService: widget.firebaseService,
            ),
          ),
        );
      } else {
        setState(() {
          _errorMessage =
              'Email hoặc mật khẩu không chính xác! (Gợi ý tài khoản admin: admin@gmail.com / admin123)';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 700;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.08),
              Theme.of(context).colorScheme.surface,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 460 : double.infinity,
              ),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Icon Logo
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.admin_panel_settings,
                              size: 48,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Tiêu đề
                        Text(
                          'Phân Hệ Quản Trị Viên',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Đăng nhập để quản lý cơ sở dữ liệu người dùng',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                        const SizedBox(height: 28),

                        // Báo lỗi nếu có
                        if (_errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.red.shade300),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: Colors.red, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(color: Colors.red, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                        ],

                        // Ô nhập Email
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            hintText: 'admin@gmail.com',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Vui lòng nhập Email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Ô nhập Mật khẩu
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Mật khẩu',
                            hintText: 'Nhập mật khẩu',
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _handleLogin(),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Vui lòng nhập Mật khẩu';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Nút Đăng nhập
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _isLoading ? null : _handleLogin,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'ĐĂNG NHẬP',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 16),

                        // Nút Đăng nhập nhanh với Admin
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.bolt, color: Colors.amber),
                          label: const Text('Điền nhanh tài khoản Admin mẫu'),
                          onPressed: _fillAdminCredentials,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

