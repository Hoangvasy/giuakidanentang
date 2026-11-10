import React, { useState, useEffect } from 'react';
import {
  Modal,
  View,
  Text,
  TextInput,
  TouchableOpacity,
  Image,
  ScrollView,
  StyleSheet,
  Alert,
  ActivityIndicator,
  Platform,
} from 'react-native';
import * as ImagePicker from 'expo-image-picker';
import { AppConstants } from '../constants';

export default function UserFormModal({ visible, userToEdit, onClose, onSave }) {
  const [hoten, setHoten] = useState('');
  const [email, setEmail] = useState('');
  const [matkhau, setMatkhau] = useState('');
  const [hinhanh, setHinhanh] = useState('');
  const [loading, setLoading] = useState(false);

  const isEditing = !!userToEdit;

  useEffect(() => {
    if (userToEdit) {
      setHoten(userToEdit.hoten || '');
      setEmail(userToEdit.email || '');
      setMatkhau(userToEdit.matkhau || '');
      setHinhanh(userToEdit.hinhanh || AppConstants.presetAvatars[0]);
    } else {
      setHoten('');
      setEmail('');
      setMatkhau('');
      setHinhanh(AppConstants.presetAvatars[0]);
    }
  }, [userToEdit, visible]);

  // 1. Chụp ảnh từ Camera (Yêu cầu di động của đề)
  const pickFromCamera = async () => {
    try {
      const { status } = await ImagePicker.requestCameraPermissionsAsync();
      if (status !== 'granted') {
        Alert.alert('Quyền truy cập', 'Cần cấp quyền camera để chụp ảnh đại diện!');
        return;
      }

      const result = await ImagePicker.launchCameraAsync({
        mediaTypes: ['images'],
        allowsEditing: true,
        aspect: [1, 1],
        quality: 0.7,
      });

      if (!result.canceled && result.assets && result.assets[0].uri) {
        setHinhanh(result.assets[0].uri);
      }
    } catch (e) {
      Alert.alert('Lỗi', 'Không thể mở Camera: ' + e.message);
    }
  };

  // 2. Chọn ảnh từ Thư viện (Gallery)
  const pickFromGallery = async () => {
    try {
      const { status } = await ImagePicker.requestMediaLibraryPermissionsAsync();
      if (status !== 'granted') {
        Alert.alert('Quyền truy cập', 'Cần cấp quyền thư viện để chọn ảnh!');
        return;
      }

      const result = await ImagePicker.launchImageLibraryAsync({
        mediaTypes: ['images'],
        allowsEditing: true,
        aspect: [1, 1],
        quality: 0.7,
      });

      if (!result.canceled && result.assets && result.assets[0].uri) {
        setHinhanh(result.assets[0].uri);
      }
    } catch (e) {
      Alert.alert('Lỗi', 'Không thể mở Thư viện: ' + e.message);
    }
  };

  const handleSave = () => {
    if (!hoten.trim()) {
      Alert.alert('Thông báo', 'Vui lòng nhập Họ và tên');
      return;
    }
    if (!email.trim() || !email.includes('@')) {
      Alert.alert('Thông báo', 'Vui lòng nhập Email hợp lệ');
      return;
    }
    if (!matkhau.trim() || matkhau.length < 6) {
      Alert.alert('Thông báo', 'Mật khẩu phải từ 6 ký tự trở lên');
      return;
    }
    if (!hinhanh.trim()) {
      Alert.alert('Thông báo', 'Vui lòng chọn hoặc nhập hình ảnh');
      return;
    }

    onSave({
      id: userToEdit ? userToEdit.id : undefined,
      hoten: hoten.trim(),
      email: email.trim(),
      matkhau: matkhau.trim(),
      hinhanh: hinhanh.trim(),
    });
  };

  return (
    <Modal visible={visible} animationType="slide" transparent={true}>
      <View style={styles.modalOverlay}>
        <View style={styles.modalContainer}>
          {/* Header */}
          <View style={styles.header}>
            <Text style={styles.headerTitle}>
              {isEditing ? 'Sửa Thông Tin Người Dùng' : 'Thêm Người Dùng Mới'}
            </Text>
            <TouchableOpacity onPress={onClose} style={styles.closeBtn}>
              <Text style={styles.closeBtnText}>✕</Text>
            </TouchableOpacity>
          </View>

          <ScrollView style={styles.scrollBody} showsVerticalScrollIndicator={false}>
            {/* Xem trước ảnh avatar */}
            <View style={styles.avatarPreviewContainer}>
              <Image
                source={{
                  uri:
                    hinhanh ||
                    'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde',
                }}
                style={styles.avatarPreview}
              />
              <View style={styles.imageActionRow}>
                <TouchableOpacity
                  style={styles.imageActionBtn}
                  onPress={pickFromCamera}
                >
                  <Text style={styles.imageActionText}>📷 Chụp Camera</Text>
                </TouchableOpacity>
                <TouchableOpacity
                  style={styles.imageActionBtn}
                  onPress={pickFromGallery}
                >
                  <Text style={styles.imageActionText}>🖼️ Thư viện</Text>
                </TouchableOpacity>
              </View>

              {/* Bộ avatar mẫu */}
              <Text style={styles.subLabel}>Hoặc chọn avatar mẫu:</Text>
              <View style={styles.presetRow}>
                {AppConstants.presetAvatars.map((url, idx) => (
                  <TouchableOpacity
                    key={idx}
                    onPress={() => setHinhanh(url)}
                    style={[
                      styles.presetItem,
                      hinhanh === url && styles.presetItemActive,
                    ]}
                  >
                    <Image source={{ uri: url }} style={styles.presetImage} />
                  </TouchableOpacity>
                ))}
              </View>
            </View>

            {/* 1. Họ và tên */}
            <Text style={styles.inputLabel}>Họ và tên *</Text>
            <TextInput
              style={styles.input}
              placeholder="Nhập họ và tên đầy đủ"
              value={hoten}
              onChangeText={setHoten}
            />

            {/* 2. Email */}
            <Text style={styles.inputLabel}>Email *</Text>
            <TextInput
              style={styles.input}
              placeholder="example@gmail.com"
              keyboardType="email-address"
              autoCapitalize="none"
              value={email}
              onChangeText={setEmail}
            />

            {/* 3. Mật khẩu */}
            <Text style={styles.inputLabel}>Mật khẩu *</Text>
            <TextInput
              style={styles.input}
              placeholder="Nhập mật khẩu (tối thiểu 6 ký tự)"
              secureTextEntry
              value={matkhau}
              onChangeText={setMatkhau}
            />

            {/* 4. Đường dẫn ảnh (hinhanh) */}
            <Text style={styles.inputLabel}>Đường dẫn ảnh (URL hoặc URI) *</Text>
            <TextInput
              style={styles.input}
              placeholder="https://... hoặc file:///..."
              value={hinhanh}
              onChangeText={setHinhanh}
            />

            <View style={{ height: 20 }} />
          </ScrollView>

          {/* Nút hành động */}
          <View style={styles.footer}>
            <TouchableOpacity style={styles.cancelBtn} onPress={onClose}>
              <Text style={styles.cancelBtnText}>Hủy</Text>
            </TouchableOpacity>
            <TouchableOpacity style={styles.submitBtn} onPress={handleSave}>
              <Text style={styles.submitBtnText}>
                {isEditing ? 'Cập Nhật' : 'Thêm Mới'}
              </Text>
            </TouchableOpacity>
          </View>
        </View>
      </View>
    </Modal>
  );
}

