# Reglas de Google Play

Fuentes oficiales consultadas el **2026-11-23**. Varias fechas límite de 2026 ya han pasado y hay cambios anunciados para 2027 ([apartado 9](#9-cambios-anunciados)).
Si hoy es más de 3 meses posterior a la fecha de consulta, avisa en el informe de que conviene volver a comprobar las fuentes.

Formato de cada regla:
- **Exige**: qué pide Google.
- **Comprobar**: dónde y cómo mirarlo (rutas por framework en `frameworks.md`).
- **Corregir**: qué cambiar. 🔧 = cambio seguro, se aplica sin preguntar. ✋ = pide confirmación antes.
- **Nivel** por defecto. Ajústalo si el contexto lo justifica y explica por qué.

Enlaces base:
- Policy Center: https://play.google/developer-content-policy/
- Ayuda de Play Console: https://support.google.com/googleplay/android-developer/

## Índice
1. [Técnico](#1-técnico) · 2. [Permisos](#2-permisos) · 3. [Privacidad](#3-privacidad) · 4. [Cuentas y acceso del revisor](#4-cuentas-y-acceso-del-revisor) · 5. [Pagos](#5-pagos) · 6. [Contenido y funcionalidad](#6-contenido-y-funcionalidad) · 7. [Ficha de tienda](#7-ficha-de-tienda) · 8. [Accesibilidad y UI](#8-accesibilidad-y-ui) · 9. [Cambios anunciados](#9-cambios-anunciados) · 10. [Permisos sensibles: tabla rápida](#10-permisos-sensibles-tabla-rápida)

---

## 1. Técnico

### G-TEC-01 · targetSdkVersion mínimo
- **Exige**:
  - Desde el **2026-08-31**, las apps nuevas y las actualizaciones deben apuntar a **API 36 (Android 16)**. La prórroga opcional hasta el 2026-11-01 ya ha vencido.
  - Wear OS y Android Automotive OS: API 35. Android TV y Android XR: API 34.
  - Las apps ya publicadas que no apunten al menos a API 35 dejan de ser visibles para usuarios nuevos con versiones de Android más recientes que su target.
- **Comprobar**: `targetSdk`/`targetSdkVersion` y `compileSdk` en `android/app/build.gradle(.kts)`, `android/build.gradle` (`ext`), `android/variables.gradle` (Capacitor), `expo-build-properties` en `app.json`, `flutter.targetSdkVersion` (lo define la versión del SDK de Flutter). En Expo sin carpeta `android/`, el valor lo fija la versión del SDK de Expo o `expo-build-properties`.
- **Corregir**:
  - 🔧 subir `targetSdk` y `compileSdk` a 36, compilar y anotar en el informe los cambios de comportamiento que hay que probar.
  - Cambios de comportamiento a probar (no son normas de Play; fuente: notas de comportamiento de Android 15 y 16, no consultadas hoy):
    - Edge-to-edge obligatorio: contenido bajo la barra de estado o de navegación.
    - Gesto atrás predictivo.
    - En pantallas grandes se ignoran las restricciones de orientación y redimensionado.
  - ✋ Si el framework es demasiado antiguo para API 36 (p. ej. versión de Expo/RN/Flutter/Capacitor vieja), propón actualizar el framework.
- **Nivel**: BLOQUEANTE.
- **Fuente**: [Target API level requirements](https://developer.android.com/google/play/requirements/target-sdk), [Help 11926878](https://support.google.com/googleplay/android-developer/answer/11926878) · consultado 2026-11-23.

### G-TEC-02 · Android App Bundle firmado
- **Exige**: las apps nuevas se publican como AAB (desde agosto de 2021); Google Play genera y firma los APK con Play App Signing; tamaño comprimido por instalación ≤ 4 GB. La clave de firma queda fija una vez publicada en un canal abierto.
- **Comprobar**:
  - Scripts y CI: `assembleRelease` frente a `bundleRelease`; `flutter build apk` frente a `flutter build appbundle`; `eas.json` con `"buildType": "apk"` en el perfil de producción.
  - En `buildTypes.release`, `signingConfig signingConfigs.debug` (la plantilla de React Native lo trae así por defecto). Play rechaza bundles firmados con la clave de depuración.
  - Contraseñas del keystore escritas en el repo.
- **Corregir**:
  - 🔧 cambiar el comando de release a bundle.
  - 🔧 crear `signingConfigs.release` que lea de `gradle.properties`/variables de entorno (`MYAPP_UPLOAD_STORE_FILE`, etc.) sin escribir contraseñas, y añadir al checklist generar la upload key si no existe.
  - No muevas ni regeneres un keystore existente, y no leas su contenido ni el de `key.properties`.
  - Comprueba que `*.jks`, `*.keystore` y `key.properties` están en `.gitignore`. Si están versionados, márcalo como BLOQUEANTE de seguridad: hay que sacarlos del repositorio y valorar rotar la upload key con el soporte de Play.
- **Nivel**: BLOQUEANTE.
- **Fuente**: [Android App Bundle](https://developer.android.com/guide/app-bundle), [Prepare and roll out a release](https://support.google.com/googleplay/android-developer/answer/9859348) · consultado 2026-11-23.

### G-TEC-03 · versionCode y versionName
- **Exige**: `versionCode` entero positivo, mayor en cada subida y ≤ 2 100 000 000; no se puede reutilizar. `versionName` es texto libre visible.
- **Comprobar**:
  - Gradle: `versionCode`/`versionName`.
  - Flutter: `pubspec.yaml` → `version: 1.2.3+45` (el número tras `+` es el `versionCode` y el `CFBundleVersion`).
  - Expo: `expo.android.versionCode`, `expo.version` y `eas.json` (`autoIncrement`, `appVersionSource`).
  - Capacitor: `android/app/build.gradle`.

  Pregunta (o busca en el changelog) el último `versionCode` publicado.
- **Corregir**: 🔧 incrementar en 1 (y el build de iOS en paralelo) si no supera al publicado o si el usuario lo pide. Si se usa `autoIncrement` remoto de EAS, no lo toques.
- **Nivel**: BLOQUEANTE si es ≤ al publicado; si no, nada que reportar.
- **Fuente**: [Version your app](https://developer.android.com/studio/publish/versioning) · consultado 2026-11-23.

### G-TEC-04 · 64 bits
- **Exige**: por cada ABI de 32 bits que se incluya, hay que incluir su equivalente de 64 bits (`armeabi-v7a` → `arm64-v8a`, `x86` → `x86_64`). Las apps solo Java/Kotlin cumplen.
- **Comprobar**: `abiFilters` en Gradle, carpetas `jniLibs/`, archivos `.so` del repo, `reactNativeArchitectures` en `gradle.properties`.
- **Corregir**: 🔧 añadir el ABI de 64 bits a `abiFilters` o quitar el filtro; ✋ si una `.so` de terceros no tiene versión de 64 bits, hay que actualizar esa librería.
- **Nivel**: BLOQUEANTE.
- **Fuente**: [64-bit requirement](https://developer.android.com/google/play/requirements/64-bit) · consultado 2026-11-23.

### G-TEC-05 · Páginas de memoria de 16 KB
- **Exige**: las apps que apuntan a API 35+ deben soportar páginas de 16 KB en dispositivos de 64 bits. **Desde el 2027-02-01** no se podrán publicar actualizaciones sin ese soporte. Afecta solo a apps con código nativo (NDK propio o en algún SDK); React Native, Flutter y muchos SDK incluyen `.so`.
- **Comprobar**:
  - Versión de AGP ≥ 8.5.1 (`com.android.tools.build:gradle`, `libs.versions.toml`) y NDK ≥ r28 (`ndkVersion`).
  - Versión del framework y de las librerías nativas.
  - Con un AAB/APK compilado: `zipalign -c -P 16 -v 4 app.apk` o `bundletool dump config --bundle=app.aab | grep alignment` (debe salir `PAGE_ALIGNMENT_16K`). En un dispositivo, `adb shell getconf PAGE_SIZE` debe devolver 16384 en el emulador de 16 KB.
- **Corregir**:
  - 🔧 subir AGP/NDK si es un cambio menor.
  - ✋ actualizar framework o librerías nativas.
  - Con NDK ≤ r27, añadir `-Wl,-z,max-page-size=16384`.
- **Nivel**: RIESGO hasta el 2027-02-01; BLOQUEANTE desde esa fecha.
- **Fuente**: [Support 16 KB page sizes](https://developer.android.com/guide/practices/page-sizes) · consultado 2026-11-23.

### G-TEC-06 · Estabilidad: sin crashes ni funciones rotas
- **Exige**: no se permiten apps que se cierran, se bloquean, no cargan o no responden.
- **Comprobar**: compila y arranca si puedes. Causas típicas: falta `google-services.json`, `localhost`/`10.0.2.2` en release, ProGuard/R8 eliminando clases (falta `proguard-rules.pro` de librerías que lo piden), permisos que se piden sin declarar. Recomienda revisar el *informe previo al lanzamiento* de Play Console.
- **Corregir**: 🔧 configuración evidente; ✋ lógica.
- **Nivel**: BLOQUEANTE.
- **Fuente**: [Minimum functionality](https://support.google.com/googleplay/android-developer/answer/9898783) · consultado 2026-11-23.

### G-TEC-07 · Prueba cerrada para cuentas personales nuevas
- **Exige**: las cuentas de desarrollador personales creadas después del 2023-11-13 necesitan una prueba cerrada con **al menos 12 testers** apuntados de forma continuada durante **14 días seguidos** antes de pedir acceso a producción.
- **Comprobar**: pregunta el tipo de cuenta si no lo sabes.
- **Corregir**: checklist.
- **Nivel**: BLOQUEANTE (si aplica).
- **Fuente**: [Help 14151465](https://support.google.com/googleplay/android-developer/answer/14151465) · consultado 2026-11-23.

### G-TEC-08 · Verificación de desarrollador Android
- **Exige**: desde el 2026-09-30 se protege la instalación de apps de desarrolladores no verificados en dispositivos certificados de Brasil, Indonesia, Singapur y Tailandia; la expansión global está prevista para 2027. Play Console registra automáticamente casi todas las apps de Play.
- **Corregir**: checklist informativo (comprobar en Play Console que la app figura como registrada).
- **Nivel**: MEJORA.
- **Fuente**: [Android developer verification](https://developer.android.com/developer-verification) · consultado 2026-11-23.

---

## 2. Permisos

Antes de opinar sobre permisos, mira el **manifest fusionado**: las librerías añaden permisos sin que aparezcan en tu `AndroidManifest.xml`. Usa `android/app/build/intermediates/merged_manifests/release/**/AndroidManifest.xml` si existe, o `./gradlew :app:processReleaseManifest`, o la lista de permisos de la propia librería. Para quitar un permiso que añade una librería:
- Nativo/RN/Flutter/Capacitor: `<uses-permission android:name="…" tools:node="remove"/>` con `xmlns:tools="http://schemas.android.com/tools"` en `<manifest>`.
- Expo: `expo.android.blockedPermissions`.

### G-PER-01 · Regla general de permisos sensibles
- **Exige**:
  - Pedir permisos solo para funciones principales anunciadas en la ficha, de forma incremental y en contexto.
  - Respetar la denegación y ofrecer alternativa.
  - Los permisos restringidos fuera de los usos permitidos necesitan el *Formulario de declaración de permisos* en Play Console.
  - No vender datos obtenidos con permisos.
  - Usar selectores del sistema (fotos, contactos, compartir) cuando basten.
- **Comprobar**: cada permiso del manifest frente a su uso real en el código. Un permiso sin uso = quitar.
- **Corregir**: 🔧 quitar permisos sin uso. ✋ quitar permisos que sí se usan (implica cambiar la función).
- **Nivel**: RIESGO (los restringidos tienen regla propia, más abajo).
- **Fuente**: [Permissions and APIs that access sensitive information](https://support.google.com/googleplay/android-developer/answer/9888170) · consultado 2026-11-23.

### G-PER-02 · SMS y registro de llamadas
- **Exige**:
  - Solo la app registrada como gestor predeterminado de SMS, teléfono o asistente puede declarar `READ_SMS`, `RECEIVE_SMS`, `SEND_SMS`, `RECEIVE_MMS`, `RECEIVE_WAP_PUSH`, `READ_CALL_LOG`, `WRITE_CALL_LOG`, `PROCESS_OUTGOING_CALLS`. Ni siquiera como placeholder.
  - Hay excepciones temporales con declaración: identificador de llamadas y antispam, copias de seguridad, companion de dispositivos, banca/UPI por SMS, etc.
  - **No valen**: verificar OTP leyendo todos los SMS, invitar contactos, grabar llamadas.
- **Comprobar**: esos permisos en el manifest fusionado; librerías de lectura de SMS (`react-native-android-sms-listener`, `telephony`, `sms_autofill` antiguos, `readsms`).
- **Corregir**:
  - 🔧 quitar el permiso si no hay uso.
  - ✋ sustituir por las alternativas:
    - OTP: SMS Retriever API, SMS User Consent API o Digital Credentials API. Elige la librería del framework que implemente una de esas APIs y verifica su nombre exacto y su mantenimiento en npm o pub.dev antes de proponerla.
    - Enviar SMS: intent `SMS`.
    - Llamar: intent `ACTION_DIAL`, que no necesita `CALL_PHONE`.
- **Nivel**: BLOQUEANTE.
- **Fuente**: [SMS and Call Log permissions](https://support.google.com/googleplay/android-developer/answer/10208820) · consultado 2026-11-23.

### G-PER-03 · Ubicación en segundo plano
- **Exige**:
  - `ACCESS_BACKGROUND_LOCATION` solo si es esencial para la finalidad principal y aporta un beneficio claro; no para anuncios ni analítica.
  - Requiere declaración en Play Console (App content → Sensitive app permissions → Location permissions) y un vídeo de ≤ 30 s.
  - Requiere una **divulgación destacada** antes del diálogo del sistema. Debe incluir la palabra "ubicación", indicar el uso en segundo plano ("cuando la app está cerrada o no se usa") y listar todas las funciones que lo usan.
  - Una sola función por app. La foreground service de ubicación solo puede continuar una acción iniciada por el usuario.
- **Comprobar**: permiso en el manifest; `expo.android.permissions`; `requestBackgroundPermissionsAsync`, `Geolocator` con `LocationAccuracy` en segundo plano, `background_location`, `react-native-background-geolocation`.
- **Corregir**:
  - 🔧 quitar el permiso si no hay seguimiento real con la app cerrada.
  - ✋ si es esencial: añadir pantalla de divulgación con el texto exigido y preparar la declaración. Texto sugerido: «[Nombre] recoge datos de ubicación para [función] incluso cuando la app está cerrada o no se está usando.»
- **Nivel**: BLOQUEANTE.
- **Fuente**: [Location permissions](https://support.google.com/googleplay/android-developer/answer/9799150) · consultado 2026-11-23.

### G-PER-04 · QUERY_ALL_PACKAGES
- **Exige**: solo si la finalidad principal es buscar o interoperar con cualquier app instalada (buscadores del dispositivo, antivirus, gestores de archivos, navegadores). Hay excepciones temporales para banca/pagos regulados (solo seguridad) y apuestas con geofencing; los préstamos personales no se incluyen. Requiere declaración.
- **Comprobar**: permiso en el manifest fusionado (algunas librerías de "share" o detección de apps lo añaden).
- **Corregir**: 🔧 quitarlo y declarar los paquetes concretos con `<queries><package android:name="…"/></queries>` o `<queries><intent>…</intent></queries>` cuando se use `canOpenURL`/`Linking.canOpenURL`/`canLaunchUrl` contra apps concretas.
- **Nivel**: BLOQUEANTE.
- **Fuente**: [Package visibility (QUERY_ALL_PACKAGES)](https://support.google.com/googleplay/android-developer/answer/10158779) · consultado 2026-11-23.

### G-PER-05 · Fotos y vídeos (READ_MEDIA_IMAGES / READ_MEDIA_VIDEO)
- **Exige**: con API 33+, estos permisos solo si el selector de fotos del sistema no basta para la función principal (galerías, editores que gestionan toda la fototeca). Requieren declaración. En vigor desde el 2025-05-28.
- **Comprobar**: permisos en el manifest fusionado (los añaden versiones antiguas de `expo-media-library`, `image_picker`, `@capacitor/camera`, etc.).
- **Corregir**:
  - 🔧 quitar los permisos si la app solo elige imágenes puntuales; las versiones actuales de `expo-image-picker`, `image_picker` y `@capacitor/camera` usan el Photo Picker.
  - ✋ si hay que cambiar la librería.
  - Mantener `READ_EXTERNAL_STORAGE` solo con `android:maxSdkVersion="32"`.
- **Nivel**: BLOQUEANTE.
- **Fuente**: [Photo and video permissions](https://support.google.com/googleplay/android-developer/answer/14115180) · consultado 2026-11-23.

### G-PER-06 · Tipos de foreground service
- **Exige**: con API 34+, declarar en Play Console cada tipo de foreground service usado (descripción, impacto si se interrumpe, vídeo y caso de uso) y su permiso `FOREGROUND_SERVICE_*`. Los tipos se revisan; `specialUse` solo si ningún otro encaja.
- **Comprobar**: `<service android:foregroundServiceType="…">` y permisos `FOREGROUND_SERVICE_*` en el manifest fusionado (reproductores de audio, geolocalización, sincronización, notificaciones de llamadas).
- **Corregir**: 🔧 quitar los que no se usan; checklist con el texto de la declaración para los que sí.
- **Nivel**: RIESGO.
- **Fuente**: [Foreground service types](https://support.google.com/googleplay/android-developer/answer/13392821) · consultado 2026-11-23.

### G-PER-07 · Alarmas exactas
- **Exige**: `USE_EXACT_ALARM` solo para apps de alarma, temporizador o calendario con avisos de eventos; el resto, `SCHEDULE_EXACT_ALARM` (lo concede el usuario). Requiere declaración.
- **Comprobar**: ambos permisos; librerías de notificaciones locales (`notifee`, `expo-notifications`, `flutter_local_notifications` con `exactAllowWhileIdle`).
- **Corregir**: 🔧 si la app no es de alarmas/calendario, quitar `USE_EXACT_ALARM` y usar alarmas inexactas o `SCHEDULE_EXACT_ALARM`.
- **Nivel**: BLOQUEANTE.
- **Fuente**: [Permissions policy](https://support.google.com/googleplay/android-developer/answer/9888170) · consultado 2026-11-23.

### G-PER-08 · REQUEST_INSTALL_PACKAGES
- **Exige**: solo si la función principal incluye enviar o recibir paquetes y permitir instalaciones iniciadas por el usuario (navegadores, mensajería con adjuntos, gestores de archivos, MDM, backup, wearables). No para autoactualizarse.
- **Corregir**: 🔧 quitarlo si no aplica (librerías de "actualización in-app" vía APK lo añaden). Para actualizar, usar In-App Updates de Play.
- **Nivel**: BLOQUEANTE.
- **Fuente**: [Permissions policy](https://support.google.com/googleplay/android-developer/answer/9888170) · consultado 2026-11-23.

### G-PER-09 · MANAGE_EXTERNAL_STORAGE (acceso a todos los archivos)
- **Exige**: con API 30+, solo si el Storage Access Framework y MediaStore no bastan para la función principal. Requiere declaración.
- **Corregir**: 🔧 quitarlo y usar SAF/MediaStore o el directorio de la app; ✋ si hay que reescribir el acceso a archivos.
- **Nivel**: BLOQUEANTE.
- **Fuente**: [Permissions policy](https://support.google.com/googleplay/android-developer/answer/9888170) · consultado 2026-11-23.

### G-PER-10 · AccessibilityService
- **Exige**: `isAccessibilityTool` solo para apps cuyo fin principal es ayudar a personas con discapacidad. El resto necesita divulgación destacada, consentimiento y declaración con vídeo. Prohibido: grabar llamadas, agentes autónomos, cambiar ajustes sin permiso o eludir controles de seguridad.
- **Nivel**: BLOQUEANTE si se usa sin declaración.
- **Fuente**: [AccessibilityService API](https://support.google.com/googleplay/android-developer/answer/10964491) · consultado 2026-11-23.

### G-PER-11 · USE_FULL_SCREEN_INTENT
- **Exige**: desde Android 14, solo se concede por defecto a apps de alarmas o llamadas; el resto debe pedirlo y funcionar si se deniega. Requiere declaración.
- **Corregir**: 🔧 quitarlo si la app no es de alarmas ni llamadas (lo añaden algunas librerías de notificaciones).
- **Nivel**: RIESGO.
- **Fuente**: [Permissions policy](https://support.google.com/googleplay/android-developer/answer/9888170) · consultado 2026-11-23.

### G-PER-12 · Divulgación destacada y consentimiento
- **Exige**: cuando el acceso o la recogida de datos puede no ser lo que el usuario espera (p. ej. en segundo plano), mostrar dentro de la app, en el uso normal y antes del permiso o la recogida, una divulgación que diga qué dato, para qué y con quién se comparte, y obtener consentimiento con una acción afirmativa. Salir de la pantalla o tocar fuera no es consentimiento.
- **Comprobar**: recogida de contactos, ubicación, lista de apps, datos de salud o subida de fotos sin pantalla previa.
- **Corregir**: ✋ añadir pantalla de divulgación (formato sugerido por Google: «[App] recoge/transmite/sincroniza/almacena [dato] para [función], [cuándo]»).
- **Nivel**: BLOQUEANTE si aplica.
- **Fuente**: [User Data](https://support.google.com/googleplay/android-developer/answer/10144311) · consultado 2026-11-23.

---

## 3. Privacidad

### G-PRI-01 · Política de privacidad en Play Console y dentro de la app
- **Exige**: enlace en el campo de Play Console **y** accesible dentro de la app. La URL debe ser activa, pública, sin restricción geográfica, no un PDF y no editable.
- **Contenido**: datos del desarrollador y contacto de privacidad; tipos de datos personales y sensibles que se acceden, recogen, usan y comparten; con quién; manejo seguro; retención y borrado; titulado como política de privacidad; nombre de la entidad de la ficha o de la app.
- Obligatoria aunque la app no recoja datos sensibles.
- **Comprobar**: igual que A-PRI-01.
- **Corregir**: 🔧 enlace dentro de la app desde una constante única; ✋ pide la URL si no consta. Nunca inventes una.
- **Nivel**: BLOQUEANTE.
- **Fuente**: [User Data](https://support.google.com/googleplay/android-developer/answer/10144311) · consultado 2026-11-23.

### G-PRI-02 · Formulario de seguridad de los datos (Data safety)
- **Exige**:
  - Toda app (salvo las solo de prueba interna) debe completarlo, aunque no recoja datos, y mantenerlo exacto.
  - "Recogida" incluye lo que envían los SDK y las WebViews que controla la app. No cuenta el procesamiento solo en el dispositivo ni el cifrado de extremo a extremo.
  - "Compartir" incluye las transferencias a terceros y a SDK. No cuenta compartir con proveedores que actúan en tu nombre, por requerimiento legal, a iniciativa del usuario o con datos anonimizados.
  - Hay que indicar qué datos son opcionales y si se pueden borrar.
  - "Cifrado en tránsito" solo se declara si se cifra **todo** lo que sale del dispositivo, incluidos los SDK.
- **Comprobar**: SDK detectados (`sdks.md`), llamadas al backend y datos que envían, URLs `http://` (si existen, no se puede declarar cifrado en tránsito), mecanismo de borrado.
- **Corregir**:
  - Checklist manual con la tabla propuesta (tipo de dato → recogido/compartido → finalidad → opcional), indicando que el usuario la valide con la guía de cada SDK y el Play SDK Index.
  - ✋ Propón cambiar `http://` por `https://`. No hagas peticiones al host para comprobar si admite HTTPS: lo confirma el usuario.
- **Nivel**: BLOQUEANTE (sin él no se publica; las incoherencias provocan rechazo o retirada).
- **Fuente**: [Data safety section](https://support.google.com/googleplay/android-developer/answer/10787469) · consultado 2026-11-23.

### G-PRI-03 · Borrado de cuenta (en la app y en la web)
- **Exige**: si se pueden crear cuentas desde la app:
  - Ruta **dentro de la app** para borrar la cuenta y sus datos.
  - **Enlace web** donde pedir el borrado sin reinstalar la app, introducido en Play Console. Debe mencionar el nombre de la app o del desarrollador y hacer visible la ruta de borrado.
  - Desactivar o congelar no es borrar. Se puede retener lo necesario por seguridad, fraude o ley si se informa.
  - También hay que responder a las preguntas de borrado en Data safety.
- **Comprobar**: igual que A-PRI-07, más la existencia de una página web de borrado (busca en la web del proyecto `/delete-account`, `/eliminar-cuenta`).
- **Corregir**: 🔧 en la app, igual que A-PRI-07. ✋ Página web: propón una página estática sencilla con formulario o instrucciones si el proyecto tiene web; si no, checklist.
- **Nivel**: BLOQUEANTE.
- **Fuente**: [Account deletion requirements](https://support.google.com/googleplay/android-developer/answer/13327111) · consultado 2026-11-23.

### G-PRI-04 · Identificadores persistentes y SDK de terceros
- **Exige**: no vincular identificadores persistentes (IMEI, IMSI, número de serie de SIM) con datos personales o identificadores reiniciables, salvo telefonía o MDM. Eres responsable de que tus SDK cumplan; si un SDK recoge datos sensibles por defecto, Google puede pedir pruebas en 2 semanas.
- **Comprobar**: `READ_PHONE_STATE`, `getDeviceId`, `getImei`, `getSubscriberId`, `Build.getSerial`.
- **Corregir**: ✋ sustituir por identificadores reiniciables o un ID propio de instalación.
- **Nivel**: BLOQUEANTE si se usa IMEI o similar.
- **Fuente**: [User Data](https://support.google.com/googleplay/android-developer/answer/10144311) · consultado 2026-11-23.

### G-PRI-05 · ID de publicidad
- **Exige**:
  - Si se usa el ID de publicidad (lo hacen los SDK de anuncios y atribución), hay que declararlo en Play Console (App content → Advertising ID).
  - Con target 33+, el permiso `com.google.android.gms.permission.AD_ID` debe estar presente. Si no se usa, hay que declararlo y quitar el permiso.
- **Verificación**: ⚠️ regla no verificada en la consulta del 2026-11-23. Compruébala en https://support.google.com/googleplay/android-developer/answer/6048248 antes de citarla como BLOQUEANTE.
- **Comprobar**: SDK de anuncios o atribución; permiso `AD_ID` en el manifest fusionado.
- **Corregir**: 🔧 quitar `AD_ID` con `tools:node="remove"` si no hay SDK de anuncios ni atribución; checklist para la declaración.
- **Nivel**: RIESGO.
- **Fuente**: [Advertising ID](https://support.google.com/googleplay/android-developer/answer/6048248) · **no consultada**.

### G-PRI-06 · Público objetivo y familias
- **Exige**:
  - Completar "Público objetivo y contenido".
  - Si la app es principalmente para menores de 13, se aplica la política de Familias: solo SDK de anuncios autocertificados y consentimiento parental cuando proceda.
  - Si el público es mixto, pantalla neutral de edad.
  - El marketing infantil (personajes infantiles) puede llevar a tratarla como app infantil.
- **Corregir**: checklist; ✋ cambiar SDK de anuncios.
- **Nivel**: BLOQUEANTE si es infantil con SDK no autorizados.
- **Fuente**: [Target audience and content](https://support.google.com/googleplay/android-developer/answer/9867159) · consultado 2026-11-23.

---

## 4. Cuentas y acceso del revisor

### G-CUE-01 · Acceso a la app (credenciales para revisión)
- **Exige**:
  - Si alguna función requiere login, pago u otra restricción, dar en Play Console → *Acceso a la app* credenciales o instrucciones que funcionen.
  - Las credenciales deben ser reutilizables, válidas desde cualquier país y sin caducidad, y saltarse el 2FA/OTP.
  - Instrucciones en inglés. Para QR, una URL estática.

  Si el revisor no puede entrar, se bloquean las actualizaciones o se retira la app.
- **Comprobar**: login, OTP por SMS, verificación de email, geobloqueo, paywall.
- **Corregir**: checklist con plantilla en inglés. ✋ Si el login exige OTP, propón una cuenta de revisión con OTP fijo en el backend (no la crees tú).
- **Nivel**: BLOQUEANTE.
- **Fuente**: [App access / login credentials](https://support.google.com/googleplay/android-developer/answer/15748846) · consultado 2026-11-23.

> Google Play no exige ofrecer un login equivalente a Sign in with Apple.

---

## 5. Pagos

Todos los cambios de esta sección son ✋: pide confirmación siempre.

### G-PAG-01 · Bienes digitales con Google Play Billing
- **Exige**: las apps de pago y las compras in-app de bienes digitales (funciones, contenido, suscripciones, moneda virtual, software en la nube) usan Google Play Billing, salvo las secciones 3, 8 y 9 de la política.
- **Comprobar**: igual que A-PAG-01, pero con librerías de Play Billing (`react-native-iap`, `expo-iap`, `react-native-purchases`, `in_app_purchase`, `purchases_flutter`, `com.android.billingclient`).
- **Corregir**: ✋ integrar Play Billing (si ya se integra StoreKit con una librería multiplataforma, se reutiliza).
- **Nivel**: BLOQUEANTE.
- **Fuente**: [Payments policy](https://support.google.com/googleplay/android-developer/answer/9858738) · consultado 2026-11-23.

### G-PAG-02 · No dirigir a otros métodos de pago (sección 4) y programas por país
- **Exige**:
  - No llevar al usuario a otros métodos de pago para bienes digitales (ficha, promociones, WebViews, botones, enlaces, registro), salvo programas en los que la app esté inscrita.
  - **EEE, India, Corea del Sur**: programas de facturación alternativa y enlaces externos (secciones 8 y 9), con inscripción.
  - **EE. UU.**: desde el 2025-10-29, mientras siga vigente la orden judicial, Google no prohíbe comunicar precios externos, enlazar a compras o usar otros métodos. Existen los programas *Alternative billing for US users* y *External content links*, con inscripción en Play Console. Desde el 2026-10-01 hay que reportar transacciones y pagar comisiones.
- **Comprobar**: enlaces o botones a pagos web para contenido digital; países de distribución.
- **Corregir**: ✋ inscribirse en el programa del país, limitar el enlace a ese país o pasar a Play Billing.
- **Nivel**: BLOQUEANTE si se enlaza sin inscripción.
- **Fuente**: [Payments policy](https://support.google.com/googleplay/android-developer/answer/9858738), [Payments FAQ](https://support.google.com/googleplay/android-developer/answer/10281818), [US court order](https://support.google.com/googleplay/android-developer/answer/15582165), [Alternative billing US](https://support.google.com/googleplay/android-developer/answer/16497028), [External content links US](https://support.google.com/googleplay/android-developer/answer/16470497) · consultado 2026-11-23.

### G-PAG-03 · Excepciones (sección 3): bienes físicos y servicios **no** usan Play Billing
- **Exige**: no usan Play Billing:
  - Bienes y servicios físicos (comida a domicilio, transporte, gimnasios, entradas, reservas, citas).
  - Facturas de tarjeta o suministros.
  - Pagos entre personas.
  - Subastas.
  - Donaciones deducibles.
  - Apuestas reguladas.

  También están exentas las tarjetas regalo, los servicios 1:1 en directo y las propinas íntegras a creadores. Las apps de solo consumo pueden mencionar la web sin enlazar.
- **Nivel**: no es hallazgo; si se usa Play Billing para bienes físicos, avisa.
- **Fuente**: [Payments policy](https://support.google.com/googleplay/android-developer/answer/9858738) · consultado 2026-11-23.

### G-PAG-04 · Precios coherentes y loot boxes
- **Exige**: el precio mostrado debe coincidir con el de la interfaz de Play Billing; la moneda virtual solo se usa dentro de la app; las probabilidades de las loot boxes deben mostrarse.
- **Comprobar**: precios escritos a mano en el paywall en lugar de los de `ProductDetails`.
- **Corregir**: ✋ leer precios del SDK de compras.
- **Nivel**: RIESGO.
- **Fuente**: [Payments policy](https://support.google.com/googleplay/android-developer/answer/9858738) · consultado 2026-11-23.

---

## 6. Contenido y funcionalidad

### G-CON-01 · Funcionalidad mínima
- **Exige**: apps estables, funcionales y con contenido útil. No se permiten:
  - Apps de funcionalidad o contenido limitado: solo texto estático o PDF, un único fondo de pantalla, apps que no hacen nada.
  - Apps rotas: no instalan, no cargan o no responden.
- **Comprobar**: placeholders y pantallas vacías (igual que A-CON-02), botones sin acción, `server.url` remoto que falla sin conexión.
- **Corregir**: igual que A-CON-02.
- **Nivel**: BLOQUEANTE si la app es casi vacía o hay funciones rotas visibles.
- **Fuente**: [Functionality, Content and User Experience](https://support.google.com/googleplay/android-developer/answer/9898783) · consultado 2026-11-23.

### G-CON-02 · WebView y spam
- **Exige**: se prohíbe la app cuyo fin principal es mostrar en WebView una web **sin permiso de su propietario**, o generar tráfico de afiliación. También el contenido repetitivo o varias apps casi iguales.
- **Comprobar**: `server.url`/WebView raíz que apunta a una web de terceros; varias variantes de la misma app.
- **Corregir**:
  - Si la web es del propio desarrollador, no infringe esta regla, pero aplica G-CON-01: marca RIESGO y añade funciones nativas (igual que A-CON-01).
  - Si es de un tercero, ✋ pide prueba de permiso o retira.
- **Nivel**: BLOQUEANTE (web de tercero) / RIESGO (web propia sin funciones nativas).
- **Fuente**: [Spam and minimum functionality](https://support.google.com/googleplay/android-developer/answer/9899034) · consultado 2026-11-23.

### G-CON-03 · Contenido generado por usuarios
- **Exige**:
  - Aceptar términos de uso que definan y prohíban el contenido inapropiado **antes** de crear o subir contenido.
  - Moderación continua y razonable.
  - Sistema dentro de la app para **denunciar** contenido y usuarios.
  - **Bloqueo** de usuarios si hay interacción 1:1 o contenido público.
  - Las apps cerradas (empresa, colegio) necesitan al menos denuncia.
- **Comprobar**: igual que A-CON-03, más pantalla de aceptación de términos en el registro.
- **Corregir**: ✋ igual que A-CON-03.
- **Nivel**: BLOQUEANTE.
- **Fuente**: [User Generated Content](https://support.google.com/googleplay/android-developer/answer/9876937) · consultado 2026-11-23.

### G-CON-04 · Clasificación de contenido (IARC)
- **Exige**: toda app necesita clasificación. Se completa el cuestionario IARC en Play Console y se repite si cambia el contenido; las apps sin clasificar se retiran. Los anuncios no pueden ser más adultos que la app.
- **Corregir**: checklist con respuestas propuestas (violencia, sexualidad, lenguaje, sustancias, apuestas, interacción entre usuarios, compras digitales, ubicación compartida, navegación web sin restricciones).
- **Nivel**: BLOQUEANTE si no está hecho.
- **Fuente**: [Content ratings](https://support.google.com/googleplay/android-developer/answer/9898843) · consultado 2026-11-23.

### G-CON-05 · Mensajes en nombre del usuario
- **Exige**: no enviar SMS, emails u otros mensajes en nombre del usuario sin que confirme contenido y destinatarios.
- **Comprobar**: invitaciones automáticas a contactos, `SmsManager.sendTextMessage` sin pantalla de confirmación.
- **Corregir**: ✋ usar el intent de compartir o SMS para que el usuario confirme.
- **Nivel**: BLOQUEANTE si aplica.
- **Fuente**: [Spam policy](https://support.google.com/googleplay/android-developer/answer/9899034) · consultado 2026-11-23.

---

## 7. Ficha de tienda

### G-FIC-01 · Textos de la ficha
- **Exige**:
  - Título ≤ 30 caracteres; descripción breve ≤ 80; descripción completa ≤ 4000.
  - Ni en el título, el icono ni el nombre del desarrollador: emojis, emoticonos, caracteres especiales repetidos, MAYÚSCULAS (salvo marca) ni reclamos de ranking, precio o promoción ("#1", "Mejor", "Nuevo", "App del año", "10 % de descuento", "Editor's choice").
  - En la descripción: sin afirmaciones engañosas, testimonios anónimos o sin atribuir, ni palabras clave repetitivas o irrelevantes.
  - Descripción breve sin emojis ni llamadas a la acción del tipo "Descarga ya".
- **Comprobar**: `fastlane/metadata/android/<locale>/{title,short_description,full_description}.txt`, `store.config.json` o textos aportados.
- **Corregir**: 🔧 en archivos del repo; si no, propuesta en el checklist.
- **Nivel**: BLOQUEANTE (límites, emojis en el título); RIESGO (relleno).
- **Fuente**: [Metadata policy](https://support.google.com/googleplay/android-developer/answer/9898842), [Store listing](https://support.google.com/googleplay/android-developer/answer/9859152) · consultado 2026-11-23.

### G-FIC-02 · Recursos gráficos
- **Exige**:
  - **Icono**: 512×512 PNG de 32 bits con alfa, ≤ 1024 KB.
  - **Gráfico destacado**: 1024×500 JPEG o PNG de 24 bits sin alfa.
  - **Capturas de teléfono**: 2 a 8, PNG o JPEG ≤ 8 MB, cada lado de 320 a 3840 px, con el lado largo ≤ 2,3 veces el corto. Para optar a los formatos recomendados: al menos 4 de ≥ 1080 px (1080×1920 en vertical o 1920×1080 en horizontal).
  - **Tablets/Chromebook**: recomendadas 4, de 1080 a 7680 px, 16:9 o 9:16.
  - Texto alternativo ≤ 140 caracteres. Vídeo opcional (YouTube público u oculto, sin anuncios).
- **Comprobar**: carpeta de assets y dimensiones si están en el repo.
- **Corregir**: checklist.
- **Nivel**: BLOQUEANTE (sin icono, gráfico destacado o 2 capturas no se publica).
- **Fuente**: [Preview assets](https://support.google.com/googleplay/android-developer/answer/9866151) · consultado 2026-11-23.

### G-FIC-03 · Capturas fieles y sin contenido ajeno
- **Exige**: las capturas y la promo deben reflejar la app real; sin contenido sexual sugerente, palabrotas ni violencia gráfica; sin nombres de famosos ni logos de marcas sin permiso.
- **Comprobar**: capturas con marco de iPhone o con interfaz de iOS → no reflejan la app de Android (MEJORA/RIESGO).
- **Nivel**: RIESGO.
- **Fuente**: [Metadata policy](https://support.google.com/googleplay/android-developer/answer/9898842) · consultado 2026-11-23.

### G-FIC-04 · Menciones a la otra plataforma
- **Exige**: la política de metadatos de Google no prohíbe expresamente mencionar iOS, pero sí el contenido irrelevante o engañoso en la ficha.
- **Comprobar**: "Disponible en App Store", "iPhone", badges de Apple en la app Android o en la ficha.
- **Corregir**: 🔧 ocultar en Android con condición de plataforma.
- **Nivel**: MEJORA.
- **Fuente**: [Metadata policy](https://support.google.com/googleplay/android-developer/answer/9898842) · consultado 2026-11-23.

### G-FIC-05 · Datos de contacto
- **Exige**: el email de contacto es obligatorio en la ficha; la web y el teléfono son opcionales.
- **Nivel**: BLOQUEANTE (checklist).
- **Fuente**: [Store listing](https://support.google.com/googleplay/android-developer/answer/9859152) · consultado 2026-11-23.

---

## 8. Accesibilidad y UI

### G-UI-01 · Áreas táctiles de 48dp
- **Exige**: cada elemento interactivo con un área enfocable de al menos 48×48dp (los componentes Material de Compose ya lo aplican).
- **Comprobar**: igual que A-UI-01, con 48 como umbral en Android. El informe previo al lanzamiento de Play lo señala.
- **Corregir**: 🔧 `hitSlop`, `minWidth`/`minHeight` de 48dp, `MaterialTapTargetSize.padded`, `min-height:48px`.
- **Nivel**: MEJORA.
- **Fuente**: [Make apps more accessible](https://developer.android.com/guide/topics/ui/accessibility/apps) · consultado 2026-11-23.

### G-UI-02 · Contraste y descripciones
- **Exige**:
  - Contraste ≥ 4.5:1 para texto de menos de 18sp (o en negrita de menos de 14sp); ≥ 3:1 para el resto.
  - `contentDescription` que describa la finalidad del elemento, sin repetir el tipo ("Enviar", no "Botón enviar") y única en listas.
  - Los elementos decorativos se ocultan a la accesibilidad.
- **Corregir**: 🔧 etiquetas en botones de icono.
- **Nivel**: MEJORA.
- **Fuente**: [Make apps more accessible](https://developer.android.com/guide/topics/ui/accessibility/apps) · consultado 2026-11-23.

### G-UI-03 · Tema oscuro
- **Exige** (recomendación): tema que herede de `DayNight`, colores de tema en lugar de colores fijos, recursos `-night`, splash sin fondo blanco fijo. Force Dark (`android:forceDarkAllowed`) es un recurso de compromiso que hay que probar.
- **Comprobar**: tema base en `styles.xml`/`themes.xml`, colores fijos, Expo `userInterfaceStyle`, Flutter `darkTheme`.
- **Corregir**: 🔧 si no hay tema oscuro y el sistema invierte colores rompiendo la UI, fijar el tema claro (`Theme.*.Light`, `forceDarkAllowed=false`, Expo `userInterfaceStyle: "light"`); ✋ implementar tema oscuro.
- **Nivel**: MEJORA (RIESGO si hay textos ilegibles).
- **Fuente**: [Dark theme](https://developer.android.com/develop/ui/views/theming/darktheme) · consultado 2026-11-23.

---

## 9. Cambios anunciados
Avísalos como MEJORA ("prepárate"), salvo que la fecha ya haya pasado cuando se ejecute la skill; en ese caso, trátalos como la regla equivalente.

- **2027-01-27**:
  - Apps con target Android 17 (API 37+): botón de ubicación para peticiones puntuales; `ACCESS_FINE_LOCATION` requerirá declaración.
  - Acceso amplio a contactos restringido al Contact Picker.
  - `READ_CALL_LOG` deja de permitirse para verificar cuentas por llamada.
- **2027-02-01**: actualizaciones sin soporte de 16 KB bloqueadas (G-TEC-05).
- **2027-04-14**: las AppFunctions no pueden engañar a agentes de IA.
- **2027-08-25**: `MANAGE_CONTACTS` restringido (API 38+) y `ACCESS_LOCAL_NETWORK` restringido (API 37+), ambos con declaración.
- **Fuente**: [Permissions policy](https://support.google.com/googleplay/android-developer/answer/9888170), [16 KB](https://developer.android.com/guide/practices/page-sizes) · consultado 2026-11-23.

---

## 10. Permisos sensibles: tabla rápida

| Permiso | Regla | Acción por defecto si no es la función principal |
|---|---|---|
| `READ_SMS`, `RECEIVE_SMS`, `SEND_SMS`, `RECEIVE_MMS`, `RECEIVE_WAP_PUSH` | G-PER-02 | quitar; SMS Retriever / User Consent |
| `READ_CALL_LOG`, `WRITE_CALL_LOG`, `PROCESS_OUTGOING_CALLS` | G-PER-02 | quitar |
| `CALL_PHONE` | G-PER-01 | quitar si solo abre el marcador (`ACTION_DIAL`) |
| `ACCESS_BACKGROUND_LOCATION` | G-PER-03 | quitar |
| `ACCESS_FINE_LOCATION` | G-PER-01 (y 2027-01-27) | valorar `ACCESS_COARSE_LOCATION` |
| `QUERY_ALL_PACKAGES` | G-PER-04 | quitar y usar `<queries>` |
| `READ_MEDIA_IMAGES`, `READ_MEDIA_VIDEO` | G-PER-05 | quitar; Photo Picker |
| `READ_EXTERNAL_STORAGE`, `WRITE_EXTERNAL_STORAGE` | G-PER-01 | `maxSdkVersion="32"` / `"28"` |
| `MANAGE_EXTERNAL_STORAGE` | G-PER-09 | quitar; SAF/MediaStore |
| `REQUEST_INSTALL_PACKAGES` | G-PER-08 | quitar |
| `USE_EXACT_ALARM` | G-PER-07 | quitar; `SCHEDULE_EXACT_ALARM` o inexactas |
| `USE_FULL_SCREEN_INTENT` | G-PER-11 | quitar |
| `FOREGROUND_SERVICE_*` | G-PER-06 | quitar los que no se usan; declarar el resto |
| `BIND_ACCESSIBILITY_SERVICE` | G-PER-10 | quitar salvo herramienta de accesibilidad |
| `READ_CONTACTS`, `WRITE_CONTACTS` | G-PER-01 (y 2027) | quitar si no hay función; selector de contactos |
| `READ_PHONE_STATE`, `READ_PHONE_NUMBERS` | G-PRI-04 | quitar salvo telefonía |
| `RECORD_AUDIO`, `CAMERA` | G-PER-01 | quitar si no hay función |
| `com.google.android.gms.permission.AD_ID` | G-PRI-05 | quitar si no hay SDK de anuncios ni atribución |
| `SYSTEM_ALERT_WINDOW` | G-PER-01 | quitar si no hay burbujas ni overlays esenciales (RN lo añade en debug) |
