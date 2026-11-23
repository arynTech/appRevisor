import axios from 'axios';
import * as SecureStore from 'expo-secure-store';
import Constants from 'expo-constants';

const api = axios.create({ baseURL: Constants.expoConfig?.extra?.apiUrl });

api.interceptors.request.use(async (config) => {
  const token = await SecureStore.getItemAsync('token');
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

export const getToken = () => SecureStore.getItemAsync('token');

// Crea la cuenta si no existe y devuelve el token de sesión
export async function loginWithGoogle(idToken: string) {
  const { data } = await api.post('/auth/google', { idToken });
  await SecureStore.setItemAsync('token', data.token);
  return data.user;
}

export async function logout() {
  await SecureStore.deleteItemAsync('token');
}

export const getMe = () => api.get('/users/me').then(r => r.data);
export const updateMe = (body: { name?: string; avatarUrl?: string }) => api.patch('/users/me', body).then(r => r.data);

// Borra la cuenta y todos sus datos (reservas, avatar) en el servidor
export const deleteMe = () => api.delete('/users/me');

export const getCourts = (lat: number, lng: number) =>
  api.get('/courts', { params: { lat, lng } }).then(r => r.data);
