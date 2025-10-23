import React, { useState, useRef, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  Alert,
  ActivityIndicator,
} from 'react-native';
import { Camera, useCameraDevices, useFrameProcessor } from 'react-native-vision-camera';
import { useApp } from '../context/AppContext';
import Toast from 'react-native-toast-message';
import RNFS from 'react-native-fs';

const CameraScreen = ({ route, navigation }: any) => {
  const { containerId } = route.params;
  const { currentContainer, updateContainer } = useApp();
  const [hasPermission, setHasPermission] = useState(false);
  const [isActive, setIsActive] = useState(true);
  const [flashMode, setFlashMode] = useState<'off' | 'on'>('off');
  const [isTakingPhoto, setIsTakingPhoto] = useState(false);
  
  const camera = useRef<Camera>(null);
  const devices = useCameraDevices();
  const device = devices.back;

  useEffect(() => {
    checkPermission();
    return () => setIsActive(false);
  }, []);

  const checkPermission = async () => {
    const status = await Camera.requestCameraPermission();
    setHasPermission(status === 'authorized');
  };

  const takePhoto = async () => {
    if (!camera.current || isTakingPhoto) return;

    try {
      setIsTakingPhoto(true);
      
      const photo = await camera.current.takePhoto({
        flash: flashMode,
        qualityPrioritization: 'quality',
      });

      // Copy photo to app's documents directory
      const fileName = `photo_${Date.now()}.jpg`;
      const destPath = `${RNFS.DocumentDirectoryPath}/${fileName}`;
      await RNFS.copyFile(photo.path, destPath);

      // Update container with new photo
      if (currentContainer) {
        const updatedContainer = {
          ...currentContainer,
          photoPaths: [...currentContainer.photoPaths, destPath],
        };
        await updateContainer(updatedContainer);
      }

      Toast.show({
        type: 'success',
        text1: 'Photo Captured',
        text2: 'Photo added to container',
      });

      navigation.goBack();
    } catch (error) {
      console.error('Error taking photo:', error);
      Alert.alert('Error', 'Failed to take photo');
    } finally {
      setIsTakingPhoto(false);
    }
  };

  const toggleFlash = () => {
    setFlashMode(flashMode === 'off' ? 'on' : 'off');
  };

  if (!hasPermission) {
    return (
      <View style={styles.container}>
        <Text style={styles.permissionText}>Camera permission required</Text>
      </View>
    );
  }

  if (!device) {
    return (
      <View style={styles.container}>
        <ActivityIndicator size="large" color="#2563eb" />
        <Text style={styles.loadingText}>Loading camera...</Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <Camera
        ref={camera}
        style={StyleSheet.absoluteFill}
        device={device}
        isActive={isActive}
        photo={true}
      />

      <View style={styles.topBar}>
        <TouchableOpacity style={styles.closeButton} onPress={() => navigation.goBack()}>
          <Text style={styles.closeButtonText}>✕</Text>
        </TouchableOpacity>
        
        <TouchableOpacity style={styles.flashButton} onPress={toggleFlash}>
          <Text style={styles.flashButtonText}>
            {flashMode === 'off' ? '⚡ Off' : '⚡ On'}
          </Text>
        </TouchableOpacity>
      </View>

      <View style={styles.bottomBar}>
        <TouchableOpacity
          style={[styles.captureButton, isTakingPhoto && styles.captureButtonDisabled]}
          onPress={takePhoto}
          disabled={isTakingPhoto}
        >
          {isTakingPhoto ? (
            <ActivityIndicator color="#fff" />
          ) : (
            <View style={styles.captureButtonInner} />
          )}
        </TouchableOpacity>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#000',
    justifyContent: 'center',
    alignItems: 'center',
  },
  permissionText: {
    color: '#fff',
    fontSize: 16,
    textAlign: 'center',
  },
  loadingText: {
    color: '#fff',
    fontSize: 16,
    marginTop: 12,
  },
  topBar: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    flexDirection: 'row',
    justifyContent: 'space-between',
    padding: 20,
    paddingTop: 40,
  },
  closeButton: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: 'rgba(0,0,0,0.5)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  closeButtonText: {
    color: '#fff',
    fontSize: 24,
    fontWeight: 'bold',
  },
  flashButton: {
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 20,
    backgroundColor: 'rgba(0,0,0,0.5)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  flashButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: 'bold',
  },
  bottomBar: {
    position: 'absolute',
    bottom: 40,
    left: 0,
    right: 0,
    alignItems: 'center',
  },
  captureButton: {
    width: 70,
    height: 70,
    borderRadius: 35,
    backgroundColor: 'rgba(255,255,255,0.3)',
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 4,
    borderColor: '#fff',
  },
  captureButtonDisabled: {
    opacity: 0.5,
  },
  captureButtonInner: {
    width: 60,
    height: 60,
    borderRadius: 30,
    backgroundColor: '#fff',
  },
});

export default CameraScreen;
