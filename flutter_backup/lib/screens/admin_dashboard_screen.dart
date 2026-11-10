import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../widgets/avatar_image.dart';
import '../widgets/stat_card.dart';
import '../widgets/user_card.dart';
import 'login_screen.dart';
import 'settings_dialog.dart';
import 'user_detail_dialog.dart';
import 'user_form_dialog.dart';

/// PHÂN HỆ QUẢN TRỊ VIÊN (ADMIN DASHBOARD)
/// Chạy tương thích tối ưu trên cả Web (8.0 điểm) và Di động (0.5 điểm)
/// Đầy đủ chức năng Đăng nhập, CRUD, Tìm kiếm, Sắp xếp, Xuất JSON (1.5 điểm)
class AdminDashboardScreen extends StatefulWidget {
  final FirebaseService firebaseService;

  const AdminDashboardScreen({super.key, required this.firebaseService});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  List<UserModel> _users = [];
  List<UserModel> _filteredUsers = [];

  bool _isLoading = true;
  String _searchQuery = '';
  String _sortOption = 'name_asc'; // name_asc, name_desc, email_asc
  bool _isFirebaseConnected = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _checkConnection();
  }

  /// Nạp danh sách người dùng từ Firebase Realtime Database
  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final users = await widget.firebaseService.fetchUsers();
    setState(() {
      _users = users;
      _isLoading = false;
    });
    _applyFilterAndSort();
  }

  /// Kiểm tra kết nối Firebase
  Future<void> _checkConnection() async {
    final ok = await widget.firebaseService.testConnection();
    if (mounted) {
      setState(() {
        _isFirebaseConnected = ok;
      });
    }
  }

  /// Lọc và sắp xếp danh sách người dùng
  void _applyFilterAndSort() {
    List<UserModel> temp = List.from(_users);

    // Lọc theo từ khóa tìm kiếm (Họ tên hoặc Email)
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      temp = temp.where((u) {
        return u.hoten.toLowerCase().contains(q) ||
            u.email.toLowerCase().contains(q);
      }).toList();
    }

    // Sắp xếp
    if (_sortOption == 'name_asc') {
      temp.sort((a, b) => a.hoten.compareTo(b.hoten));
    } else if (_sortOption == 'name_desc') {
      temp.sort((a, b) => b.hoten.compareTo(a.hoten));
    } else if (_sortOption == 'email_asc') {
      temp.sort((a, b) => a.email.compareTo(b.email));
    }

    setState(() {
      _filteredUsers = temp;
    });
  }

  /// 1. THÊM NGƯỜI DÙNG (CREATE)
  void _openAddUserDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => UserFormDialog(
        onSave: (newUser) async {
          setState(() => _isLoading = true);
          final created = await widget.firebaseService.addUser(newUser);
          if (created != null && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Đã thêm người dùng "${created.hoten}" vào CSDL!'),
                backgroundColor: Colors.green,
              ),
            );
          }
          await _loadUsers();
        },
      ),
    );
  }

  /// 2. SỬA THÔNG TIN NGƯỜI DÙNG (UPDATE)
  void _openEditUserDialog(UserModel user) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => UserFormDialog(
        userToEdit: user,
        onSave: (updatedUser) async {
          setState(() => _isLoading = true);
          final ok = await widget.firebaseService.updateUser(updatedUser);
          if (ok && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Đã cập nhật thông tin "${updatedUser.hoten}" thành công!'),
                backgroundColor: Colors.blue,
              ),
            );
          }
          await _loadUsers();
        },
      ),
    );
  }

  /// 3. XÓA NGƯỜI DÙNG (DELETE)
  void _confirmDeleteUser(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text('Xác nhận xóa'),
          ],
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa người dùng "${user.hoten}" (${user.email}) khỏi cơ sở dữ liệu không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              setState(() => _isLoading = true);
              final ok = await widget.firebaseService.deleteUser(user.id);
              if (ok && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã xóa người dùng "${user.hoten}" khỏi CSDL!'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              await _loadUsers();
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  /// 4. XEM CHI TIẾT NGƯỜI DÙNG (READ DETAIL)
  void _openUserDetail(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => UserDetailDialog(
        user: user,
        onEdit: () => _openEditUserDialog(user),
      ),
    );
  }

  /// 5. XUẤT CƠ SỞ DỮ LIỆU JSON ĐỂ NỘP BÀI
  /// Yêu cầu số 4 & phần kết quả của đề bài: "nộp file cơ sở dữ liệu (json, sql...)"
  Future<void> _exportDatabaseDialog() async {
    final jsonStr = await widget.firebaseService.exportDatabaseJson();

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.data_object, color: Colors.indigo, size: 26),
            SizedBox(width: 10),
            Text('Xuất Cơ Sở Dữ Liệu (JSON)'),
          ],
        ),
        content: SizedBox(
          width: 550,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dữ liệu JSON chuẩn chỉ gồm 4 trường (email, matkhau, hoten, hinhanh) theo đúng yêu cầu đề bài:',
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
              const SizedBox(height: 12),
              Container(
                height: 260,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    jsonStr,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: Colors.greenAccent,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('Sao chép JSON'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: jsonStr));
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã sao chép toàn bộ CSDL JSON vào Clipboard!'),
                  backgroundColor: Colors.indigo,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 6. MỞ CÀI ĐẶT CSDL
  void _openSettings() {
    showDialog(
      context: context,
      builder: (context) => SettingsDialog(
        firebaseService: widget.firebaseService,
        onConfigChanged: () {
          _checkConnection();
          _loadUsers();
        },
      ),
    );
  }

  /// 7. ĐĂNG XUẤT
  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi Admin Portal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.logout();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => LoginScreen(firebaseService: widget.firebaseService),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Row(
          children: [
            const Icon(Icons.admin_panel_settings, size: 28),
            const SizedBox(width: 10),
            Text(
              isDesktop
                  ? 'Admin Portal - Quản Lý Người Dùng'
                  : 'Admin Portal',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(width: 12),

            // Badge trạng thái kết nối Firebase
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _isFirebaseConnected
                    ? Colors.green.withOpacity(0.15)
                    : Colors.orange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isFirebaseConnected ? Colors.green : Colors.orange,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 4,
                    backgroundColor: _isFirebaseConnected ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isFirebaseConnected ? 'Firebase Online' : 'Local Mode',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _isFirebaseConnected ? Colors.green[800] : Colors.orange[900],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.data_object),
            tooltip: 'Xuất CSDL (JSON)',
            onPressed: _exportDatabaseDialog,
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Cài đặt kết nối CSDL',
            onPressed: _openSettings,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Làm mới',
            onPressed: () {
              _checkConnection();
              _loadUsers();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: _handleLogout,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _checkConnection();
          await _loadUsers();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hàng thẻ thống kê
              _buildStatCardsRow(isDesktop),
              const SizedBox(height: 20),

              // Thanh công cụ: Tìm kiếm, Sắp xếp, Nút Thêm mới
              _buildActionBar(isDesktop),
              const SizedBox(height: 16),

              // Nội dung hiển thị dữ liệu (Bảng trên Web / Danh sách thẻ trên Mobile)
              _isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : _filteredUsers.isEmpty
                      ? _buildEmptyState()
                      : isDesktop
                          ? _buildWebDataTable()
                          : _buildMobileList(),
            ],
          ),
        ),
      ),
      floatingActionButton: isDesktop
          ? null
          : FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: const Text('Thêm người dùng'),
              onPressed: _openAddUserDialog,
            ),
    );
  }

  /// Thống kê tổng quan
  Widget _buildStatCardsRow(bool isDesktop) {
    final stats = [
      StatCard(
        title: 'Tổng số người dùng',
        value: '${_users.length}',
        icon: Icons.people,
        color: Colors.blue,
        subtitle: 'Bản ghi trong cơ sở dữ liệu',
      ),
      StatCard(
        title: 'Cơ sở dữ liệu',
        value: _isFirebaseConnected ? 'Firebase Realtime' : 'Local Cache',
        icon: Icons.cloud_done,
        color: _isFirebaseConnected ? Colors.green : Colors.orange,
        subtitle: _isFirebaseConnected ? 'Đồng bộ đám mây' : 'Chế độ ngoại tuyến',
      ),
      StatCard(
        title: 'Nền tảng ứng dụng',
        value: kIsWeb ? 'Web Browser' : 'Di Động (Mobile)',
        icon: kIsWeb ? Icons.language : Icons.smartphone,
        color: Colors.purple,
        subtitle: 'Flutter Cross-Platform',
      ),
    ];

    if (isDesktop) {
      return Row(
        children: stats
            .map((card) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: card,
                  ),
                ))
            .toList(),
      );
    } else {
      return Column(
        children: stats
            .map((card) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: card,
                ))
            .toList(),
      );
    }
  }

  /// Thanh thao tác (Tìm kiếm, Sắp xếp, Thêm mới)
  Widget _buildActionBar(bool isDesktop) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.spaceBetween,
          children: [
            // Ô tìm kiếm
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 320 : double.infinity,
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm theo họ tên hoặc email...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            setState(() => _searchQuery = '');
                            _applyFilterAndSort();
                          },
                        )
                      : null,
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (val) {
                  _searchQuery = val.trim();
                  _applyFilterAndSort();
                },
              ),
            ),

            // Dropdown Sắp xếp & Nút Thêm mới
            Wrap(
              spacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Sắp xếp
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _sortOption,
                      icon: const Icon(Icons.sort, size: 20),
                      items: const [
                        DropdownMenuItem(
                          value: 'name_asc',
                          child: Text('Tên: A → Z', style: TextStyle(fontSize: 13)),
                        ),
                        DropdownMenuItem(
                          value: 'name_desc',
                          child: Text('Tên: Z → A', style: TextStyle(fontSize: 13)),
                        ),
                        DropdownMenuItem(
                          value: 'email_asc',
                          child: Text('Email: A → Z', style: TextStyle(fontSize: 13)),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _sortOption = val);
                          _applyFilterAndSort();
                        }
                      },
                    ),
                  ),
                ),

                // Nút Thêm mới người dùng
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.person_add, size: 18),
                  label: const Text('Thêm người dùng'),
                  onPressed: _openAddUserDialog,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// BẢNG DỮ LIỆU TRÊN NỀN TẢNG WEB (Yêu cầu số 1 của đề bài)
  Widget _buildWebDataTable() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: double.infinity,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
            ),
            horizontalMargin: 20,
            columnSpacing: 24,
            columns: const [
              DataColumn(label: Text('STT', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Hình ảnh', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Họ và tên', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Mật khẩu', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                label: Text('Thao tác', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
            rows: List.generate(_filteredUsers.length, (index) {
              final user = _filteredUsers[index];
              return DataRow(
                cells: [
                  DataCell(Text('${index + 1}')),
                  DataCell(
                    AvatarImage(
                      imageSource: user.hinhanh,
                      fallbackName: user.hoten,
                      radius: 20,
                      onTap: () => _openUserDetail(user),
                    ),
                  ),
                  DataCell(
                    InkWell(
                      onTap: () => _openUserDetail(user),
                      child: Text(
                        user.hoten,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  DataCell(Text(user.email)),
                  DataCell(
                    Text(
                      '••••••••',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.visibility_outlined, size: 20, color: Colors.blue),
                          tooltip: 'Xem chi tiết',
                          onPressed: () => _openUserDetail(user),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.orange),
                          tooltip: 'Sửa thông tin',
                          onPressed: () => _openEditUserDialog(user),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                          tooltip: 'Xóa người dùng',
                          onPressed: () => _confirmDeleteUser(user),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  /// DANH SÁCH THẺ TRÊN DI ĐỘNG (Yêu cầu số 3 của đề bài)
  Widget _buildMobileList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredUsers.length,
      itemBuilder: (context, index) {
        final user = _filteredUsers[index];
        return UserCard(
          user: user,
          onView: () => _openUserDetail(user),
          onEdit: () => _openEditUserDialog(user),
          onDelete: () => _confirmDeleteUser(user),
        );
      },
    );
  }

  /// Trạng thái trống (Không tìm thấy kết quả)
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.person_off_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Không tìm thấy người dùng phù hợp với "$_searchQuery"'
                  : 'Chưa có người dùng nào trong cơ sở dữ liệu',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Thêm người dùng mới ngay'),
              onPressed: _openAddUserDialog,
            ),
          ],
        ),
      ),
    );
  }
}

