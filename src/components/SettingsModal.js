import React, { useState, useEffect } from 'react';
import {
  Modal,
  View,
  Text,
  TextInput,
  TouchableOpacity,
  ScrollView,
  StyleSheet,
  Alert,
  ActivityIndicator,
} from 'react-native';
import { firebaseService } from '../services/firebaseService';
import { AppConstants } from '../constants';

export default function SettingsModal({ visible, onClose, onConfigSaved }) {
  const [url, setUrl] = useState('');
  const [isTesting, setIsTesting] = useState(false);
  const [testResult, setTestResult] = useState(null);
  const [exportJsonStr, setExportJsonStr] = useState('');

  useEffect(() => {
    if (visible) {
      setUrl(firebaseService.databaseUrl);
      setTestResult(null);
      setExportJsonStr('');
    }
  }, [visible]);

  const handleTestConnection = async () => {
    setIsTesting(true);
    setTestResult(null);

    await firebaseService.setDatabaseUrl(url);
    const ok = await firebaseService.testConnection();

    setIsTesting(false);
    setTestResult({
      success: ok,
      message: ok
        ? 'Kết nối Firebase thành công! (200 OK)'
        : 'Không thể kết nối! Vui lòng kiểm tra lại URL hoặc Rules (cần mở .read/.write: true)',
    });
  };

  const handleReset = () => {
    setUrl(AppConstants.defaultFirebaseUrl);
    setTestResult({
      success: true,
      message: 'Đã khôi phục URL Firebase mặc định',
    });
  };

  const handleSave = async () => {
    await firebaseService.setDatabaseUrl(url);
    onConfigSaved();
    onClose();
    Alert.alert('Thành công', 'Đã lưu cấu hình kết nối CSDL');
  };

  const handleExportJson = async () => {
    const jsonStr = await firebaseService.exportDatabaseJson();
    setExportJsonStr(jsonStr);
  };

  return (
    <Modal visible={visible} animationType="slide" transparent={true}>
      <View style={styles.overlay}>
        <View style={styles.card}>
          <View style={styles.header}>
            <Text style={styles.title}>Cấu Hình Cơ Sở Dữ Liệu</Text>
            <TouchableOpacity onPress={onClose}>
              <Text style={styles.closeText}>✕</Text>
            </TouchableOpacity>
          </View>

          <ScrollView style={styles.body} showsVerticalScrollIndicator={false}>
            <Text style={styles.sectionTitle}>URL Firebase Realtime Database:</Text>
            <Text style={styles.desc}>
              Đường link kết thúc bằng .firebasedatabase.app hoặc .firebaseio.com
            </Text>

            <TextInput
              style={styles.input}
              placeholder="https://your-project-default-rtdb.firebaseio.com"
              value={url}
              onChangeText={setUrl}
              autoCapitalize="none"
            />

            <View style={styles.btnRow}>
              <TouchableOpacity
                style={styles.testBtn}
                onPress={handleTestConnection}
                disabled={isTesting}
              >
                {isTesting ? (
                  <ActivityIndicator size="small" color="#fff" />
                ) : (
                  <Text style={styles.testBtnText}>Kiểm tra kết nối</Text>
                )}
              </TouchableOpacity>
              <TouchableOpacity style={styles.resetBtn} onPress={handleReset}>
                <Text style={styles.resetBtnText}>Mặc định</Text>
              </TouchableOpacity>
            </View>

            {testResult && (
              <View
                style={[
                  styles.resultBox,
                  testResult.success ? styles.resultSuccess : styles.resultError,
                ]}
              >
                <Text
                  style={[
                    styles.resultText,
                    testResult.success
                      ? styles.resultTextSuccess
                      : styles.resultTextError,
                  ]}
                >
                  {testResult.success ? '✓ ' : '✕ '}
                  {testResult.message}
                </Text>
              </View>
            )}

            <View style={styles.divider} />

            <Text style={styles.sectionTitle}>Xuất CSDL ra JSON (Nộp bài):</Text>
            <Text style={styles.desc}>
              Xuất dữ liệu đúng chuẩn 4 trường (email, matkhau, hoten, hinhanh):
            </Text>

            <TouchableOpacity style={styles.exportBtn} onPress={handleExportJson}>
              <Text style={styles.exportBtnText}>📄 Tải / Xem Dữ Liệu JSON</Text>
            </TouchableOpacity>

            {exportJsonStr !== '' && (
              <View style={styles.codeContainer}>
                <ScrollView horizontal showsHorizontalScrollIndicator={false}>
                  <Text style={styles.codeText}>{exportJsonStr}</Text>
                </ScrollView>
              </View>
            )}
          </ScrollView>

          <View style={styles.footer}>
            <TouchableOpacity style={styles.closeBtn} onPress={onClose}>
              <Text style={styles.closeBtnText}>Đóng</Text>
            </TouchableOpacity>
            <TouchableOpacity style={styles.saveBtn} onPress={handleSave}>
              <Text style={styles.saveBtnText}>Lưu Cấu Hình</Text>
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
    maxWidth: 520,
    maxHeight: '85%',
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 18,
    borderBottomWidth: 1,
    borderColor: '#eee',
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
    padding: 18,
  },
  sectionTitle: {
    fontSize: 14,
    fontWeight: 'bold',
    color: '#1F2937',
    marginBottom: 4,
  },
  desc: {
    fontSize: 12,
    color: '#6B7280',
    marginBottom: 8,
  },
  input: {
    backgroundColor: '#F9FAFB',
    borderWidth: 1,
    borderColor: '#D1D5DB',
    borderRadius: 10,
    paddingHorizontal: 12,
    paddingVertical: 10,
    fontSize: 13,
    marginBottom: 10,
  },
  btnRow: {
    flexDirection: 'row',
    gap: 10,
    marginBottom: 12,
  },
  testBtn: {
    backgroundColor: '#4B5563',
    paddingHorizontal: 14,
    paddingVertical: 8,
    borderRadius: 8,
  },
  testBtnText: {
    color: '#fff',
    fontSize: 13,
    fontWeight: '600',
  },
  resetBtn: {
    backgroundColor: '#F3F4F6',
    paddingHorizontal: 14,
    paddingVertical: 8,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: '#D1D5DB',
  },
  resetBtnText: {
    color: '#374151',
    fontSize: 13,
  },
  resultBox: {
    padding: 10,
    borderRadius: 8,
    marginBottom: 14,
  },
  resultSuccess: {
    backgroundColor: '#DCFCE7',
  },
  resultError: {
    backgroundColor: '#FEE2E2',
  },
  resultText: {
    fontSize: 12,
    fontWeight: '500',
  },
  resultTextSuccess: {
    color: '#15803D',
  },
  resultTextError: {
    color: '#B91C1C',
  },
  divider: {
    height: 1,
    backgroundColor: '#E5E7EB',
    marginVertical: 14,
  },
  exportBtn: {
    backgroundColor: '#EEF2FF',
    borderWidth: 1,
    borderColor: '#C7D2FE',
    paddingVertical: 10,
    borderRadius: 8,
    alignItems: 'center',
    marginBottom: 10,
  },
  exportBtnText: {
    color: '#4338CA',
    fontWeight: '600',
    fontSize: 13,
  },
  codeContainer: {
    backgroundColor: '#1E293B',
    borderRadius: 8,
    padding: 12,
    maxHeight: 180,
    marginBottom: 10,
  },
  codeText: {
    color: '#38BDF8',
    fontFamily: 'monospace',
    fontSize: 11,
  },
  footer: {
    flexDirection: 'row',
    justifyContent: 'flex-end',
    gap: 10,
    padding: 16,
    borderTopWidth: 1,
    borderColor: '#eee',
  },
  closeBtn: {
    paddingHorizontal: 16,
    paddingVertical: 10,
  },
  closeBtnText: {
    color: '#6B7280',
    fontWeight: '600',
  },
  saveBtn: {
    backgroundColor: '#6750A4',
    paddingHorizontal: 18,
    paddingVertical: 10,
    borderRadius: 8,
  },
  saveBtnText: {
    color: '#fff',
    fontWeight: 'bold',
  },
});

