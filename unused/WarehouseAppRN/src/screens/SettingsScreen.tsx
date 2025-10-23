import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  TextInput,
  Switch,
  Alert,
} from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { useApp } from '../context/AppContext';
import Toast from 'react-native-toast-message';

const SettingsScreen = ({ navigation }: any) => {
  const { syncWithGoogleSheets, isOffline, isLoading } = useApp();
  const [adminEmail, setAdminEmail] = useState('');
  const [autoSync, setAutoSync] = useState(true);
  const [debugMode, setDebugMode] = useState(false);

  const handleSync = async () => {
    try {
      await syncWithGoogleSheets();
      Toast.show({
        type: 'success',
        text1: 'Synced',
        text2: 'Data synced with Google Sheets',
      });
    } catch (error) {
      Toast.show({
        type: 'error',
        text1: 'Sync Failed',
        text2: 'Could not sync with Google Sheets',
      });
    }
  };

  const handleClearCache = async () => {
    Alert.alert(
      'Clear Cache',
      'Are you sure you want to clear all cached data? This will not delete your containers.',
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Clear',
          style: 'destructive',
          onPress: async () => {
            try {
              // Clear specific cache keys, not all data
              await AsyncStorage.removeItem('@cache_data');
              Toast.show({
                type: 'success',
                text1: 'Cache Cleared',
                text2: 'Cached data has been cleared',
              });
            } catch (error) {
              Alert.alert('Error', 'Failed to clear cache');
            }
          },
        },
      ]
    );
  };

  const handleSaveSettings = async () => {
    try {
      await AsyncStorage.setItem('@settings', JSON.stringify({
        adminEmail,
        autoSync,
        debugMode,
      }));
      Toast.show({
        type: 'success',
        text1: 'Saved',
        text2: 'Settings saved successfully',
      });
    } catch (error) {
      Alert.alert('Error', 'Failed to save settings');
    }
  };

  return (
    <ScrollView style={styles.container}>
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Sync Settings</Text>
        
        <View style={styles.statusRow}>
          <Text style={styles.statusLabel}>Connection Status:</Text>
          <View style={[styles.statusBadge, isOffline ? styles.offlineBadge : styles.onlineBadge]}>
            <Text style={styles.statusText}>
              {isOffline ? '⚠️ Offline' : '✓ Online'}
            </Text>
          </View>
        </View>

        <TouchableOpacity
          style={[styles.button, isLoading && styles.buttonDisabled]}
          onPress={handleSync}
          disabled={isLoading}
        >
          <Text style={styles.buttonText}>
            {isLoading ? 'Syncing...' : '🔄 Sync Now'}
          </Text>
        </TouchableOpacity>

        <View style={styles.settingRow}>
          <Text style={styles.settingLabel}>Auto-sync when online</Text>
          <Switch
            value={autoSync}
            onValueChange={setAutoSync}
            trackColor={{ false: '#ccc', true: '#2563eb' }}
          />
        </View>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Notifications</Text>
        
        <Text style={styles.label}>Admin Email</Text>
        <TextInput
          style={styles.input}
          value={adminEmail}
          onChangeText={setAdminEmail}
          placeholder="admin@company.com"
          keyboardType="email-address"
          autoCapitalize="none"
        />
        <Text style={styles.helpText}>
          Email address to receive discrepancy notifications
        </Text>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Advanced</Text>
        
        <View style={styles.settingRow}>
          <Text style={styles.settingLabel}>Debug Mode</Text>
          <Switch
            value={debugMode}
            onValueChange={setDebugMode}
            trackColor={{ false: '#ccc', true: '#2563eb' }}
          />
        </View>

        <TouchableOpacity style={styles.button} onPress={handleClearCache}>
          <Text style={styles.buttonText}>🗑️ Clear Cache</Text>
        </TouchableOpacity>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>About</Text>
        <Text style={styles.infoText}>Warehouse Container Tracker</Text>
        <Text style={styles.infoText}>Version 1.0.0</Text>
        <Text style={styles.infoText}>React Native Edition</Text>
      </View>

      <TouchableOpacity style={styles.saveButton} onPress={handleSaveSettings}>
        <Text style={styles.saveButtonText}>Save Settings</Text>
      </TouchableOpacity>

      <View style={styles.spacer} />
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  section: {
    backgroundColor: '#fff',
    padding: 16,
    marginBottom: 12,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 16,
  },
  statusRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 16,
  },
  statusLabel: {
    fontSize: 16,
    color: '#666',
  },
  statusBadge: {
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 12,
  },
  onlineBadge: {
    backgroundColor: '#4caf50',
  },
  offlineBadge: {
    backgroundColor: '#ff9800',
  },
  statusText: {
    color: '#fff',
    fontWeight: 'bold',
  },
  button: {
    backgroundColor: '#2563eb',
    padding: 14,
    borderRadius: 8,
    alignItems: 'center',
    marginVertical: 8,
  },
  buttonDisabled: {
    opacity: 0.5,
  },
  buttonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: 'bold',
  },
  settingRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
  },
  settingLabel: {
    fontSize: 16,
    color: '#333',
  },
  label: {
    fontSize: 14,
    color: '#666',
    marginBottom: 8,
  },
  input: {
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    padding: 12,
    fontSize: 16,
    marginBottom: 8,
  },
  helpText: {
    fontSize: 12,
    color: '#999',
    fontStyle: 'italic',
  },
  infoText: {
    fontSize: 14,
    color: '#666',
    marginBottom: 4,
  },
  saveButton: {
    margin: 16,
    backgroundColor: '#4caf50',
    padding: 16,
    borderRadius: 8,
    alignItems: 'center',
  },
  saveButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: 'bold',
  },
  spacer: {
    height: 40,
  },
});

export default SettingsScreen;
