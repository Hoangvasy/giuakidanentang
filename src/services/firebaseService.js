import AsyncStorage from '@react-native-async-storage/async-storage';
import { AppConstants } from '../constants';

/**
 * Dịch vụ kết nối Firebase Realtime Database qua REST API
 * Tương thích 100% với Expo Go và Expo Web, không cần cấu hình native phức tạp.
 *
 * QUY ĐỊNH CỦA ĐỀ THI:
 * "Chỉ chấp nhận cơ sở dữ liệu gồm các trường: email, matkhau, hoten, hinhanh
 * (không tự bổ sung thêm trường), bắt buộc phải nộp file cơ sở dữ liệu"
 */
class FirebaseService {
  constructor() {
    this.databaseUrl = AppConstants.defaultFirebaseUrl;
    this.isLocalFallback = false;
    this.seedUsers = [
      {
        id: '-OAdmoa1_Admin001',
        email: 'admin@gmail.com',
        matkhau: 'admin123',
        hoten: 'Quản Trị Viên Hệ Thống',
        hinhanh:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
      },
      {
        id: '-OAdmob2_User002',
        email: 'nguyenvanan@gmail.com',
        matkhau: 'an123456',
        hoten: 'Nguyễn Văn An',
        hinhanh:
          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=400&q=80',
      },
      {
        id: '-OAdmoc3_User003',
        email: 'tranthibinh@gmail.com',
        matkhau: 'binh123456',
        hoten: 'Trần Thị Bình',
        hinhanh:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=400&q=80',
      },
      {
        id: '-OAdmod4_User004',
        email: 'lehoangcuong@gmail.com',
        matkhau: 'cuong123456',
        hoten: 'Lê Hoàng Cường',
        hinhanh:
          'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?auto=format&fit=crop&w=400&q=80',
      },
      {
        id: '-OAdmoe5_User005',
        email: 'phamthidung@gmail.com',
        matkhau: 'dung123456',
        hoten: 'Phạm Thị Dung',
        hinhanh:
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=400&q=80',
      },
    ];
    this.init();
  }

  async init() {
    try {
      const savedUrl = await AsyncStorage.getItem(
        AppConstants.storageKeys.firebaseUrl
      );
      if (savedUrl) {
        this.databaseUrl = savedUrl.trim();
      }
    } catch (e) {
      console.log('Không thể tải URL Firebase từ AsyncStorage:', e);
    }
  }

  async setDatabaseUrl(newUrl) {
    this.databaseUrl = newUrl.trim();
    try {
      await AsyncStorage.setItem(
        AppConstants.storageKeys.firebaseUrl,
        this.databaseUrl
      );
    } catch (e) {
      console.log('Lỗi lưu URL Firebase:', e);
    }
  }

  cleanUrl(url) {
    let clean = (url || this.databaseUrl).trim();
    while (clean.endsWith('/')) {
      clean = clean.substring(0, clean.length - 1);
    }
    return clean;
  }

