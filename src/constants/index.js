export const AppConstants = {
  appName: 'Admin Quản Lý Người Dùng',
  appVersion: '1.0.0 (Giữa Kỳ - React Native Expo)',

  // URL Firebase Realtime Database mặc định
  defaultFirebaseUrl:
    'https://danentang-giuaki-default-rtdb.asia-southeast1.firebasedatabase.app',

  // Tài khoản Admin mặc định để chấm bài và test nhanh
  defaultAdminEmail: 'admin@gmail.com',
  defaultAdminPassword: 'admin123',

  // Khóa lưu trữ AsyncStorage
  storageKeys: {
    loggedInUser: '@logged_in_user_email',
    firebaseUrl: '@firebase_database_url',
    localUsersBackup: '@local_users_backup_data',
    isAdmin: '@is_admin_logged_in',
  },

  // Màu sắc chủ đạo (Material Design)
  colors: {
    primary: '#6750A4',
    primaryLight: '#EADDFF',
    primaryDark: '#21005D',
    secondary: '#625B71',
    surface: '#FFFFFF',
    background: '#F6F8FA',
    cardBorder: '#E1E4E8',
    textPrimary: '#1F2937',
    textSecondary: '#6B7280',
    success: '#16A34A',
    successLight: '#DCFCE7',
    warning: '#D97706',
    warningLight: '#FEF3C7',
    danger: '#DC2626',
    dangerLight: '#FEE2E2',
  },

  // Bộ sưu tập avatar mẫu để chọn nhanh
  presetAvatars: [
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
    'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=400&q=80',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=400&q=80',
    'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?auto=format&fit=crop&w=400&q=80',
    'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=400&q=80',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=400&q=80',
  ],
};

