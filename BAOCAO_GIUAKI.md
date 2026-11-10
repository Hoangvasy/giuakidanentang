# BÁO CÁO BÀI TẬP GIỮA KỲ: LẬP TRÌNH ĐA NỀN TẢNG
## ĐỀ TÀI: XÂY DỰNG ỨNG DỤNG CRUD NGƯỜI DÙNG PHÂN HỆ ADMIN TRÊN WEB & EXPO GO (REACT NATIVE EXPO + FIREBASE REALTIME DATABASE)

---

### THÔNG TIN CHUNG
- **Môn học:** Lập trình đa nền tảng
- **Họ và tên sinh viên:** Hoàng Văn Sỹ
- **Mã số sinh viên (MSSV):** 23IT241
- **Lớp / Khóa:** *(Điền tên lớp vào đây)*
- **Giảng viên hướng dẫn:** *(Điền tên Giảng viên vào đây)*
- **Link GitHub Source Code:** https://github.com/Hoangvasy/giuakidanentang
- **Link Video Demo:** `https://youtu.be/...` *(Link video Youtube hoặc Google Drive)*
- **File Cơ sở dữ liệu đính kèm:** `database_users.json`

---

## I. MỤC TIÊU VÀ BAREM ĐIỂM ĐỀ BÀI (10.0 / 10.0 ĐIỂM)

| STT | Nội dung yêu cầu | Barem điểm | Trạng thái |
|:---:|:---|:---:|:---:|
| 1 | Sử dụng cơ sở dữ liệu Firebase, thực hiện thêm, hiển thị `email`, `matkhau`, `hoten`, `hinhanh` chạy trên nền tảng **Web** (`npx expo start --web`) | **8.0 điểm** | Hoàn thành 100% |
| 2 | Thực hiện **Đăng nhập**, **Xóa**, **Sửa**, các chức năng nâng cao (Tìm kiếm, Sắp xếp, Thống kê, Xuất CSDL JSON...) | **1.5 điểm** | Hoàn thành 100% |
| 3 | Nhập được hình ảnh (chụp từ Camera, chọn từ Thư viện) và hiển thị thông tin người dùng trên nền tảng **Di động (Expo Go)** | **0.5 điểm** | Hoàn thành 100% |
| **Quy định CSDL** | **Chỉ chấp nhận cơ sở dữ liệu gồm đúng 4 trường: `email`, `matkhau`, `hoten`, `hinhanh` (không tự ý bổ sung thêm trường), bắt buộc phải nộp file cơ sở dữ liệu (`database_users.json`)** | **Bắt buộc** | Tuân thủ chính xác 100% |

---

## II. LỆNH CÀI ĐẶT THƯ VIỆN LIÊN QUAN (PACKAGE COMMANDS)

### 1. Bảng tổng hợp các thư viện sử dụng:

| STT | Tên thư viện | Phiên bản | Mục đích sử dụng | Lệnh cài đặt chi tiết |
|:---:|:---|:---:|:---|:---|
| 1 | `expo` | `~52.0.0` | Framework chính phát triển ứng dụng đa nền tảng (Web & Mobile) | `npx expo install expo` |
| 2 | `react-native` | `0.76.6` | Thư viện UI Core (View, Text, TextInput, TouchableOpacity, FlatList...) | `npm install react-native` |
| 3 | `react-dom` & `@expo/metro-runtime` | `18.3.1` | Hỗ trợ biên dịch và hiển thị trên nền tảng Web (**8.0 điểm**) | `npx expo install react-dom @expo/metro-runtime` |
| 4 | `expo-asset` | `~11.0.1` | Quản lý và nạp tài nguyên hình ảnh, icon hệ thống | `npx expo install expo-asset` |
| 5 | `expo-image-picker` | `~16.0.4` | Chụp ảnh từ Camera & chọn ảnh từ Thư viện trên Di động (**0.5 điểm**) | `npx expo install expo-image-picker` |
| 6 | `@react-native-async-storage/async-storage` | `1.23.1` | Lưu trữ phiên đăng nhập Admin & bộ nhớ đệm Offline Cache | `npx expo install @react-native-async-storage/async-storage` |
| 7 | `expo-status-bar` | `~2.0.0` | Tự động đổi màu và quản lý thanh trạng thái trên điện thoại | `npx expo install expo-status-bar` |