  /**
   * 1. LẤY DANH SÁCH NGƯỜI DÙNG (READ)
   * Gọi GET [databaseUrl]/users.json
   */
  async fetchUsers() {
    const url = `${this.cleanUrl()}/users.json`;
    try {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 6000);

      const res = await fetch(url, { signal: controller.signal });
      clearTimeout(timeoutId);

      if (res.ok) {
        this.isLocalFallback = false;
        const data = await res.json();
        if (!data) return [];

        const users = Object.keys(data).map((key) => ({
          id: key,
          email: data[key]?.email || '',
          matkhau: data[key]?.matkhau || '',
          hoten: data[key]?.hoten || '',
          hinhanh: data[key]?.hinhanh || '',
        }));

        await this.saveLocalCache(users);
        return users;
      } else {
        this.isLocalFallback = true;
        return await this.loadLocalCache();
      }
    } catch (error) {
      console.log('Lỗi kết nối Firebase, chuyển sang Local Cache:', error.message);
      this.isLocalFallback = true;
      return await this.loadLocalCache();
    }
  }

  /**
   * 2. THÊM NGƯỜI DÙNG MỚI (CREATE)
   * Gọi POST [databaseUrl]/users.json
   * Payload CHỈ CHỨA ĐÚNG 4 TRƯỜNG: email, matkhau, hoten, hinhanh
   */
  async addUser(userData) {
    const payload = {
      email: userData.email.trim(),
      matkhau: userData.matkhau,
      hoten: userData.hoten.trim(),
      hinhanh: userData.hinhanh.trim(),
    };

    const url = `${this.cleanUrl()}/users.json`;
    try {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 6000);

      const res = await fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
        signal: controller.signal,
      });
      clearTimeout(timeoutId);

      if (res.ok) {
        const result = await res.json();
        const newUser = { id: result.name, ...payload };
        const local = await this.loadLocalCache();
        local.unshift(newUser);
        await this.saveLocalCache(local);
        return newUser;
      }
    } catch (error) {
      console.log('Thêm trên Firebase lỗi, lưu vào Local Cache:', error.message);
    }

    const fallbackUser = {
      id: `local_${Date.now()}`,
      ...payload,
    };
    const local = await this.loadLocalCache();
    local.unshift(fallbackUser);
    await this.saveLocalCache(local);
    return fallbackUser;
  }

  /**
   * 3. SỬA THÔNG TIN NGƯỜI DÙNG (UPDATE)
   * Gọi PATCH [databaseUrl]/users/[id].json
   */
  async updateUser(user) {
    if (!user || !user.id) return false;

    const payload = {
      email: user.email.trim(),
      matkhau: user.matkhau,
      hoten: user.hoten.trim(),
      hinhanh: user.hinhanh.trim(),
    };

    const url = `${this.cleanUrl()}/users/${user.id}.json`;
    try {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 6000);

      const res = await fetch(url, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
        signal: controller.signal,
      });
      clearTimeout(timeoutId);

      const local = await this.loadLocalCache();
      const idx = local.findIndex((u) => u.id === user.id);
      if (idx !== -1) {
        local[idx] = { id: user.id, ...payload };
        await this.saveLocalCache(local);
      }

      return res.ok;
    } catch (error) {
      console.log('Cập nhật trên Firebase lỗi, cập nhật Local:', error.message);
      const local = await this.loadLocalCache();
      const idx = local.findIndex((u) => u.id === user.id);
      if (idx !== -1) {
        local[idx] = { id: user.id, ...payload };
        await this.saveLocalCache(local);
      }
      return true;
    }
  }

  /**
   * 4. XÓA NGƯỜI DÙNG (DELETE)
   * Gọi DELETE [databaseUrl]/users/[id].json
   */
  async deleteUser(id) {
    if (!id) return false;

    const url = `${this.cleanUrl()}/users/${id}.json`;
    try {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 6000);

      const res = await fetch(url, {
        method: 'DELETE',
        signal: controller.signal,
      });
      clearTimeout(timeoutId);

      const local = await this.loadLocalCache();
      const updated = local.filter((u) => u.id !== id);
      await this.saveLocalCache(updated);

      return res.ok;
    } catch (error) {
      console.log('Xóa trên Firebase lỗi, xóa trên Local:', error.message);
      const local = await this.loadLocalCache();
      const updated = local.filter((u) => u.id !== id);
      await this.saveLocalCache(updated);
      return true;
    }
  }

  /**
   * 5. XUẤT CƠ SỞ DỮ LIỆU THÀNH JSON (EXPORT JSON ĐỂ NỘP BÀI)
   */
  async exportDatabaseJson() {
    let users = await this.fetchUsers();
    if (!users || users.length === 0) {
      users = await this.loadLocalCache();
    }

    const exportData = { users: {} };
    users.forEach((u, i) => {
      const key = u.id || `-UserKey_${i + 1}`;
      exportData.users[key] = {
        email: u.email,
        matkhau: u.matkhau,
        hoten: u.hoten,
        hinhanh: u.hinhanh,
      };
    });

    return JSON.stringify(exportData, null, 2);
  }

  /**
   * 6. KIỂM TRA TRẠNG THÁI KẾT NỐI (PING TEST)
   */
  async testConnection() {
    try {
      const url = `${this.cleanUrl()}/.json?shallow=true`;
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 4000);

      const res = await fetch(url, { signal: controller.signal });
      clearTimeout(timeoutId);
      return res.ok;
    } catch (e) {
      return false;
    }
  }

  // --- LOCAL CACHE ---
  async saveLocalCache(users) {
    try {
      await AsyncStorage.setItem(
        AppConstants.storageKeys.localUsersBackup,
        JSON.stringify(users)
      );
    } catch (e) {
      console.log('Lỗi lưu cache:', e);
    }
  }

  async loadLocalCache() {
    try {
      const dataStr = await AsyncStorage.getItem(
        AppConstants.storageKeys.localUsersBackup
      );
      if (dataStr) {
        return JSON.parse(dataStr);
      }
    } catch (e) {
      console.log('Lỗi đọc cache:', e);
    }
    return [...this.seedUsers];
  }
}

export const firebaseService = new FirebaseService();

