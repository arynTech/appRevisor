import React, { useEffect, useState } from 'react';
import { View, Text, Image, Pressable, StyleSheet } from 'react-native';
import * as ImagePicker from 'expo-image-picker';
import { GoogleSignin } from '@react-native-google-signin/google-signin';
import { getMe, updateMe, logout } from '../api/client';

export default function ProfileScreen({ navigation }: any) {
  const [me, setMe] = useState<any>(null);
  useEffect(() => { getMe().then(setMe); }, []);

  const pickAvatar = async (fromCamera: boolean) => {
    const res = fromCamera
      ? await ImagePicker.launchCameraAsync({ allowsEditing: true, aspect: [1, 1] })
      : await ImagePicker.launchImageLibraryAsync({ allowsEditing: true, aspect: [1, 1] });
    if (!res.canceled) setMe(await updateMe({ avatarUrl: res.assets[0].uri }));
  };

  const onLogout = async () => {
    await GoogleSignin.signOut();
    await logout();
    navigation.reset({ index: 0, routes: [{ name: 'Login' }] });
  };

  return (
    <View style={styles.container}>
      {me?.avatarUrl ? <Image source={{ uri: me.avatarUrl }} style={styles.avatar} /> : null}
      <Text style={styles.name}>{me?.name}</Text>
      <Pressable onPress={() => pickAvatar(false)}><Text style={styles.link}>Cambiar foto</Text></Pressable>
      <Pressable onPress={() => pickAvatar(true)}><Text style={styles.link}>Hacer foto</Text></Pressable>

      <Text style={styles.section}>Sobre el club</Text>
      <Text style={styles.body}>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor.</Text>

      <Pressable style={styles.logout} onPress={onLogout}><Text style={{ color: '#c00' }}>Cerrar sesión</Text></Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, padding: 24, backgroundColor: '#fff' },
  avatar: { width: 96, height: 96, borderRadius: 48 },
  name: { fontSize: 22, fontWeight: '700', marginVertical: 8, color: '#111' },
  link: { color: '#0a7', paddingVertical: 10 },
  section: { marginTop: 24, fontWeight: '600', color: '#111' },
  body: { color: '#333' },
  logout: { marginTop: 32 },
});