### 2. Các lệnh tải thư viện thực tế:

- **Cách 1: Lệnh tải toàn bộ dự án từ `package.json` (Nhanh nhất):**
  ```bash
  cd "/Users/sy/Documents/Đa nền tảng/giuaki"
  npm install
  ```

- **Cách 2: Lệnh cài đặt từng thư viện chuyên biệt bằng Expo CLI:**
  ```bash
  cd "/Users/sy/Documents/Đa nền tảng/giuaki"
  npx expo install expo-image-picker @react-native-async-storage/async-storage expo-status-bar
  ```

---

## III. QUY TRÌNH PHÁT TRIỂN CODE (STEP-BY-STEP CODING WORKFLOW)

Quy trình lập trình được xây dựng theo kiến trúc phân tầng rõ ràng (Separation of Concerns):

```
Tầng 1: Cấu hình hệ thống (constants)
   ↓
Tầng 2: Tầng Dịch vụ Dữ liệu (services: Firebase REST API & AuthService)
   ↓
Tầng 3: Tầng Linh kiện dùng chung (components: Form Modal, Detail Modal, Settings Modal)
   ↓
Tầng 4: Tầng Màn hình Giao diện (screens: LoginScreen & AdminDashboardScreen)
   ↓
Tầng 5: Bộ điều hướng gốc (App.js)
```

---

### BƯỚC 1: Khởi tạo Project và Cấu hình Môi trường
- Tạo cấu trúc thư mục dự án với `package.json`, `app.json`, `babel.config.js`, `index.js`.
- Cấu hình cấp quyền trong `app.json` cho phép ứng dụng truy cập Camera (`CAMERA`) và Thư viện ảnh (`READ_EXTERNAL_STORAGE`).

---

### BƯỚC 2: Định nghĩa Hằng số và Cấu hình Hệ thống (`src/constants/index.js`)
- Khởi tạo đối tượng `AppConstants` chứa:
  * URL Firebase Realtime Database mặc định.
  * Tài khoản Admin mặc định: `admin@gmail.com` / `admin123`.
  * Bộ mã màu giao diện chuẩn Material Design 3.
  * Danh sách 6 avatar mẫu để người dùng chọn nhanh khi không tiện chụp ảnh.

---

### BƯỚC 3: Xây dựng Tầng Dịch vụ Kết nối CSDL Firebase (`src/services/firebaseService.js`)
Thay vì dùng SDK Firebase cồng kềnh dễ lỗi trên Expo Go, hệ thống sử dụng **REST API chuẩn của Firebase thông qua hàm `fetch()`**:
1. **Lấy danh sách người dùng (`fetchUsers`):**
   - Gửi HTTP GET: `GET [databaseUrl]/users.json`
   - Nhận kết quả JSON dạng cây `Object.keys(data).map(...)` chuyển thành danh sách đối tượng.
   - Lưu bản sao dự phòng vào `AsyncStorage` (Offline Cache) phòng trường hợp mất mạng.
2. **Thêm mới người dùng (`addUser`):**
   - Chuẩn hóa payload **CHỈ LƯU ĐÚNG 4 TRƯỜNG THEO ĐỀ**:
     ```javascript
     const payload = {
       email: userData.email.trim(),
       matkhau: userData.matkhau,
       hoten: userData.hoten.trim(),
       hinhanh: userData.hinhanh.trim()
     };
     ```
   - Gửi HTTP POST: `POST [databaseUrl]/users.json` với header `Content-Type: application/json`.
   - Nhận về ID tự sinh của Firebase (`result.name`) và cập nhật danh sách.
3. **Cập nhật thông tin (`updateUser`):**
   - Gửi HTTP PATCH: `PATCH [databaseUrl]/users/[id].json` để sửa các trường thay đổi.
4. **Xóa người dùng (`deleteUser`):**
   - Gửi HTTP DELETE: `DELETE [databaseUrl]/users/[id].json`.
