import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { Container } from '../types/Container';
import { GoogleSheetsService } from '../services/GoogleSheetsService';
import { StorageService } from '../services/StorageService';

interface AppContextType {
  containers: Container[];
  currentContainer: Container | null;
  isLoading: boolean;
  isOffline: boolean;
  addContainer: (container: Container) => Promise<void>;
  updateContainer: (container: Container) => Promise<void>;
  deleteContainer: (containerId: string) => Promise<void>;
  setCurrentContainer: (container: Container | null) => void;
  completeContainer: (containerId: string) => Promise<void>;
  syncWithGoogleSheets: () => Promise<void>;
  refreshContainers: () => Promise<void>;
}

const AppContext = createContext<AppContextType | undefined>(undefined);

const STORAGE_KEY = '@warehouse_containers';

export const AppProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [containers, setContainers] = useState<Container[]>([]);
  const [currentContainer, setCurrentContainer] = useState<Container | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [isOffline, setIsOffline] = useState(false);

  const googleSheetsService = new GoogleSheetsService();
  const storageService = new StorageService();

  // Load containers from local storage on app start
  useEffect(() => {
    loadContainers();
  }, []);

  const loadContainers = async () => {
    try {
      setIsLoading(true);
      const stored = await AsyncStorage.getItem(STORAGE_KEY);
      if (stored) {
        const parsed = JSON.parse(stored);
        // Convert date strings back to Date objects
        const containersWithDates = parsed.map((c: any) => ({
          ...c,
          createdAt: new Date(c.createdAt),
          updatedAt: new Date(c.updatedAt),
          completedAt: c.completedAt ? new Date(c.completedAt) : undefined,
          discrepancies: c.discrepancies.map((d: any) => ({
            ...d,
            timestamp: new Date(d.timestamp),
          })),
        }));
        setContainers(containersWithDates);
      }
    } catch (error) {
      console.error('Error loading containers:', error);
    } finally {
      setIsLoading(false);
    }
  };

  const saveContainers = async (newContainers: Container[]) => {
    try {
      await AsyncStorage.setItem(STORAGE_KEY, JSON.stringify(newContainers));
      setContainers(newContainers);
    } catch (error) {
      console.error('Error saving containers:', error);
      throw error;
    }
  };

  const addContainer = async (container: Container) => {
    try {
      setIsLoading(true);
      const newContainers = [...containers, container];
      await saveContainers(newContainers);
      
      // Try to sync with Google Sheets
      try {
        await googleSheetsService.addContainer(container);
      } catch (error) {
        console.warn('Failed to sync with Google Sheets:', error);
        setIsOffline(true);
      }
    } catch (error) {
      console.error('Error adding container:', error);
      throw error;
    } finally {
      setIsLoading(false);
    }
  };

  const updateContainer = async (updatedContainer: Container) => {
    try {
      setIsLoading(true);
      const newContainers = containers.map(c =>
        c.id === updatedContainer.id ? { ...updatedContainer, updatedAt: new Date() } : c
      );
      await saveContainers(newContainers);
      
      // Try to sync with Google Sheets
      try {
        await googleSheetsService.updateContainer(updatedContainer);
      } catch (error) {
        console.warn('Failed to sync with Google Sheets:', error);
        setIsOffline(true);
      }
    } catch (error) {
      console.error('Error updating container:', error);
      throw error;
    } finally {
      setIsLoading(false);
    }
  };

  const deleteContainer = async (containerId: string) => {
    try {
      setIsLoading(true);
      const newContainers = containers.filter(c => c.id !== containerId);
      await saveContainers(newContainers);
    } catch (error) {
      console.error('Error deleting container:', error);
      throw error;
    } finally {
      setIsLoading(false);
    }
  };

  const completeContainer = async (containerId: string) => {
    try {
      setIsLoading(true);
      const container = containers.find(c => c.id === containerId);
      if (!container) throw new Error('Container not found');

      // Generate PDF
      const pdfPath = await storageService.generatePDF(container);
      
      // Upload to cloud storage and get shareable link
      const shareableLink = await storageService.uploadPDF(pdfPath, container.containerNumber);

      // Update container
      const updatedContainer: Container = {
        ...container,
        isCompleted: true,
        completedAt: new Date(),
        shareableLink,
        updatedAt: new Date(),
      };

      await updateContainer(updatedContainer);

      // Send notification if there are discrepancies
      if (updatedContainer.discrepancies.length > 0) {
        await googleSheetsService.sendDiscrepancyNotification(updatedContainer);
      }
    } catch (error) {
      console.error('Error completing container:', error);
      throw error;
    } finally {
      setIsLoading(false);
    }
  };

  const syncWithGoogleSheets = async () => {
    try {
      setIsLoading(true);
      setIsOffline(false);
      
      // Sync all containers
      for (const container of containers) {
        try {
          await googleSheetsService.updateContainer(container);
        } catch (error) {
          console.warn(`Failed to sync container ${container.containerNumber}:`, error);
        }
      }
    } catch (error) {
      console.error('Error syncing with Google Sheets:', error);
      setIsOffline(true);
      throw error;
    } finally {
      setIsLoading(false);
    }
  };

  const refreshContainers = async () => {
    try {
      setIsLoading(true);
      setIsOffline(false);
      
      // Fetch containers from Google Sheets
      const sheetsContainers = await googleSheetsService.getContainers();
      
      // Merge with local containers (local takes precedence for conflicts)
      const mergedContainers = [...containers];
      sheetsContainers.forEach(sheetContainer => {
        const existingIndex = mergedContainers.findIndex(
          c => c.containerNumber === sheetContainer.containerNumber
        );
        if (existingIndex === -1) {
          mergedContainers.push(sheetContainer);
        }
      });
      
      await saveContainers(mergedContainers);
    } catch (error) {
      console.error('Error refreshing containers:', error);
      setIsOffline(true);
      throw error;
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <AppContext.Provider
      value={{
        containers,
        currentContainer,
        isLoading,
        isOffline,
        addContainer,
        updateContainer,
        deleteContainer,
        setCurrentContainer,
        completeContainer,
        syncWithGoogleSheets,
        refreshContainers,
      }}
    >
      {children}
    </AppContext.Provider>
  );
};

export const useApp = () => {
  const context = useContext(AppContext);
  if (context === undefined) {
    throw new Error('useApp must be used within an AppProvider');
  }
  return context;
};
