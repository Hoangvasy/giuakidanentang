import React, { useState } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  ActivityIndicator,
  Alert,
  KeyboardAvoidingView,
  Platform,
  ScrollView,
} from 'react-native';
import { authService } from '../services/authService';
import { AppConstants } from '../constants';

export default function LoginScreen({ onLoginSuccess }) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [errorMsg, setErrorMsg] = useState('');

  // Tự động điền tài khoản admin mẫu
  const fillSampleAdmin = () => {
    setEmail(AppConstants.defaultAdminEmail);
    setPassword(AppConstants.defaultAdminPassword);
    setErrorMsg('');
  };

  // Tự động điền tài khoản người dùng mẫu từ CSDL
  const fillSampleUser = () => {
    setEmail('nguyenvanan@gmail.com');
    setPassword('an123456');
    setErrorMsg('');
  };

  const handleLogin = async () => {
    if (!email.trim()) {
      setErrorMsg('Vui lòng nhập Email');
      return;
    }
    if (!password.trim()) {
      setErrorMsg('Vui lòng nhập Mật khẩu');
      return;
    }

    setLoading(true);
    setErrorMsg('');

    const success = await authService.login(email, password);
    setLoading(false);

    if (success) {
      onLoginSuccess();
    } else {
      setErrorMsg(
        'Email hoặc mật khẩu không chính xác! (Gợi ý: admin@gmail.com / admin123)'
      );
    }
  };

  return (
    <KeyboardAvoidingView
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
      style={styles.container}
    >
      <ScrollView
        contentContainerStyle={styles.scrollContent}
        keyboardShouldPersistTaps="handled"
      >
        <View style={styles.card}>
          {/* Logo Icon */}
          <View style={styles.logoBadge}>
            <Text style={styles.logoIcon}>🛡️</Text>
          </View>

          <Text style={styles.title}>Phân Hệ Quản Trị Viên</Text>
          <Text style={styles.subtitle}>
            Đăng nhập để quản lý cơ sở dữ liệu người dùng
          </Text>

          {errorMsg !== '' && (
            <View style={styles.errorBox}>
              <Text style={styles.errorText}>⚠️ {errorMsg}</Text>
            </View>
          )}

          {/* Email */}
          <Text style={styles.label}>Email</Text>
          <TextInput
            style={styles.input}
            placeholder="admin@gmail.com"
            keyboardType="email-address"
            autoCapitalize="none"
            value={email}
            onChangeText={(txt) => {
              setEmail(txt);
              setErrorMsg('');
            }}
          />

          {/* Mật khẩu */}
          <Text style={styles.label}>Mật khẩu</Text>
          <View style={styles.pwdWrapper}>
            <TextInput
              style={styles.pwdInput}
              placeholder="Nhập mật khẩu"
              secureTextEntry={!showPassword}
              value={password}
              onChangeText={(txt) => {
                setPassword(txt);
                setErrorMsg('');
              }}
            />
            <TouchableOpacity
              onPress={() => setShowPassword(!showPassword)}
              style={styles.eyeBtn}
            >
              <Text style={styles.eyeBtnText}>
                {showPassword ? 'Ẩn' : 'Hiện'}
              </Text>
            </TouchableOpacity>
          </View>

          {/* Nút Đăng nhập */}
          <TouchableOpacity
            style={styles.loginBtn}
            onPress={handleLogin}
            disabled={loading}
          >
            {loading ? (
              <ActivityIndicator color="#fff" />
            ) : (
              <Text style={styles.loginBtnText}>ĐĂNG NHẬP</Text>
            )}
          </TouchableOpacity>

          {/* Nút điền nhanh */}
          <TouchableOpacity
            style={styles.sampleBtn}
            onPress={fillSampleAdmin}
          >
            <Text style={styles.sampleBtnText}>
              ⚡ Điền tài khoản Admin (admin@gmail.com)
            </Text>
          </TouchableOpacity>

          <TouchableOpacity
            style={[styles.sampleBtn, { marginTop: 8 }]}
            onPress={fillSampleUser}
          >
            <Text style={styles.sampleBtnText}>
              👤 Điền tài khoản User mẫu (nguyenvanan@gmail.com)
            </Text>
          </TouchableOpacity>
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F3F4F6',
  },
  scrollContent: {
    flexGrow: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  card: {
    backgroundColor: '#fff',
    borderRadius: 24,
    padding: 28,
    width: '100%',
    maxWidth: 440,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.08,
    shadowRadius: 16,
    elevation: 4,
  },
  logoBadge: {
    alignSelf: 'center',
    width: 68,
    height: 68,
    borderRadius: 34,
    backgroundColor: '#EADDFF',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 16,
  },
  logoIcon: {
    fontSize: 32,
  },
  title: {
    fontSize: 22,
    fontWeight: 'bold',
    textAlign: 'center',
    color: '#111827',
  },
  subtitle: {
    fontSize: 13,
    color: '#6B7280',
    textAlign: 'center',
    marginTop: 4,
    marginBottom: 24,
  },
  errorBox: {
    backgroundColor: '#FEE2E2',
    borderWidth: 1,
    borderColor: '#FCA5A5',
    borderRadius: 8,
    padding: 10,
    marginBottom: 14,
  },
  errorText: {
    color: '#B91C1C',
    fontSize: 12,
  },
  label: {
    fontSize: 13,
    fontWeight: '600',
    color: '#374151',
    marginBottom: 6,
  },
  input: {
    backgroundColor: '#F9FAFB',
    borderWidth: 1,
    borderColor: '#D1D5DB',
    borderRadius: 10,
    paddingHorizontal: 14,
    paddingVertical: 11,
    fontSize: 14,
    marginBottom: 14,
  },
  pwdWrapper: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#F9FAFB',
    borderWidth: 1,
    borderColor: '#D1D5DB',
    borderRadius: 10,
    marginBottom: 20,
  },
  pwdInput: {
    flex: 1,
    paddingHorizontal: 14,
    paddingVertical: 11,
    fontSize: 14,
  },
  eyeBtn: {
    paddingHorizontal: 12,
    paddingVertical: 10,
  },
  eyeBtnText: {
    fontSize: 12,
    color: '#6750A4',
    fontWeight: 'bold',
  },
  loginBtn: {
    backgroundColor: '#6750A4',
    paddingVertical: 14,
    borderRadius: 12,
    alignItems: 'center',
    marginBottom: 12,
  },
  loginBtnText: {
    color: '#fff',
    fontSize: 15,
    fontWeight: 'bold',
    letterSpacing: 0.5,
  },
  sampleBtn: {
    borderWidth: 1,
    borderColor: '#D1D5DB',
    paddingVertical: 12,
    borderRadius: 12,
    alignItems: 'center',
    backgroundColor: '#F9FAFB',
  },
  sampleBtnText: {
    color: '#4B5563',
    fontSize: 13,
    fontWeight: '600',
  },
});

