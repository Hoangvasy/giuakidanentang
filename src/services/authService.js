import AsyncStorage from '@react-native-async-storage/async-storage';
import { AppConstants } from '../constants';
import { firebaseService } from './firebaseService';

export const authService = {
  /**
   * Đăng nhập Admin:
   * Chấp nhận tài khoản Admin hệ thống (admin@gmail.com / admin123)
   * hoặc tài khoản có trong cơ sở dữ liệu
   */
  async login(email, password) {
    const cleanEmail = (email || '').trim().toLowerCase();
    const cleanPassword = (password || '').trim();

    // 1. Kiểm tra tài khoản Admin mặc định
    if (
      cleanEmail === AppConstants.defaultAdminEmail.toLowerCase() &&
      cleanPassword === AppConstants.defaultAdminPassword
    ) {
      await this.saveSession(cleanEmail, true);
      return true;
    }

    // 2. Kiểm tra trong cơ sở dữ liệu người dùng
    try {
      const users = await firebaseService.fetchUsers();
      const matched = users.find(
        (u) =>
          u.email.trim().toLowerCase() === cleanEmail &&
          u.matkhau.trim() === cleanPassword
      );

      if (matched) {
        await this.saveSession(cleanEmail, true);
        return true;
      }
    } catch (e) {
      console.log('Lỗi kiểm tra đăng nhập:', e);
    }

    return false;
  },

  async saveSession(email, isAdmin) {
    try {
      await AsyncStorage.setItem(AppConstants.storageKeys.loggedInUser, email);
      await AsyncStorage.setItem(
        AppConstants.storageKeys.isAdmin,
        isAdmin ? 'true' : 'false'
      );
    } catch (e) {
      console.log('Lỗi lưu session:', e);
    }
  },

  async isLoggedIn() {
    try {
      const user = await AsyncStorage.getItem(
        AppConstants.storageKeys.loggedInUser
      );
      return !!user;
    } catch (e) {
      return false;
    }
  },

  async getCurrentUser() {
    try {
      return await AsyncStorage.getItem(
        AppConstants.storageKeys.loggedInUser
      );
    } catch (e) {
      return null;
    }
  },

  async logout() {
    try {
      await AsyncStorage.removeItem(AppConstants.storageKeys.loggedInUser);
      await AsyncStorage.removeItem(AppConstants.storageKeys.isAdmin);
    } catch (e) {
      console.log('Lỗi đăng xuất:', e);
    }
  },
};