const styles = StyleSheet.create({
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.5)',
    justifyContent: 'center',
    alignItems: 'center',
    padding: 16,
  },
  modalContainer: {
    backgroundColor: '#fff',
    borderRadius: 20,
    width: '100%',
    maxWidth: 520,
    maxHeight: '90%',
    overflow: 'hidden',
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 18,
    borderBottomWidth: 1,
    borderColor: '#eee',
  },
  headerTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#1F2937',
  },
  closeBtn: {
    padding: 6,
  },
  closeBtnText: {
    fontSize: 18,
    color: '#6B7280',
    fontWeight: 'bold',
  },
  scrollBody: {
    padding: 18,
  },
  avatarPreviewContainer: {
    alignItems: 'center',
    marginBottom: 16,
  },
  avatarPreview: {
    width: 86,
    height: 86,
    borderRadius: 43,
    backgroundColor: '#eee',
    marginBottom: 10,
    borderWidth: 2,
    borderColor: '#6750A4',
  },
  imageActionRow: {
    flexDirection: 'row',
    gap: 10,
    marginBottom: 10,
  },
  imageActionBtn: {
    backgroundColor: '#F3F4F6',
    paddingHorizontal: 12,
    paddingVertical: 7,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: '#D1D5DB',
  },
  imageActionText: {
    fontSize: 13,
    color: '#374151',
    fontWeight: '500',
  },
  subLabel: {
    fontSize: 12,
    color: '#6B7280',
    marginTop: 4,
    marginBottom: 6,
  },
  presetRow: {
    flexDirection: 'row',
    gap: 8,
  },
  presetItem: {
    borderRadius: 20,
    padding: 2,
    borderWidth: 2,
    borderColor: 'transparent',
  },
  presetItemActive: {
    borderColor: '#6750A4',
  },
  presetImage: {
    width: 36,
    height: 36,
    borderRadius: 18,
  },
  inputLabel: {
    fontSize: 13,
    fontWeight: '600',
    color: '#374151',
    marginBottom: 6,
    marginTop: 10,
  },
  input: {
    backgroundColor: '#F9FAFB',
    borderWidth: 1,
    borderColor: '#D1D5DB',
    borderRadius: 10,
    paddingHorizontal: 14,
    paddingVertical: 10,
    fontSize: 14,
    color: '#111827',
  },
  footer: {
    flexDirection: 'row',
    justifyContent: 'flex-end',
    gap: 12,
    padding: 16,
    borderTopWidth: 1,
    borderColor: '#eee',
  },
  cancelBtn: {
    paddingHorizontal: 16,
    paddingVertical: 10,
    borderRadius: 8,
  },
  cancelBtnText: {
    color: '#6B7280',
    fontWeight: '600',
  },
  submitBtn: {
    backgroundColor: '#6750A4',
    paddingHorizontal: 20,
    paddingVertical: 10,
    borderRadius: 8,
  },
  submitBtnText: {
    color: '#fff',
    fontWeight: 'bold',
  },
});