5. **Kiểm tra kết nối (`testConnection`):**
   - Gửi request `GET [databaseUrl]/.json?shallow=true` với timeout 4 giây để đo trạng thái online (mã 200).
6. **Xuất file CSDL (`exportDatabaseJson`):**
   - Trích xuất toàn bộ dữ liệu người dùng thành chuỗi JSON chuẩn có thụt dòng 2 khoảng trắng để phục vụ nộp bài.

---

### BƯỚC 4: Xây dựng Tầng Xác thực và Phiên Đăng nhập (`src/services/authService.js`)
- Hàm `login(email, password)`: Kiểm tra thông tin đăng nhập với tài khoản Admin mặc định hoặc bất kỳ người dùng nào đang tồn tại trong Firebase CSDL.
- Hàm `saveSession()`: Lưu email và cờ `isAdmin: true` vào `AsyncStorage`.
- Hàm `isLoggedIn()`: Đọc trạng thái từ `AsyncStorage` giúp giữ phiên đăng nhập khi reload app.
- Hàm `logout()`: Xóa sạch session khi đăng xuất.

---

### BƯỚC 5: Xây dựng Màn hình Đăng nhập (`src/screens/LoginScreen.js`)
- Form đăng nhập gồm các ô nhập Email, Mật khẩu có nút **"Hiện / Ẩn"** mật khẩu.
- Kiểm tra tính hợp lệ dữ liệu (validation): không để trống email và mật khẩu.
- Nút **"⚡ Điền nhanh tài khoản Admin mẫu"**: Tự động gán `admin@gmail.com` / `admin123` vào form để giảng viên chấm thi nhanh trong 1 click.
- Xử lý trạng thái Loading spinner trong lúc gửi yêu cầu xác thực.

---

### BƯỚC 6: Xây dựng Form Thêm / Sửa & Tích hợp Camera (`src/components/UserFormModal.js`)
- Hộp thoại Modal phục vụ cả 2 tính năng: Thêm mới (Create) và Chỉnh sửa (Update).
- **Tích hợp `expo-image-picker` đáp ứng yêu cầu di động (0.5 điểm):**
  * Nút **"📷 Chụp Camera"**: Gọi `ImagePicker.launchCameraAsync({ allowsEditing: true, aspect: [1, 1], quality: 0.7 })` để bật camera chụp ảnh chân dung thật.
  * Nút **"🖼️ Thư viện"**: Gọi `ImagePicker.launchImageLibraryAsync(...)` để chọn ảnh từ bộ nhớ thiết bị.
  * Bộ avatar mẫu: Bấm chọn avatar có sẵn để test nhanh.
  * Ô nhập link URL: Nhập trực tiếp đường link ảnh online.
- Kiểm tra hợp lệ (Validate): Tên không để trống, Email phải chứa `@`, Mật khẩu tối thiểu 6 ký tự.

---

### BƯỚC 7: Xây dựng Phân hệ Admin Đa Nền Tảng (`src/screens/AdminDashboardScreen.js`)
1. **Khả năng thích ứng giao diện (Responsive Design):**
   - Dùng hook `useWindowDimensions()` để lấy bề rộng màn hình:
     * **Màn hình Web (width > 768px - 8.0 điểm):** Hiển thị **Bảng dữ liệu Data Table** gồm các cột: *STT, Hình ảnh avatar tròn, Họ và tên, Email, Mật khẩu ẩn, Thao tác (Xem, Sửa, Xóa)*.
     * **Màn hình Di động (Expo Go - 0.5 điểm):** Hiển thị **Danh sách thẻ Card** mượt mà kèm nút bấm thao tác nhanh và nút Floating Action Button `+ Thêm` ở góc dưới.
2. **Tìm kiếm thời gian thực (Live Search):**
   - Lắng nghe sự kiện `onChangeText` trên thanh tìm kiếm để lọc danh sách `filteredUsers` tức thì theo Họ tên hoặc Email (không phân biệt chữ hoa/thường).
