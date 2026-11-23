# SDK habituales: qué implican para la revisión

Tabla **orientativa** para proponer Data safety (Google) y App Privacy (Apple) y para detectar obligaciones (Sign in with Apple, ATT, IAP). No es fuente oficial: en el checklist pide al usuario que la valide con la guía de divulgación de cada proveedor y con el [Play SDK Index](https://play.google.com/sdks). Lo que sí es oficial está en `apple.md` y `google.md`.

| SDK (paquetes) | Obliga a | Datos típicos que recoge o envía | ¿Tracking (ATT)? |
|---|---|---|---|
| Google Sign-In (`@react-native-google-signin/google-signin`, `google_sign_in`, `@codetrix-studio/capacitor-google-auth`, `GoogleSignIn`), `expo-auth-session` con proveedor Google | A-LOG-01 (Sign in with Apple), A-PRI-07/G-PRI-03 (borrado) | Nombre, email, ID de usuario | No |
| Facebook Login / Meta SDK (`react-native-fbsdk-next`, `flutter_facebook_auth`, `facebook_app_events`, `FBSDK*`) | A-LOG-01, A-PRI-06 si se usan App Events con publicidad | Nombre, email, ID de usuario, interacciones con la app, ID de dispositivo | Sí, si hay App Events/anuncios |
| Firebase Auth (`@react-native-firebase/auth`, `firebase_auth`, `@capacitor-firebase/authentication`) | A-PRI-07/G-PRI-03; A-LOG-01 si activa proveedores sociales | Email, ID de usuario, teléfono si hay login por SMS | No |
| Firebase Analytics / Google Analytics (`@react-native-firebase/analytics`, `firebase_analytics`) | Data safety / App Privacy | Interacciones con la app, ID de dispositivo o instancia, ubicación aproximada | Solo si se vincula con anuncios (Google Signals/AdMob) |
| Crashlytics / Sentry / Bugsnag (`@react-native-firebase/crashlytics`, `firebase_crashlytics`, `@sentry/react-native`, `sentry_flutter`) | Data safety / App Privacy | Datos de fallos, diagnóstico, ID de dispositivo | No |
| FCM / OneSignal / notificaciones push (`@react-native-firebase/messaging`, `firebase_messaging`, `react-native-onesignal`, `onesignal_flutter`, `expo-notifications`) | — | ID de dispositivo o token push; OneSignal también analítica | OneSignal: según configuración |
| AdMob / Google Mobile Ads (`react-native-google-mobile-ads`, `google_mobile_ads`, `@capacitor-community/admob`) | A-PRI-06 (ATT), G-PRI-05 (ID de publicidad), Familias si hay menores | ID de publicidad, ubicación aproximada, interacciones, diagnóstico; se **comparte** para publicidad | Sí |
| AppsFlyer / Adjust / Branch / Singular (`react-native-appsflyer`, `appsflyer_sdk`, `react-native-adjust`, `adjust_sdk`, `react-native-branch`) | A-PRI-06, G-PRI-05 | ID de publicidad, ID de dispositivo, interacciones, atribución de instalaciones | Sí |
| Mixpanel / Amplitude / Segment | Data safety / App Privacy | Interacciones, ID de usuario o dispositivo | Según configuración |
| RevenueCat (`react-native-purchases`, `purchases_flutter`, `@revenuecat/purchases-capacitor`) | A-PAG/G-PAG (ya usa IAP/Billing) | Historial de compras, ID de usuario | No |
| `react-native-iap`, `expo-iap`, `in_app_purchase`, `cordova-plugin-purchase` | A-PAG/G-PAG (ya usa IAP/Billing) | Historial de compras | No |
| Stripe / PayPal / Braintree / Redsys / Mercado Pago (`@stripe/stripe-react-native`, `flutter_stripe`, `@capacitor-community/stripe`) | A-PAG-01/G-PAG-01 si se venden **bienes digitales**; OK para bienes físicos (A-PAG-03/G-PAG-03) | Datos de pago (información financiera) | No |
| Mapas y ubicación (`expo-location`, `geolocator`, `react-native-maps`, `google_maps_flutter`) | A-PER-01 (claves de ubicación), G-PER-03 si hay segundo plano | Ubicación precisa o aproximada | No |
| Cámara / fotos (`expo-image-picker`, `image_picker`, `@capacitor/camera`, `react-native-vision-camera`) | A-PER-01, G-PER-05 | Fotos o vídeos si se suben al servidor | No |
| WebView (`react-native-webview`, `webview_flutter`, `flutter_inappwebview`) | A-CON-01/G-CON-02 si es la pantalla principal; clasificación por edad (acceso web sin restricciones) | Lo que recoja la web cargada cuenta como recogido por la app | Según la web |
| Chat / comunidad (Stream, Sendbird, CometChat, Firebase Firestore con colecciones de mensajes o comentarios) | A-CON-03/G-CON-03 (denunciar y bloquear) | Mensajes, contenido de usuario, fotos | No |

## Recordatorios
- **"Recoger"** = el dato sale del dispositivo (también si lo envía un SDK). Lo que se procesa solo en el dispositivo no se declara.
- **"Compartir"** (Google) = enviar a un tercero que no actúa solo en tu nombre. Un SDK de anuncios que construye perfiles entre clientes es compartir.
- **"Vinculado a la identidad"** (Apple): casi siempre sí, salvo que existan protecciones específicas.
- Las URLs `http://` impiden declarar "cifrado en tránsito" en Data safety.
