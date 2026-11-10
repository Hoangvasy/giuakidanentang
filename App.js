import React, { useState, useEffect } from 'react';
import { View, ActivityIndicator, StyleSheet } from 'react-native';
import { StatusBar } from 'expo-status-bar';
import { authService } from './src/services/authService';
import LoginScreen from './src/screens/LoginScreen';
import AdminDashboardScreen from './src/screens/AdminDashboardScreen';

export default function App() {
  const [isCheckingAuth, setIsCheckingAuth] = useState(true);
  const [isLoggedIn, setIsLoggedIn] = useState(false);

  useEffect(() => {
    checkAuth();
  }, []);

  const checkAuth = async () => {
    // Để phục vụ quay video demo chấm điểm, app luôn bắt đầu từ màn hình Đăng nhập
    setIsLoggedIn(false);
    setIsCheckingAuth(false);
  };

  if (isCheckingAuth) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color="#6750A4" />
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <StatusBar style="auto" />
      {isLoggedIn ? (
        <AdminDashboardScreen onLogout={() => setIsLoggedIn(false)} />
      ) : (
        <LoginScreen onLoginSuccess={() => setIsLoggedIn(true)} />
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F3F4F6',
  },
});

