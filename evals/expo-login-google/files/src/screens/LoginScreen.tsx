import React from 'react';
import { View, Text, Pressable, StyleSheet, Image } from 'react-native';
import { GoogleSignin } from '@react-native-google-signin/google-signin';
import { loginWithGoogle } from '../api/client';

GoogleSignin.configure({ webClientId: '1234567890-abc.apps.googleusercontent.com' });

export default function LoginScreen({ navigation }: any) {
  const onGoogle = async () => {
    await GoogleSignin.hasPlayServices();
    const res = await GoogleSignin.signIn();
    if (res.data?.idToken) {
      await loginWithGoogle(res.data.idToken);
      navigation.replace('Courts');
    }
  };

  return (
    <View style={styles.container}>
      <Image source={require('../../assets/icon.png')} style={styles.logo} />
      <Text style={styles.title}>PadelYa</Text>
      <Text style={styles.subtitle}>Reserva pista en tu club en 10 segundos</Text>
      <Pressable style={styles.google} onPress={onGoogle}>
        <Text style={styles.googleText}>Continuar con Google</Text>
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, alignItems: 'center', justifyContent: 'center', backgroundColor: '#fff' },
  logo: { width: 96, height: 96, marginBottom: 16 },
  title: { fontSize: 32, fontWeight: '700', color: '#111' },
  subtitle: { fontSize: 15, color: '#444', marginBottom: 32 },
  google: { backgroundColor: '#fff', borderWidth: 1, borderColor: '#ddd', borderRadius: 8, paddingVertical: 12, paddingHorizontal: 24 },
  googleText: { fontSize: 16, color: '#111' },
});