3. **Sắp xếp linh hoạt (Sort):**
   - Nút chuyển đổi sắp xếp: `Tên: A → Z 🔽`, `Tên: Z → A 🔼`, `Email: A → Z ✉️`.
4. **Huy hiệu kết nối (Connection Badge):**
   - Hiển thị chấm tròn xanh `🟢 Firebase Online` khi kết nối thành công, hoặc `🟠 Local Mode` khi mất mạng.
5. **Cảnh báo an toàn khi xóa:**
   - Dùng `Alert.alert` (trên Mobile) và `window.confirm` (trên Web) để yêu cầu người dùng xác nhận trước khi xóa vĩnh viễn khỏi CSDL.

---

### BƯỚC 8: Xây dựng Hộp thoại Cài đặt CSDL & Xuất JSON (`src/components/SettingsModal.js`)
- Cho phép người dùng hoặc giảng viên dán URL Firebase của riêng mình vào để kết nối.
- Nút **"Kiểm tra kết nối"**: Thực hiện gửi Ping request kiểm tra trạng thái HTTP 200 OK.
- Nút **"📄 Tải / Xem Dữ Liệu JSON"**: Hiển thị toàn bộ dữ liệu CSDL dưới định dạng JSON đúng 4 trường theo đề thi để sao chép hoặc kiểm tra.

---

### BƯỚC 9: Điều hướng Gốc trong `App.js`
- Quản lý trạng thái đăng nhập `isLoggedIn`.
- Nếu chưa đăng nhập: Hiển thị `LoginScreen`.
- Nếu đã đăng nhập: Hiển thị `AdminDashboardScreen`.

---

## IV. CẤU TRÚC DỮ LIỆU CƠ SỞ DỮ LIỆU (`database_users.json`)

File CSDL mẫu nộp bài tuân thủ nghiêm ngặt **chỉ chứa đúng 4 trường**:
```json
{
  "users": {
    "-OAdmoa1_Admin001": {
      "email": "admin@gmail.com",
      "matkhau": "admin123",
      "hoten": "Quản Trị Viên Hệ Thống",
      "hinhanh": "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80"
    },
    "-OAdmob2_User002": {
      "email": "nguyenvanan@gmail.com",
      "matkhau": "an123456",
      "hoten": "Nguyễn Văn An",
      "hinhanh": "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=400&q=80"
    }
  }
}
```

---

## V. HƯỚNG DẪN CHẠY ỨNG DỤNG VÀ THAO TÁC DEMO

### 1. Lệnh chạy Web:
```bash
npx expo start --web
```
### 2. Lệnh chạy Mobile Expo Go:
```bash
npx expo start
```
*(Quét mã QR bằng app Expo Go trên điện thoại)*.

---

## VI. KỊCH BẢN QUAY VIDEO DEMO NỘP BÀI (3 - 5 PHÚT)

1. **Phút 0:00 - 0:30 (Giới thiệu):** Giới thiệu Họ tên, MSSV, Đề tài môn Lập trình đa nền tảng. Đăng nhập bằng nút *"Điền nhanh tài khoản Admin mẫu"*.
2. **Phút 0:30 - 1:45 (Demo Web Admin CRUD - 8.0 điểm):** Đặt song song màn hình Web App và Firebase Console. Thêm người dùng mới → Cây dữ liệu Firebase nhấp nháy sáng và xuất hiện ngay. Sửa họ tên → Firebase cập nhật. Xóa người dùng → Firebase xóa bản ghi.
3. **Phút 1:45 - 2:30 (Demo tính năng nâng cao - 1.5 điểm):** Thử tìm kiếm theo tên, thử đổi bộ lọc sắp xếp A-Z / Z-A. Mở hộp thoại Cài đặt CSDL bấm xem chuỗi JSON.
4. **Phút 2:30 - 3:30 (Demo trên Di động Expo Go - 0.5 điểm):** Mở app trên điện thoại qua Expo Go. Bấm Thêm → Chụp ảnh từ Camera thật hoặc chọn từ Thư viện ảnh để cập nhật avatar.
5. **Phút 3:30 - 4:00 (Kết luận):** Mở file `database_users.json` và repo GitHub. Kết thúc bài báo cáo.
