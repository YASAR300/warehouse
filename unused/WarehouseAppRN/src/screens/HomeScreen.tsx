import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  TouchableOpacity,
  TextInput,
  RefreshControl,
  Alert,
} from 'react-native';
import { useApp } from '../context/AppContext';
import { Container } from '../types/Container';
import Toast from 'react-native-toast-message';

const HomeScreen = ({ navigation }: any) => {
  const { containers, isLoading, isOffline, refreshContainers, setCurrentContainer } = useApp();
  const [searchQuery, setSearchQuery] = useState('');
  const [filteredContainers, setFilteredContainers] = useState<Container[]>([]);

  useEffect(() => {
    filterContainers();
  }, [containers, searchQuery]);

  const filterContainers = () => {
    if (!searchQuery) {
      setFilteredContainers(containers);
      return;
    }

    const query = searchQuery.toLowerCase();
    const filtered = containers.filter(
      c =>
        c.containerNumber.toLowerCase().includes(query) ||
        c.type.toLowerCase().includes(query) ||
        c.doorNumber?.toLowerCase().includes(query)
    );
    setFilteredContainers(filtered);
  };

  const handleRefresh = async () => {
    try {
      await refreshContainers();
      Toast.show({
        type: 'success',
        text1: 'Refreshed',
        text2: 'Container list updated',
      });
    } catch (error) {
      Toast.show({
        type: 'error',
        text1: 'Refresh Failed',
        text2: 'Could not refresh container list',
      });
    }
  };

  const handleContainerPress = (container: Container) => {
    setCurrentContainer(container);
    navigation.navigate('ContainerDetail', { containerId: container.id });
  };

  const handleNewContainer = () => {
    navigation.navigate('ContainerDetail', { containerId: null });
  };

  const renderContainer = ({ item }: { item: Container }) => (
    <TouchableOpacity
      style={[styles.containerCard, item.isCompleted && styles.completedCard]}
      onPress={() => handleContainerPress(item)}
    >
      <View style={styles.cardHeader}>
        <Text style={styles.containerNumber}>{item.containerNumber}</Text>
        <View style={[styles.badge, item.isCompleted ? styles.completedBadge : styles.activeBadge]}>
          <Text style={styles.badgeText}>{item.isCompleted ? 'Completed' : 'Active'}</Text>
        </View>
      </View>
      <View style={styles.cardBody}>
        <Text style={styles.containerType}>{item.type}</Text>
        {item.doorNumber && (
          <Text style={styles.doorNumber}>Door: {item.doorNumber}</Text>
        )}
        {item.discrepancies.length > 0 && (
          <Text style={styles.discrepancyWarning}>
            ⚠️ {item.discrepancies.length} Discrepancy(ies)
          </Text>
        )}
      </View>
      <View style={styles.cardFooter}>
        <Text style={styles.photoCount}>📷 {item.photoPaths.length} photos</Text>
        <Text style={styles.pieceCount}>
          📦 {item.pieceCounts.reduce((sum, pc) => sum + pc.quantity, 0)} pieces
        </Text>
      </View>
    </TouchableOpacity>
  );

  return (
    <View style={styles.container}>
      {isOffline && (
        <View style={styles.offlineBanner}>
          <Text style={styles.offlineText}>⚠️ Offline Mode - Changes will sync when online</Text>
        </View>
      )}
      
      <View style={styles.header}>
        <TextInput
          style={styles.searchInput}
          placeholder="Search containers..."
          value={searchQuery}
          onChangeText={setSearchQuery}
        />
        <TouchableOpacity style={styles.settingsButton} onPress={() => navigation.navigate('Settings')}>
          <Text style={styles.settingsIcon}>⚙️</Text>
        </TouchableOpacity>
      </View>

      <FlatList
        data={filteredContainers}
        renderItem={renderContainer}
        keyExtractor={item => item.id}
        contentContainerStyle={styles.listContent}
        refreshControl={
          <RefreshControl refreshing={isLoading} onRefresh={handleRefresh} />
        }
        ListEmptyComponent={
          <View style={styles.emptyContainer}>
            <Text style={styles.emptyText}>No containers found</Text>
            <Text style={styles.emptySubtext}>Tap + to add a new container</Text>
          </View>
        }
      />

      <TouchableOpacity style={styles.fab} onPress={handleNewContainer}>
        <Text style={styles.fabText}>+</Text>
      </TouchableOpacity>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  offlineBanner: {
    backgroundColor: '#ff9800',
    padding: 10,
    alignItems: 'center',
  },
  offlineText: {
    color: '#fff',
    fontWeight: 'bold',
  },
  header: {
    flexDirection: 'row',
    padding: 16,
    backgroundColor: '#fff',
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  searchInput: {
    flex: 1,
    height: 40,
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    paddingHorizontal: 12,
    backgroundColor: '#f9f9f9',
  },
  settingsButton: {
    marginLeft: 12,
    justifyContent: 'center',
  },
  settingsIcon: {
    fontSize: 24,
  },
  listContent: {
    padding: 16,
  },
  containerCard: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 16,
    marginBottom: 12,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  completedCard: {
    backgroundColor: '#e8f5e9',
  },
  cardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  containerNumber: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
  },
  badge: {
    paddingHorizontal: 12,
    paddingVertical: 4,
    borderRadius: 12,
  },
  activeBadge: {
    backgroundColor: '#2196f3',
  },
  completedBadge: {
    backgroundColor: '#4caf50',
  },
  badgeText: {
    color: '#fff',
    fontSize: 12,
    fontWeight: 'bold',
  },
  cardBody: {
    marginBottom: 8,
  },
  containerType: {
    fontSize: 16,
    color: '#666',
    marginBottom: 4,
  },
  doorNumber: {
    fontSize: 14,
    color: '#888',
  },
  discrepancyWarning: {
    fontSize: 14,
    color: '#f44336',
    fontWeight: 'bold',
    marginTop: 4,
  },
  cardFooter: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    borderTopWidth: 1,
    borderTopColor: '#f0f0f0',
    paddingTop: 8,
  },
  photoCount: {
    fontSize: 14,
    color: '#666',
  },
  pieceCount: {
    fontSize: 14,
    color: '#666',
  },
  emptyContainer: {
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 60,
  },
  emptyText: {
    fontSize: 18,
    color: '#999',
    marginBottom: 8,
  },
  emptySubtext: {
    fontSize: 14,
    color: '#bbb',
  },
  fab: {
    position: 'absolute',
    right: 20,
    bottom: 20,
    width: 60,
    height: 60,
    borderRadius: 30,
    backgroundColor: '#2563eb',
    justifyContent: 'center',
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 4,
    elevation: 8,
  },
  fabText: {
    fontSize: 32,
    color: '#fff',
    fontWeight: 'bold',
  },
});

export default HomeScreen;
