import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TextInput,
  TouchableOpacity,
  Alert,
  Modal,
} from 'react-native';
import { useApp } from '../context/AppContext';
import { Container, ContainerType, PackageType, MaterialType, PieceCount } from '../types/Container';
import Toast from 'react-native-toast-message';

const ContainerDetailScreen = ({ route, navigation }: any) => {
  const { containerId } = route.params;
  const { containers, addContainer, updateContainer, completeContainer, currentContainer } = useApp();
  
  const [containerNumber, setContainerNumber] = useState('');
  const [type, setType] = useState<ContainerType>(ContainerType.IMPORT);
  const [doorNumber, setDoorNumber] = useState('');
  const [pieceCounts, setPieceCounts] = useState<PieceCount[]>([]);
  const [materialsSupplied, setMaterialsSupplied] = useState<MaterialType[]>([]);
  const [discrepancies, setDiscrepancies] = useState<string[]>([]);
  const [photoPaths, setPhotoPaths] = useState<string[]>([]);
  
  const [showTypeModal, setShowTypeModal] = useState(false);
  const [showPieceCountModal, setShowPieceCountModal] = useState(false);
  const [showMaterialsModal, setShowMaterialsModal] = useState(false);
  const [showDiscrepancyModal, setShowDiscrepancyModal] = useState(false);

  useEffect(() => {
    if (containerId && currentContainer) {
      loadContainer(currentContainer);
    }
  }, [containerId, currentContainer]);

  const loadContainer = (container: Container) => {
    setContainerNumber(container.containerNumber);
    setType(container.type);
    setDoorNumber(container.doorNumber || '');
    setPieceCounts(container.pieceCounts);
    setMaterialsSupplied(container.materialsSupplied);
    setDiscrepancies(container.discrepancies.map(d => d.description));
    setPhotoPaths(container.photoPaths);
  };

  const handleSave = async () => {
    if (!containerNumber.trim()) {
      Alert.alert('Error', 'Please enter a container number');
      return;
    }

    try {
      const containerData: Container = {
        id: containerId || `container_${Date.now()}`,
        containerNumber: containerNumber.trim(),
        type,
        doorNumber: doorNumber.trim() || undefined,
        pieceCounts,
        materialsSupplied,
        discrepancies: discrepancies.map(d => ({
          description: d,
          timestamp: new Date(),
        })),
        photoPaths,
        isCompleted: false,
        createdAt: containerId ? currentContainer!.createdAt : new Date(),
        updatedAt: new Date(),
      };

      if (containerId) {
        await updateContainer(containerData);
        Toast.show({
          type: 'success',
          text1: 'Updated',
          text2: 'Container updated successfully',
        });
      } else {
        await addContainer(containerData);
        Toast.show({
          type: 'success',
          text1: 'Created',
          text2: 'Container created successfully',
        });
      }

      navigation.goBack();
    } catch (error) {
      Alert.alert('Error', 'Failed to save container');
    }
  };

  const handleComplete = async () => {
    if (!containerId) {
      Alert.alert('Error', 'Please save the container first');
      return;
    }

    Alert.alert(
      'Complete Container',
      'Are you sure you want to mark this container as complete? This will generate a PDF report and sync with Google Sheets.',
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Complete',
          onPress: async () => {
            try {
              await completeContainer(containerId);
              Toast.show({
                type: 'success',
                text1: 'Completed',
                text2: 'Container marked as complete',
              });
              navigation.goBack();
            } catch (error) {
              Alert.alert('Error', 'Failed to complete container');
            }
          },
        },
      ]
    );
  };

  const handleTakePhoto = () => {
    navigation.navigate('Camera', { containerId });
  };

  const handleViewPhotos = () => {
    navigation.navigate('PhotoGallery', { containerId });
  };

  const addPieceCount = (quantity: number, packageType: PackageType) => {
    setPieceCounts([...pieceCounts, { quantity, packageType }]);
    setShowPieceCountModal(false);
  };

  const removePieceCount = (index: number) => {
    setPieceCounts(pieceCounts.filter((_, i) => i !== index));
  };

  const toggleMaterial = (material: MaterialType) => {
    if (materialsSupplied.includes(material)) {
      setMaterialsSupplied(materialsSupplied.filter(m => m !== material));
    } else {
      setMaterialsSupplied([...materialsSupplied, material]);
    }
  };

  const addDiscrepancy = (description: string) => {
    if (description.trim()) {
      setDiscrepancies([...discrepancies, description.trim()]);
      setShowDiscrepancyModal(false);
    }
  };

  const removeDiscrepancy = (index: number) => {
    setDiscrepancies(discrepancies.filter((_, i) => i !== index));
  };

  return (
    <ScrollView style={styles.container}>
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Container Information</Text>
        
        <Text style={styles.label}>Container Number *</Text>
        <TextInput
          style={styles.input}
          value={containerNumber}
          onChangeText={setContainerNumber}
          placeholder="Enter container number"
        />

        <Text style={styles.label}>Type *</Text>
        <TouchableOpacity
          style={styles.picker}
          onPress={() => setShowTypeModal(true)}
        >
          <Text>{type}</Text>
        </TouchableOpacity>

        <Text style={styles.label}>Door Number</Text>
        <TextInput
          style={styles.input}
          value={doorNumber}
          onChangeText={setDoorNumber}
          placeholder="Enter door number"
        />
      </View>

      <View style={styles.section}>
        <View style={styles.sectionHeader}>
          <Text style={styles.sectionTitle}>Piece Count</Text>
          <TouchableOpacity
            style={styles.addButton}
            onPress={() => setShowPieceCountModal(true)}
          >
            <Text style={styles.addButtonText}>+ Add</Text>
          </TouchableOpacity>
        </View>
        
        {pieceCounts.map((pc, index) => (
          <View key={index} style={styles.listItem}>
            <Text>{pc.quantity} {pc.packageType}</Text>
            <TouchableOpacity onPress={() => removePieceCount(index)}>
              <Text style={styles.removeButton}>✕</Text>
            </TouchableOpacity>
          </View>
        ))}
        
        {pieceCounts.length === 0 && (
          <Text style={styles.emptyText}>No pieces recorded</Text>
        )}
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Materials Supplied</Text>
        <TouchableOpacity
          style={styles.picker}
          onPress={() => setShowMaterialsModal(true)}
        >
          <Text>
            {materialsSupplied.length > 0
              ? materialsSupplied.join(', ')
              : 'Select materials'}
          </Text>
        </TouchableOpacity>
      </View>

      <View style={styles.section}>
        <View style={styles.sectionHeader}>
          <Text style={styles.sectionTitle}>Discrepancies</Text>
          <TouchableOpacity
            style={styles.addButton}
            onPress={() => setShowDiscrepancyModal(true)}
          >
            <Text style={styles.addButtonText}>+ Add</Text>
          </TouchableOpacity>
        </View>
        
        {discrepancies.map((disc, index) => (
          <View key={index} style={styles.listItem}>
            <Text style={styles.discrepancyText}>{disc}</Text>
            <TouchableOpacity onPress={() => removeDiscrepancy(index)}>
              <Text style={styles.removeButton}>✕</Text>
            </TouchableOpacity>
          </View>
        ))}
        
        {discrepancies.length === 0 && (
          <Text style={styles.emptyText}>No discrepancies reported</Text>
        )}
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Photos</Text>
        <View style={styles.photoButtons}>
          <TouchableOpacity style={styles.photoButton} onPress={handleTakePhoto}>
            <Text style={styles.photoButtonText}>📷 Take Photo</Text>
          </TouchableOpacity>
          <TouchableOpacity style={styles.photoButton} onPress={handleViewPhotos}>
            <Text style={styles.photoButtonText}>🖼️ View ({photoPaths.length})</Text>
          </TouchableOpacity>
        </View>
      </View>

      <View style={styles.actionButtons}>
        <TouchableOpacity style={styles.saveButton} onPress={handleSave}>
          <Text style={styles.saveButtonText}>Save</Text>
        </TouchableOpacity>
        
        {containerId && !currentContainer?.isCompleted && (
          <TouchableOpacity style={styles.completeButton} onPress={handleComplete}>
            <Text style={styles.completeButtonText}>Complete Container</Text>
          </TouchableOpacity>
        )}
      </View>

      {/* Type Selection Modal */}
      <Modal visible={showTypeModal} transparent animationType="slide">
        <View style={styles.modalOverlay}>
          <View style={styles.modalContent}>
            <Text style={styles.modalTitle}>Select Container Type</Text>
            {Object.values(ContainerType).map(t => (
              <TouchableOpacity
                key={t}
                style={styles.modalOption}
                onPress={() => {
                  setType(t);
                  setShowTypeModal(false);
                }}
              >
                <Text style={styles.modalOptionText}>{t}</Text>
              </TouchableOpacity>
            ))}
            <TouchableOpacity
              style={styles.modalCancel}
              onPress={() => setShowTypeModal(false)}
            >
              <Text style={styles.modalCancelText}>Cancel</Text>
            </TouchableOpacity>
          </View>
        </View>
      </Modal>

      {/* Materials Selection Modal */}
      <Modal visible={showMaterialsModal} transparent animationType="slide">
        <View style={styles.modalOverlay}>
          <View style={styles.modalContent}>
            <Text style={styles.modalTitle}>Select Materials</Text>
            {Object.values(MaterialType).map(material => (
              <TouchableOpacity
                key={material}
                style={[
                  styles.modalOption,
                  materialsSupplied.includes(material) && styles.modalOptionSelected,
                ]}
                onPress={() => toggleMaterial(material)}
              >
                <Text style={styles.modalOptionText}>
                  {materialsSupplied.includes(material) ? '✓ ' : ''}
                  {material}
                </Text>
              </TouchableOpacity>
            ))}
            <TouchableOpacity
              style={styles.modalCancel}
              onPress={() => setShowMaterialsModal(false)}
            >
              <Text style={styles.modalCancelText}>Done</Text>
            </TouchableOpacity>
          </View>
        </View>
      </Modal>
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
  sectionHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 12,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 12,
  },
  label: {
    fontSize: 14,
    color: '#666',
    marginBottom: 6,
    marginTop: 12,
  },
  input: {
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    padding: 12,
    fontSize: 16,
  },
  picker: {
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    padding: 12,
  },
  addButton: {
    backgroundColor: '#2563eb',
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 6,
  },
  addButtonText: {
    color: '#fff',
    fontWeight: 'bold',
  },
  listItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 8,
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
  },
  removeButton: {
    color: '#f44336',
    fontSize: 20,
    fontWeight: 'bold',
  },
  discrepancyText: {
    flex: 1,
    color: '#f44336',
  },
  emptyText: {
    color: '#999',
    fontStyle: 'italic',
    textAlign: 'center',
    paddingVertical: 12,
  },
  photoButtons: {
    flexDirection: 'row',
    gap: 12,
  },
  photoButton: {
    flex: 1,
    backgroundColor: '#e3f2fd',
    padding: 12,
    borderRadius: 8,
    alignItems: 'center',
  },
  photoButtonText: {
    color: '#2563eb',
    fontWeight: 'bold',
  },
  actionButtons: {
    padding: 16,
    gap: 12,
  },
  saveButton: {
    backgroundColor: '#2563eb',
    padding: 16,
    borderRadius: 8,
    alignItems: 'center',
  },
  saveButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: 'bold',
  },
  completeButton: {
    backgroundColor: '#4caf50',
    padding: 16,
    borderRadius: 8,
    alignItems: 'center',
  },
  completeButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: 'bold',
  },
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.5)',
    justifyContent: 'flex-end',
  },
  modalContent: {
    backgroundColor: '#fff',
    borderTopLeftRadius: 20,
    borderTopRightRadius: 20,
    padding: 20,
  },
  modalTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 16,
    textAlign: 'center',
  },
  modalOption: {
    padding: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
  },
  modalOptionSelected: {
    backgroundColor: '#e3f2fd',
  },
  modalOptionText: {
    fontSize: 16,
  },
  modalCancel: {
    marginTop: 12,
    padding: 16,
    alignItems: 'center',
  },
  modalCancelText: {
    color: '#2563eb',
    fontSize: 16,
    fontWeight: 'bold',
  },
});

export default ContainerDetailScreen;
