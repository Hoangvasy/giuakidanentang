import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  ScrollView,
  FlatList,
  Image,
  StyleSheet,
  Alert,
  ActivityIndicator,
  useWindowDimensions,
  Platform,
  RefreshControl,
} from 'react-native';
import { firebaseService } from '../services/firebaseService';
import { authService } from '../services/authService';
import UserFormModal from '../components/UserFormModal';
import UserDetailModal from '../components/UserDetailModal';
import SettingsModal from '../components/SettingsModal';

export default function AdminDashboardScreen({ onLogout }) {
  const { width } = useWindowDimensions();
  const isWebOrDesktop = width > 768;

  const [users, setUsers] = useState([]);
  const [filteredUsers, setFilteredUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [isFirebaseConnected, setIsFirebaseConnected] = useState(false);

  // Tìm kiếm và sắp xếp
  const [searchQuery, setSearchQuery] = useState('');
  const [sortOption, setSortOption] = useState('name_asc'); // name_asc, name_desc, email_asc

  // Modals
  const [formVisible, setFormVisible] = useState(false);
  const [selectedUser, setSelectedUser] = useState(null);
  const [detailVisible, setDetailVisible] = useState(false);
  const [settingsVisible, setSettingsVisible] = useState(false);
  const [currentUser, setCurrentUser] = useState('');

  useEffect(() => {
    loadData();
    checkConnection();
    authService.getCurrentUser().then((u) => setCurrentUser(u || ''));
  }, []);

  const loadData = async () => {
    setLoading(true);
    const data = await firebaseService.fetchUsers();
    setUsers(data);
    setLoading(false);
    applyFilterAndSort(data, searchQuery, sortOption);
  };

  const handleRefresh = async () => {
    setRefreshing(true);
    await checkConnection();
    const data = await firebaseService.fetchUsers();
    setUsers(data);
    applyFilterAndSort(data, searchQuery, sortOption);
    setRefreshing(false);
  };

  const checkConnection = async () => {
    const ok = await firebaseService.testConnection();
    setIsFirebaseConnected(ok);
  };

  const applyFilterAndSort = (sourceData, query, sort) => {
    let list = [...(sourceData || users)];

    // Lọc theo họ tên hoặc email
    if (query && query.trim() !== '') {
      const q = query.toLowerCase().trim();
      list = list.filter(
        (u) =>
          u.hoten.toLowerCase().includes(q) ||
          u.email.toLowerCase().includes(q)
      );
    }

    // Sắp xếp
    if (sort === 'name_asc') {
      list.sort((a, b) => a.hoten.localeCompare(b.hoten));
    } else if (sort === 'name_desc') {
      list.sort((a, b) => b.hoten.localeCompare(a.hoten));
    } else if (sort === 'email_asc') {
      list.sort((a, b) => a.email.localeCompare(b.email));
    }

    setFilteredUsers(list);
  };

  const handleSearchChange = (txt) => {
    setSearchQuery(txt);
    applyFilterAndSort(users, txt, sortOption);
  };

  const handleSortChange = (newSort) => {
    setSortOption(newSort);
    applyFilterAndSort(users, searchQuery, newSort);
  };

  // 1. Thêm người dùng
  const handleOpenAdd = () => {
    setSelectedUser(null);
    setFormVisible(true);
  };

  // 2. Sửa người dùng
  const handleOpenEdit = (user) => {
    setSelectedUser(user);
    setFormVisible(true);
  };

  // 3. Xóa người dùng (có xác nhận)
  const handleDeleteUser = (user) => {
    if (Platform.OS === 'web') {
      const confirmDelete = window.confirm(
        `Bạn có chắc chắn muốn xóa "${user.hoten}" (${user.email}) khỏi CSDL không?`
      );
      if (confirmDelete) {
        confirmDeleteAction(user.id);
      }
    } else {
      Alert.alert(
        'Xác nhận xóa',
        `Bạn có chắc chắn muốn xóa "${user.hoten}" (${user.email}) khỏi CSDL không?`,
        [
          { text: 'Hủy', style: 'cancel' },
          {
            text: 'Xóa',
            style: 'destructive',
            onPress: () => confirmDeleteAction(user.id),
          },
        ]
      );
    }
  };

  const confirmDeleteAction = async (userId) => {
    setLoading(true);
    await firebaseService.deleteUser(userId);
    await loadData();
  };

  // Lưu khi Thêm hoặc Sửa
  const handleSaveUser = async (userData) => {
    setFormVisible(false);
    setLoading(true);

    if (userData.id) {
      await firebaseService.updateUser(userData);
    } else {
      await firebaseService.addUser(userData);
    }

    await loadData();
  };

  // Xem chi tiết
  const handleViewDetail = (user) => {
    setSelectedUser(user);
    setDetailVisible(true);
  };

  // Đăng xuất
  const handleLogoutPress = () => {
    if (Platform.OS === 'web') {
      if (window.confirm('Bạn có chắc chắn muốn đăng xuất không?')) {
        authService.logout();
        onLogout();
      }
    } else {
      Alert.alert('Đăng xuất', 'Bạn có chắc chắn muốn đăng xuất không?', [
        { text: 'Hủy', style: 'cancel' },
        {
          text: 'Đăng xuất',
          style: 'destructive',
          onPress: async () => {
            await authService.logout();
            onLogout();
          },
        },
      ]);
    }
  };

  return (
    <View style={styles.container}>
      {/* App Bar */}
      <View style={styles.appBar}>
        <View style={styles.appBarLeft}>
          <View>
            <Text style={styles.appBarTitle}>Admin Portal</Text>
            {currentUser ? (
              <Text style={{ fontSize: 11, color: '#6B7280' }}>
                👤 {currentUser}
              </Text>
            ) : null}
          </View>
          {/* Badge trạng thái kết nối CSDL */}
          <View
            style={[
              styles.statusBadge,
              isFirebaseConnected
                ? styles.statusConnected
                : styles.statusFallback,
            ]}
          >
            <View
              style={[
                styles.statusDot,
                isFirebaseConnected ? styles.dotGreen : styles.dotOrange,
              ]}
            />
            <Text
              style={[
                styles.statusText,
                isFirebaseConnected
                  ? styles.statusTextGreen
                  : styles.statusTextOrange,
              ]}
            >
              {isFirebaseConnected ? 'Firebase Online' : 'Local Mode'}
            </Text>
          </View>
        </View>

        <View style={styles.appBarRight}>
          <TouchableOpacity
            style={styles.iconBtn}
            onPress={() => setSettingsVisible(true)}
          >
            <Text style={styles.iconBtnText}>⚙️ CSDL</Text>
          </TouchableOpacity>
          <TouchableOpacity style={styles.iconBtn} onPress={loadData}>
            <Text style={styles.iconBtnText}>🔄</Text>
          </TouchableOpacity>
          <TouchableOpacity style={styles.iconBtn} onPress={handleLogoutPress}>
            <Text style={styles.iconBtnText}>🚪 Thoát</Text>
          </TouchableOpacity>
        </View>
      </View>

      <ScrollView
        style={styles.contentScroll}
        showsVerticalScrollIndicator={false}
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={handleRefresh} />
        }
      >
        {/* Thẻ Thống kê */}
        <View
          style={[
            styles.statsRow,
            !isWebOrDesktop && styles.statsRowVertical,
          ]}
        >
          <View style={styles.statCard}>
            <Text style={styles.statNum}>{users.length}</Text>
            <Text style={styles.statLabel}>Tổng người dùng</Text>
          </View>
          <View style={styles.statCard}>
            <Text style={[styles.statNum, { color: isFirebaseConnected ? '#16A34A' : '#D97706' }]}>
              {isFirebaseConnected ? 'Đồng bộ' : 'Ngoại tuyến'}
            </Text>
            <Text style={styles.statLabel}>
              {isFirebaseConnected ? 'Firebase Cloud' : 'Bộ nhớ tạm Local'}
            </Text>
          </View>
          <View style={styles.statCard}>
            <Text style={[styles.statNum, { color: '#6750A4' }]}>
              {Platform.OS === 'web' ? 'Web App' : 'Expo Go'}
            </Text>
            <Text style={styles.statLabel}>Nền tảng hoạt động</Text>
          </View>
        </View>

        {/* Thanh tìm kiếm & bộ lọc */}
        <View style={styles.toolbarCard}>
          <TextInput
            style={styles.searchInput}
            placeholder="🔍 Tìm theo họ tên hoặc email..."
            value={searchQuery}
            onChangeText={handleSearchChange}
          />

          <View style={styles.toolbarActions}>
            {/* Nút lọc sắp xếp */}
            <TouchableOpacity
              style={styles.sortToggleBtn}
              onPress={() => {
                const nextSort =
                  sortOption === 'name_asc'
                    ? 'name_desc'
                    : sortOption === 'name_desc'
                    ? 'email_asc'
                    : 'name_asc';
                handleSortChange(nextSort);
              }}
            >
              <Text style={styles.sortToggleText}>
                {sortOption === 'name_asc'
                  ? 'Tên: A → Z 🔽'
                  : sortOption === 'name_desc'
                  ? 'Tên: Z → A 🔼'
                  : 'Email: A → Z ✉️'}
              </Text>
            </TouchableOpacity>

            {/* Nút Thêm người dùng (trên Web / Desktop) */}
            {isWebOrDesktop && (
              <TouchableOpacity
                style={styles.addBtn}
                onPress={handleOpenAdd}
              >
                <Text style={styles.addBtnText}>+ Thêm Người Dùng</Text>
              </TouchableOpacity>
            )}
          </View>
        </View>

        {/* Danh sách người dùng: Bảng dữ liệu trên Web hoặc Card trên Di động */}
        {loading ? (
          <View style={styles.loadingBox}>
            <ActivityIndicator size="large" color="#6750A4" />
            <Text style={styles.loadingText}>Đang tải dữ liệu từ CSDL...</Text>
          </View>
        ) : filteredUsers.length === 0 ? (
          <View style={styles.emptyBox}>
            <Text style={styles.emptyIcon}>👤</Text>
            <Text style={styles.emptyText}>
              {searchQuery ? `Không tìm thấy kết quả cho "${searchQuery}"` : 'Chưa có người dùng nào'}
            </Text>
            <TouchableOpacity
              style={[styles.addBtn, { marginTop: 12 }]}
              onPress={handleOpenAdd}
            >
              <Text style={styles.addBtnText}>Thêm người dùng mới</Text>
            </TouchableOpacity>
          </View>
        ) : isWebOrDesktop ? (
          /* BẢNG DỮ LIỆU TRÊN NỀN TẢNG WEB (8.0 ĐIỂM) */
          <View style={styles.tableCard}>
            <View style={styles.tableHeader}>
              <Text style={[styles.th, { width: 45 }]}>STT</Text>
              <Text style={[styles.th, { width: 65 }]}>Hình ảnh</Text>
              <Text style={[styles.th, { flex: 2 }]}>Họ và tên</Text>
              <Text style={[styles.th, { flex: 2 }]}>Email</Text>
              <Text style={[styles.th, { flex: 1.5 }]}>Mật khẩu</Text>
              <Text style={[styles.th, { width: 140, textAlign: 'center' }]}>
                Thao tác
              </Text>
            </View>

            {filteredUsers.map((item, index) => (
              <View key={item.id || index} style={styles.tableRow}>
                <Text style={[styles.td, { width: 45 }]}>{index + 1}</Text>
                <View style={{ width: 65 }}>
                  <Image
                    source={{
                      uri:
                        item.hinhanh ||
                        'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde',
                    }}
                    style={styles.tableAvatar}
                  />
                </View>
                <Text style={[styles.td, styles.tdBold, { flex: 2 }]}>
                  {item.hoten}
                </Text>
                <Text style={[styles.td, { flex: 2 }]}>{item.email}</Text>
                <Text style={[styles.td, { flex: 1.5, color: '#6B7280' }]}>
                  ••••••••
                </Text>
                <View style={styles.actionCell}>
                  <TouchableOpacity
                    style={styles.actionBtnView}
                    onPress={() => handleViewDetail(item)}
                  >
                    <Text style={styles.actionText}>Xem</Text>
                  </TouchableOpacity>
                  <TouchableOpacity
                    style={styles.actionBtnEdit}
                    onPress={() => handleOpenEdit(item)}
                  >
                    <Text style={styles.actionText}>Sửa</Text>
                  </TouchableOpacity>
                  <TouchableOpacity
                    style={styles.actionBtnDelete}
                    onPress={() => handleDeleteUser(item)}
                  >
                    <Text style={styles.actionText}>Xóa</Text>
                  </TouchableOpacity>
                </View>
              </View>
            ))}
          </View>
        ) : (
          /* DANH SÁCH THẺ TRÊN DI ĐỘNG EXPO GO (0.5 ĐIỂM) */
          <View style={styles.mobileList}>
            {filteredUsers.map((item, index) => (
              <TouchableOpacity
                key={item.id || index}
                style={styles.userCard}
                onPress={() => handleViewDetail(item)}
              >
                <Image
                  source={{
                    uri:
                      item.hinhanh ||
                      'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde',
                  }}
                  style={styles.cardAvatar}
                />
                <View style={styles.cardInfo}>
                  <Text style={styles.cardName}>{item.hoten}</Text>
                  <Text style={styles.cardEmail}>✉️ {item.email}</Text>
                  <Text style={styles.cardPwd}>🔒 ••••••••</Text>
                </View>
                <View style={styles.cardActions}>
                  <TouchableOpacity
                    style={styles.cardBtnEdit}
                    onPress={() => handleOpenEdit(item)}
                  >
                    <Text style={styles.cardBtnText}>✏️</Text>
                  </TouchableOpacity>
                  <TouchableOpacity
                    style={styles.cardBtnDelete}
                    onPress={() => handleDeleteUser(item)}
                  >
                    <Text style={styles.cardBtnText}>🗑️</Text>
                  </TouchableOpacity>
                </View>
              </TouchableOpacity>
            ))}
          </View>
        )}

        <View style={{ height: 80 }} />
      </ScrollView>

      {/* Floating Action Button trên Di động */}
      {!isWebOrDesktop && (
        <TouchableOpacity style={styles.fab} onPress={handleOpenAdd}>
          <Text style={styles.fabText}>+ Thêm</Text>
        </TouchableOpacity>
      )}

      {/* Hộp thoại Thêm & Sửa người dùng */}
      <UserFormModal
        visible={formVisible}
        userToEdit={selectedUser}
        onClose={() => setFormVisible(false)}
        onSave={handleSaveUser}
      />

      {/* Hộp thoại Xem chi tiết */}
      <UserDetailModal
        visible={detailVisible}
        user={selectedUser}
        onClose={() => setDetailVisible(false)}
        onEdit={(user) => {
          setDetailVisible(false);
          handleOpenEdit(user);
        }}
      />

      {/* Hộp thoại Cài đặt CSDL & Xuất JSON */}
      <SettingsModal
        visible={settingsVisible}
        onClose={() => setSettingsVisible(false)}
        onConfigSaved={() => {
          checkConnection();
          loadData();
        }}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F3F4F6',
    ...(Platform.OS === 'web' ? { minHeight: '100vh', height: '100%' } : {}),
  },
  appBar: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    backgroundColor: '#fff',
    paddingHorizontal: 16,
    paddingTop: Platform.OS === 'ios' ? 44 : 12,
    paddingBottom: 12,
    borderBottomWidth: 1,
    borderColor: '#E5E7EB',
  },
  appBarLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
  },
  appBarTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#111827',
  },
  statusBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 8,
    paddingVertical: 3,
    borderRadius: 12,
  },
  statusConnected: {
    backgroundColor: '#DCFCE7',
  },
  statusFallback: {
    backgroundColor: '#FEF3C7',
  },
  statusDot: {
    width: 6,
    height: 6,
    borderRadius: 3,
    marginRight: 4,
  },
  dotGreen: {
    backgroundColor: '#16A34A',
  },
  dotOrange: {
    backgroundColor: '#D97706',
  },
  statusText: {
    fontSize: 11,
    fontWeight: '600',
  },
  statusTextGreen: {
    color: '#15803D',
  },
  statusTextOrange: {
    color: '#B45309',
  },
  appBarRight: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  iconBtn: {
    paddingHorizontal: 8,
    paddingVertical: 6,
    borderRadius: 8,
    backgroundColor: '#F3F4F6',
  },
  iconBtnText: {
    fontSize: 12,
    fontWeight: '600',
    color: '#374151',
  },
  contentScroll: {
    padding: 16,
  },
  statsRow: {
    flexDirection: 'row',
    gap: 12,
    marginBottom: 16,
  },
  statsRowVertical: {
    flexDirection: 'column',
  },
  statCard: {
    flex: 1,
    backgroundColor: '#fff',
    padding: 14,
    borderRadius: 14,
    borderWidth: 1,
    borderColor: '#E5E7EB',
  },
  statNum: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#111827',
  },
  statLabel: {
    fontSize: 12,
    color: '#6B7280',
    marginTop: 2,
  },
  toolbarCard: {
    backgroundColor: '#fff',
    padding: 12,
    borderRadius: 14,
    borderWidth: 1,
    borderColor: '#E5E7EB',
    marginBottom: 16,
  },
  searchInput: {
    backgroundColor: '#F9FAFB',
    borderWidth: 1,
    borderColor: '#D1D5DB',
    borderRadius: 8,
    paddingHorizontal: 12,
    paddingVertical: 8,
    fontSize: 13,
    marginBottom: 10,
  },
  toolbarActions: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  sortToggleBtn: {
    backgroundColor: '#F3F4F6',
    paddingHorizontal: 12,
    paddingVertical: 7,
    borderRadius: 8,
  },
  sortToggleText: {
    fontSize: 12,
    fontWeight: '600',
    color: '#374151',
  },
  addBtn: {
    backgroundColor: '#6750A4',
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 8,
  },
  addBtnText: {
    color: '#fff',
    fontWeight: 'bold',
    fontSize: 13,
  },
  loadingBox: {
    padding: 40,
    alignItems: 'center',
  },
  loadingText: {
    marginTop: 10,
    color: '#6B7280',
    fontSize: 13,
  },
  emptyBox: {
    padding: 40,
    alignItems: 'center',
  },
  emptyIcon: {
    fontSize: 48,
    marginBottom: 8,
  },
  emptyText: {
    color: '#6B7280',
    fontSize: 14,
  },
  // Table Web
  tableCard: {
    backgroundColor: '#fff',
    borderRadius: 14,
    borderWidth: 1,
    borderColor: '#E5E7EB',
    overflow: 'hidden',
  },
  tableHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#F9FAFB',
    paddingVertical: 12,
    paddingHorizontal: 14,
    borderBottomWidth: 1,
    borderColor: '#E5E7EB',
  },
  th: {
    fontSize: 12,
    fontWeight: 'bold',
    color: '#374151',
  },
  tableRow: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 10,
    paddingHorizontal: 14,
    borderBottomWidth: 1,
    borderColor: '#F3F4F6',
  },
  td: {
    fontSize: 13,
    color: '#374151',
  },
  tdBold: {
    fontWeight: '600',
    color: '#111827',
  },
  tableAvatar: {
    width: 38,
    height: 38,
    borderRadius: 19,
    backgroundColor: '#eee',
  },
  actionCell: {
    width: 140,
    flexDirection: 'row',
    justifyContent: 'center',
    gap: 6,
  },
  actionBtnView: {
    backgroundColor: '#E0F2FE',
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 6,
  },
  actionBtnEdit: {
    backgroundColor: '#FEF3C7',
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 6,
  },
  actionBtnDelete: {
    backgroundColor: '#FEE2E2',
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 6,
  },
  actionText: {
    fontSize: 11,
    fontWeight: '600',
  },
  // Mobile Card List
  mobileList: {
    gap: 10,
  },
  userCard: {
    backgroundColor: '#fff',
    borderRadius: 14,
    padding: 12,
    flexDirection: 'row',
    alignItems: 'center',
    borderWidth: 1,
    borderColor: '#E5E7EB',
  },
  cardAvatar: {
    width: 50,
    height: 50,
    borderRadius: 25,
    backgroundColor: '#eee',
    marginRight: 12,
  },
  cardInfo: {
    flex: 1,
  },
  cardName: {
    fontSize: 15,
    fontWeight: 'bold',
    color: '#111827',
  },
  cardEmail: {
    fontSize: 12,
    color: '#6B7280',
    marginTop: 2,
  },
  cardPwd: {
    fontSize: 11,
    color: '#9CA3AF',
    marginTop: 2,
  },
  cardActions: {
    flexDirection: 'row',
    gap: 8,
  },
  cardBtnEdit: {
    backgroundColor: '#FEF3C7',
    padding: 8,
    borderRadius: 8,
  },
  cardBtnDelete: {
    backgroundColor: '#FEE2E2',
    padding: 8,
    borderRadius: 8,
  },
  cardBtnText: {
    fontSize: 14,
  },
  fab: {
    position: 'absolute',
    bottom: 20,
    right: 20,
    backgroundColor: '#6750A4',
    paddingHorizontal: 20,
    paddingVertical: 14,
    borderRadius: 28,
    elevation: 5,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.25,
    shadowRadius: 4,
  },
  fabText: {
    color: '#fff',
    fontWeight: 'bold',
    fontSize: 15,
  },
});

