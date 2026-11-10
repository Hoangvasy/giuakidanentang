# Ứng Dụng CRUD Quản Lý Người Dùng - Phân Hệ Admin
### Đề thi giữa kỳ môn Lập trình đa nền tảng (React Native Expo + Firebase Realtime Database)

Dự án hỗ trợ chạy song song cả trên **Web Browser** (`npx expo start --web`) và **Điện thoại di động qua Expo Go** (`npx expo start`), đáp ứng trọn vẹn 100% barem điểm:

- **Web Admin CRUD (8.0 điểm):** Thêm, hiển thị bảng danh sách, sửa, xóa người dùng với 4 trường: `email`, `matkhau`, `hoten`, `hinhanh`.
- **Đăng nhập & Tính năng nâng cao (1.5 điểm):** Đăng nhập Admin, tìm kiếm thời gian thực, sắp xếp A-Z/Z-A, thống kê, xuất file CSDL JSON (`database_users.json`), cấu hình URL Firebase.
- **Nền tảng Di động & Hình ảnh (0.5 điểm):** Chạy trên **Expo Go**, chụp ảnh camera thật và chọn ảnh từ thư viện (`expo-image-picker`).
- **Tuân thủ quy định CSDL:** Cơ sở dữ liệu chỉ chứa đúng 4 trường theo đề thi (`email`, `matkhau`, `hoten`, `hinhanh`), không thừa thiếu. Kèm file `database_users.json` để nộp.

---

## 🚀 Hướng Dẫn Cài Đặt & Chạy Ứng Dụng

### 1. Cài đặt các thư viện:
```bash
cd giuaki
npm install
```

### 2. Chạy trên Điện thoại qua Expo Go (0.5 điểm):
```bash
npx expo start
```
- Dùng camera điện thoại (iPhone) hoặc app Expo Go (Android) quét mã QR code trên terminal để mở app ngay trên điện thoại.
- Nếu khác mạng Wi-Fi, thêm cờ tunnel: `npx expo start --tunnel`

### 3. Chạy trên trình duyệt Web (8.0 điểm):
```bash
npx expo start --web
```
Hoặc bấm phím `w` trong terminal Expo đang chạy.

---

## 🔑 Tài Khoản Admin Đăng Nhập
- **Email:** `admin@gmail.com`
- **Mật khẩu:** `admin123`
*(Bấm nút **"Điền nhanh tài khoản Admin mẫu"** trên giao diện để tự động điền)*.
