import React, { useEffect } from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';
import { StatusBar, Platform } from 'react-native';
import Toast from 'react-native-toast-message';
import { AppProvider } from './src/context/AppContext';
import HomeScreen from './src/screens/HomeScreen';
import ContainerDetailScreen from './src/screens/ContainerDetailScreen';
import CameraScreen from './src/screens/CameraScreen';
import PhotoGalleryScreen from './src/screens/PhotoGalleryScreen';
import SettingsScreen from './src/screens/SettingsScreen';
import { requestPermissions } from './src/utils/permissions';

const Stack = createStackNavigator();

const App = () => {
  useEffect(() => {
    // Request necessary permissions on app start
    requestPermissions();
  }, []);

  return (
    <AppProvider>
      <NavigationContainer>
        <StatusBar
          barStyle={Platform.OS === 'ios' ? 'dark-content' : 'light-content'}
          backgroundColor="#2563eb"
        />
        <Stack.Navigator
          initialRouteName="Home"
          screenOptions={{
            headerStyle: {
              backgroundColor: '#2563eb',
            },
            headerTintColor: '#fff',
            headerTitleStyle: {
              fontWeight: 'bold',
            },
          }}
        >
          <Stack.Screen
            name="Home"
            component={HomeScreen}
            options={{ title: 'Warehouse Tracker' }}
          />
          <Stack.Screen
            name="ContainerDetail"
            component={ContainerDetailScreen}
            options={{ title: 'Container Details' }}
          />
          <Stack.Screen
            name="Camera"
            component={CameraScreen}
            options={{ 
              title: 'Take Photo',
              headerShown: false 
            }}
          />
          <Stack.Screen
            name="PhotoGallery"
            component={PhotoGalleryScreen}
            options={{ title: 'Photo Gallery' }}
          />
          <Stack.Screen
            name="Settings"
            component={SettingsScreen}
            options={{ title: 'Settings' }}
          />
        </Stack.Navigator>
        <Toast />
      </NavigationContainer>
    </AppProvider>
  );
};

export default App;
