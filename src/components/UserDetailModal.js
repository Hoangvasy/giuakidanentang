import React, { useState } from 'react';
import {
  Modal,
  View,
  Text,
  TouchableOpacity,
  Image,
  StyleSheet,
} from 'react-native';

export default function UserDetailModal({ visible, user, onClose, onEdit }) {
  const [showPassword, setShowPassword] = useState(false);

  if (!user) return null;

  return (
    <Modal visible={visible} animationType="fade" transparent={true}>
      <View style={styles.overlay}>
        <View style={styles.card}>
          <View style={styles.header}>
            <Text style={styles.title}>Chi Tiết Người Dùng</Text>
            <TouchableOpacity onPress={onClose}>
              <Text style={styles.closeText}>✕</Text>
            </TouchableOpacity>
          </View>

          <View style={styles.body}>
            <Image
              source={{
                uri:
                  user.hinhanh ||
                  'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde',
              }}
              style={styles.avatar}
            />
            <Text style={styles.name}>{user.hoten}</Text>
            <Text style={styles.roleBadge}>Người dùng CSDL</Text>

            <View style={styles.infoBox}>
              <View style={styles.infoRow}>
                <Text style={styles.label}>Email:</Text>
                <Text style={styles.value}>{user.email}</Text>
              </View>
              <View style={styles.divider} />

              <View style={styles.infoRow}>
                <Text style={styles.label}>Mật khẩu:</Text>
                <View style={styles.pwdRow}>
                  <Text style={styles.value}>
                    {showPassword ? user.matkhau : '••••••••'}
                  </Text>
                  <TouchableOpacity
                    onPress={() => setShowPassword(!showPassword)}
                    style={styles.eyeBtn}
                  >
                    <Text style={styles.eyeText}>
                      {showPassword ? 'Ẩn' : 'Hiện'}
                    </Text>
                  </TouchableOpacity>
                </View>
              </View>
              <View style={styles.divider} />

              <View style={styles.infoRow}>
                <Text style={styles.label}>ID CSDL:</Text>
                <Text style={styles.valueId}>{user.id || 'N/A'}</Text>
              </View>
            </View>
          </View>

          <View style={styles.footer}>
            <TouchableOpacity style={styles.closeBtn} onPress={onClose}>
              <Text style={styles.closeBtnText}>Đóng</Text>
            </TouchableOpacity>
            <TouchableOpacity
              style={styles.editBtn}
              onPress={() => {
                onClose();
                onEdit(user);
              }}
            >
              <Text style={styles.editBtnText}>Sửa thông tin</Text>
            </TouchableOpacity>
          </View>
        </View>
      </View>
    </Modal>
  );
}

const styles = StyleSheet.create({
  overlay: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.5)',
    justifyContent: 'center',
    alignItems: 'center',
    padding: 16,
  },
  card: {
    backgroundColor: '#fff',
    borderRadius: 20,
    width: '100%',
    maxWidth: 440,
    padding: 20,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 16,
  },
  title: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#1F2937',
  },
  closeText: {
    fontSize: 18,
    color: '#6B7280',
    fontWeight: 'bold',
  },
  body: {
    alignItems: 'center',
  },
  avatar: {
    width: 90,
    height: 90,
    borderRadius: 45,
    backgroundColor: '#eee',
    marginBottom: 12,
  },
  name: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#111827',
  },
  roleBadge: {
    fontSize: 12,
    color: '#6750A4',
    backgroundColor: '#EADDFF',
    paddingHorizontal: 10,
    paddingVertical: 3,
    borderRadius: 12,
    marginTop: 4,
    marginBottom: 16,
    fontWeight: '600',
  },
  infoBox: {
    width: '100%',
    backgroundColor: '#F9FAFB',
    borderRadius: 12,
    padding: 14,
    borderWidth: 1,
    borderColor: '#E5E7EB',
  },
  infoRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 6,
  },
  divider: {
    height: 1,
    backgroundColor: '#E5E7EB',
  },
  label: {
    fontSize: 13,
    color: '#6B7280',
    fontWeight: '500',
  },
  value: {
    fontSize: 14,
    color: '#1F2937',
    fontWeight: '600',
  },
  valueId: {
    fontSize: 12,
    color: '#6B7280',
    fontFamily: 'monospace',
  },
  pwdRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  eyeBtn: {
    backgroundColor: '#E5E7EB',
    paddingHorizontal: 8,
    paddingVertical: 2,
    borderRadius: 6,
  },
  eyeText: {
    fontSize: 11,
    color: '#374151',
    fontWeight: '600',
  },
  footer: {
    flexDirection: 'row',
    justifyContent: 'flex-end',
    gap: 12,
    marginTop: 20,
  },
  closeBtn: {
    paddingHorizontal: 16,
    paddingVertical: 10,
  },
  closeBtnText: {
    color: '#6B7280',
    fontWeight: '600',
  },
  editBtn: {
    backgroundColor: '#6750A4',
    paddingHorizontal: 18,
    paddingVertical: 10,
    borderRadius: 8,
  },
  editBtnText: {
    color: '#fff',
    fontWeight: 'bold',
  },
});

