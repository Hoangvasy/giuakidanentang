import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/firebase_service.dart';
import '../utils/constants.dart';

/// Hộp thoại Cài đặt Kết nối Cơ sở dữ liệu (Firebase / MongoDB / Offline)
class SettingsDialog extends StatefulWidget {
  final FirebaseService firebaseService;
  final VoidCallback onConfigChanged;

  const SettingsDialog({
    super.key,
    required this.firebaseService,
    required this.onConfigChanged,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late TextEditingController _urlController;
  late TextEditingController _importJsonController;

  bool _isTesting = false;
  String? _testResult;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.firebaseService.databaseUrl);
    _importJsonController = TextEditingController();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _importJsonController.dispose();
    super.dispose();
  }

  /// Kiểm tra kết nối tới Firebase Realtime Database
  Future<void> _testConnection() async {
    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    final tempUrl = _urlController.text.trim();
    await widget.firebaseService.setDatabaseUrl(tempUrl);
    final ok = await widget.firebaseService.testConnection();

    setState(() {
      _isTesting = false;
      _isSuccess = ok;
      _testResult = ok
          ? 'Kết nối Firebase thành công! (200 OK)'
          : 'Không thể kết nối! Kiểm tra lại URL hoặc Rules (cần mở .read/.write: true)';
    });
  }

  /// Khôi phục URL mặc định
  void _resetDefault() {
    _urlController.text = AppConstants.defaultFirebaseUrl;
    widget.firebaseService.setDatabaseUrl(AppConstants.defaultFirebaseUrl);
    setState(() {
      _testResult = 'Đã khôi phục URL Firebase mặc định';
      _isSuccess = true;
    });
  }

  /// Lưu cài đặt
  Future<void> _saveSettings() async {
    await widget.firebaseService.setDatabaseUrl(_urlController.text.trim());
    widget.onConfigChanged();
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu cấu hình kết nối CSDL')),
      );
    }
  }

  /// Nhập dữ liệu JSON
  Future<void> _handleImportJson() async {
    final jsonStr = _importJsonController.text.trim();
    if (jsonStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng dán chuỗi JSON cần nhập')),
      );
      return;
    }

    final success = await widget.firebaseService.importDatabaseJson(jsonStr);
    if (mounted) {
      if (success) {
        widget.onConfigChanged();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã nhập dữ liệu CSDL từ JSON thành công!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lỗi: Cấu trúc JSON không hợp lệ!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 700;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 600 : double.infinity,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Tiêu đề
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.settings,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Cấu Hình Cơ Sở Dữ Liệu',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Nhập Firebase Database URL
                Text(
                  'URL Firebase Realtime Database:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Nhập đường link Realtime Database từ Firebase Console (kết thúc bằng .firebasedatabase.app hoặc .firebaseio.com)',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _urlController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.cloud_outlined),
                    hintText: 'https://your-project-default-rtdb.firebaseio.com',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.refresh, size: 20),
                      tooltip: 'Khôi phục mặc định',
                      onPressed: _resetDefault,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Nút Test kết nối
                Row(
                  children: [
                    ElevatedButton.icon(
                      icon: _isTesting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.network_check, size: 18),
                      label: Text(_isTesting ? 'Đang kiểm tra...' : 'Kiểm tra kết nối'),
                      onPressed: _isTesting ? null : _testConnection,
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: _resetDefault,
                      child: const Text('Mặc định'),
                    ),
                  ],
                ),

                if (_testResult != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isSuccess
                          ? Colors.green.withOpacity(0.12)
                          : Colors.red.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _isSuccess ? Colors.green : Colors.red,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isSuccess ? Icons.check_circle : Icons.error_outline,
                          color: _isSuccess ? Colors.green : Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _testResult!,
                            style: TextStyle(
                              color: _isSuccess ? Colors.green[800] : Colors.red[800],
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                const Divider(),

                // Phần Nhập / Khôi phục dữ liệu từ JSON
                Text(
                  'Nhập CSDL từ chuỗi JSON (Import JSON):',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Dán nội dung file database_users.json vào đây để nạp nhanh:',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _importJsonController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: '{\n  "users": { ... }\n}',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.file_upload_outlined, size: 18),
                    label: const Text('Nhập dữ liệu vào CSDL'),
                    onPressed: _handleImportJson,
                  ),
                ),
                const SizedBox(height: 24),

                // Nút Đóng / Lưu
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Đóng'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _saveSettings,
                      child: const Text('Lưu cấu hình'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

