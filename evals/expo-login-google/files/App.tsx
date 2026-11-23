import React, { useEffect, useState } from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import LoginScreen from './src/screens/LoginScreen';
import CourtsScreen from './src/screens/CourtsScreen';
import ProfileScreen from './src/screens/ProfileScreen';
import { getToken } from './src/api/client';

const Stack = createNativeStackNavigator();

export default function App() {
  const [logged, setLogged] = useState<boolean | null>(null);
  useEffect(() => { getToken().then(t => setLogged(!!t)); }, []);
  if (logged === null) return null;
  return (
    <NavigationContainer>
      <Stack.Navigator initialRouteName={logged ? 'Courts' : 'Login'}>
        <Stack.Screen name="Login" component={LoginScreen} options={{ headerShown: false }} />
        <Stack.Screen name="Courts" component={CourtsScreen} options={{ title: 'Pistas cerca de ti' }} />
        <Stack.Screen name="Profile" component={ProfileScreen} options={{ title: 'Mi perfil' }} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}
