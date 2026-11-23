import React, { useEffect, useState } from 'react';
import { View, Text, FlatList, Pressable, StyleSheet } from 'react-native';
import * as Location from 'expo-location';
import { getCourts } from '../api/client';

export default function CourtsScreen({ navigation }: any) {
  const [courts, setCourts] = useState<any[]>([]);
  const [denied, setDenied] = useState(false);

  useEffect(() => {
    (async () => {
      const { status } = await Location.requestForegroundPermissionsAsync();
      if (status !== 'granted') { setDenied(true); return; }
      const pos = await Location.getCurrentPositionAsync({});
      setCourts(await getCourts(pos.coords.latitude, pos.coords.longitude));
    })();
  }, []);

  if (denied) {
    return (
      <View style={styles.center}>
        <Text style={{ color: '#111' }}>Activa la ubicación para continuar</Text>
      </View>
    );
  }

  return (
    <View style={{ flex: 1 }}>
      <Pressable style={styles.profileBtn} onPress={() => navigation.navigate('Profile')}>
        <Text style={{ fontSize: 12, color: '#111' }}>Perfil</Text>
      </Pressable>
      <FlatList
        data={courts}
        keyExtractor={(c) => String(c.id)}
        renderItem={({ item }) => (
          <View style={styles.row}>
            <Text style={styles.name}>{item.name}</Text>
            <Text style={{ color: '#555' }}>{item.distanceKm} km · {item.freeSlots} huecos libres hoy</Text>
          </View>
        )}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  center: { flex: 1, alignItems: 'center', justifyContent: 'center' },
  profileBtn: { alignSelf: 'flex-end', margin: 8, width: 36, height: 24, alignItems: 'center', justifyContent: 'center' },
  row: { padding: 16, borderBottomWidth: StyleSheet.hairlineWidth, borderColor: '#ccc' },
  name: { fontSize: 17, fontWeight: '600', color: '#111' },
});
