import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  Image,
  FlatList,
  TouchableOpacity,
  Alert,
  Dimensions,
} from 'react-native';
import DraggableFlatList from 'react-native-draggable-flatlist';
import { useApp } from '../context/AppContext';
import Toast from 'react-native-toast-message';
import RNFS from 'react-native-fs';
import ImageResizer from 'react-native-image-resizer';

const { width } = Dimensions.get('window');
const PHOTO_SIZE = (width - 48) / 3;

const PhotoGalleryScreen = ({ route, navigation }: any) => {
  const { containerId } = route.params;
  const { currentContainer, updateContainer } = useApp();
  const [photos, setPhotos] = useState(currentContainer?.photoPaths || []);

  const handleDelete = (photoPath: string) => {
    Alert.alert(
      'Delete Photo',
      'Are you sure you want to delete this photo?',
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Delete',
          style: 'destructive',
          onPress: async () => {
            try {
              // Delete from file system
              await RNFS.unlink(photoPath);
              
              // Update container
              const updatedPhotos = photos.filter(p => p !== photoPath);
              setPhotos(updatedPhotos);
              
              if (currentContainer) {
                await updateContainer({
                  ...currentContainer,
                  photoPaths: updatedPhotos,
                });
              }

              Toast.show({
                type: 'success',
                text1: 'Deleted',
                text2: 'Photo deleted successfully',
              });
            } catch (error) {
              Alert.alert('Error', 'Failed to delete photo');
            }
          },
        },
      ]
    );
  };

  const handleRotate = async (photoPath: string) => {
    try {
      // Rotate image 90 degrees clockwise
      const rotated = await ImageResizer.createResizedImage(
        photoPath,
        2000,
        2000,
        'JPEG',
        100,
        90 // rotation
      );

      // Replace original file
      await RNFS.unlink(photoPath);
      await RNFS.moveFile(rotated.uri, photoPath);

      Toast.show({
        type: 'success',
        text1: 'Rotated',
        text2: 'Photo rotated successfully',
      });

      // Force re-render
      setPhotos([...photos]);
    } catch (error) {
      Alert.alert('Error', 'Failed to rotate photo');
    }
  };

  const handleReorder = async (data: string[]) => {
    setPhotos(data);
    
    if (currentContainer) {
      await updateContainer({
        ...currentContainer,
        photoPaths: data,
      });
    }
  };

  const renderPhoto = ({ item, drag, isActive }: any) => (
    <TouchableOpacity
      style={[styles.photoContainer, isActive && styles.photoContainerActive]}
      onLongPress={drag}
    >
      <Image
        source={{ uri: `file://${item}` }}
        style={styles.photo}
        resizeMode="cover"
      />
      <View style={styles.photoActions}>
        <TouchableOpacity
          style={styles.actionButton}
          onPress={() => handleRotate(item)}
        >
          <Text style={styles.actionButtonText}>🔄</Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={[styles.actionButton, styles.deleteButton]}
          onPress={() => handleDelete(item)}
        >
          <Text style={styles.actionButtonText}>🗑️</Text>
        </TouchableOpacity>
      </View>
    </TouchableOpacity>
  );

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.headerText}>
          {photos.length} Photo{photos.length !== 1 ? 's' : ''}
        </Text>
        <Text style={styles.headerSubtext}>Long press to reorder</Text>
      </View>

      {photos.length === 0 ? (
        <View style={styles.emptyContainer}>
          <Text style={styles.emptyText}>No photos yet</Text>
          <Text style={styles.emptySubtext}>Take photos from the container detail screen</Text>
        </View>
      ) : (
        <DraggableFlatList
          data={photos}
          renderItem={renderPhoto}
          keyExtractor={(item, index) => `${item}-${index}`}
          onDragEnd={({ data }) => handleReorder(data)}
          numColumns={3}
          contentContainerStyle={styles.gallery}
        />
      )}

      <TouchableOpacity
        style={styles.addButton}
        onPress={() => navigation.navigate('Camera', { containerId })}
      >
        <Text style={styles.addButtonText}>+ Add Photo</Text>
      </TouchableOpacity>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  header: {
    backgroundColor: '#fff',
    padding: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  headerText: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
  },
  headerSubtext: {
    fontSize: 12,
    color: '#999',
    marginTop: 4,
  },
  gallery: {
    padding: 12,
  },
  photoContainer: {
    width: PHOTO_SIZE,
    height: PHOTO_SIZE,
    margin: 4,
    borderRadius: 8,
    overflow: 'hidden',
    backgroundColor: '#fff',
  },
  photoContainerActive: {
    opacity: 0.7,
  },
  photo: {
    width: '100%',
    height: '100%',
  },
  photoActions: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    flexDirection: 'row',
    justifyContent: 'space-around',
    backgroundColor: 'rgba(0,0,0,0.6)',
    padding: 8,
  },
  actionButton: {
    padding: 4,
  },
  deleteButton: {
    // Additional styling if needed
  },
  actionButtonText: {
    fontSize: 20,
  },
  emptyContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 40,
  },
  emptyText: {
    fontSize: 18,
    color: '#999',
    marginBottom: 8,
  },
  emptySubtext: {
    fontSize: 14,
    color: '#bbb',
    textAlign: 'center',
  },
  addButton: {
    margin: 16,
    backgroundColor: '#2563eb',
    padding: 16,
    borderRadius: 8,
    alignItems: 'center',
  },
  addButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: 'bold',
  },
});

export default PhotoGalleryScreen;
