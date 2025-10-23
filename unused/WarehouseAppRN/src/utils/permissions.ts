import { Platform, PermissionsAndroid, Alert } from 'react-native';
import { check, request, PERMISSIONS, RESULTS } from 'react-native-permissions';

export const requestCameraPermission = async (): Promise<boolean> => {
  try {
    if (Platform.OS === 'android') {
      const granted = await PermissionsAndroid.request(
        PermissionsAndroid.PERMISSIONS.CAMERA,
        {
          title: 'Camera Permission',
          message: 'This app needs access to your camera to take photos of containers.',
          buttonNeutral: 'Ask Me Later',
          buttonNegative: 'Cancel',
          buttonPositive: 'OK',
        }
      );
      return granted === PermissionsAndroid.RESULTS.GRANTED;
    } else {
      const result = await request(PERMISSIONS.IOS.CAMERA);
      return result === RESULTS.GRANTED;
    }
  } catch (err) {
    console.warn('Camera permission error:', err);
    return false;
  }
};

export const requestStoragePermission = async (): Promise<boolean> => {
  try {
    if (Platform.OS === 'android') {
      const granted = await PermissionsAndroid.request(
        PermissionsAndroid.PERMISSIONS.WRITE_EXTERNAL_STORAGE,
        {
          title: 'Storage Permission',
          message: 'This app needs access to your storage to save photos and PDFs.',
          buttonNeutral: 'Ask Me Later',
          buttonNegative: 'Cancel',
          buttonPositive: 'OK',
        }
      );
      return granted === PermissionsAndroid.RESULTS.GRANTED;
    }
    return true; // iOS doesn't need explicit storage permission
  } catch (err) {
    console.warn('Storage permission error:', err);
    return false;
  }
};

export const requestPermissions = async (): Promise<void> => {
  const cameraGranted = await requestCameraPermission();
  const storageGranted = await requestStoragePermission();

  if (!cameraGranted || !storageGranted) {
    Alert.alert(
      'Permissions Required',
      'This app requires camera and storage permissions to function properly. Please enable them in your device settings.',
      [{ text: 'OK' }]
    );
  }
};
