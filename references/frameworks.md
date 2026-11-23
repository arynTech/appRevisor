# Archivos clave y cómo aplicar cambios por framework

Lee solo el apartado del framework detectado.

Los comandos de compilar, `npx`, `expo config`/`prebuild` e instalar dependencias ejecutan código del proyecto o descargan paquetes. Pide permiso antes del primero (SKILL.md → Seguridad). Inspeccionar archivos no necesita permiso. Si hay carpetas `android/` o `ios/` generadas, comprueba si se versionan o se regeneran: en Expo con *prebuild* (CNG) se regeneran, así que **los cambios van en `app.json`/`app.config.*` o en un config plugin**, no en las carpetas nativas.

## Detección rápida

| Señal | Framework |
|---|---|
| `package.json` con `expo` y sin `android/`+`ios/` versionadas | Expo gestionado (CNG) |
| `package.json` con `expo` y con `android/`/`ios/` versionadas | Expo bare |
| `package.json` con `react-native` sin `expo` | React Native CLI |
| `pubspec.yaml` con `flutter:` | Flutter |
| `package.json` con `@capacitor/core` + `capacitor.config.*` | Capacitor (Ionic) |
| `config.xml` con `<widget` + `cordova` | Cordova |
| Solo `app/build.gradle(.kts)` + `AndroidManifest.xml` | Android nativo |
| Solo `*.xcodeproj`/`*.xcworkspace` + Swift/ObjC | iOS nativo |

---

## Expo (gestionado / CNG)

| Qué | Dónde |
|---|---|
| Nombre, versión, iconos | `app.json` → `expo.name`, `expo.version`, `expo.icon`, `expo.android.adaptiveIcon` |
| Versión de build | `expo.android.versionCode`, `expo.ios.buildNumber`, o `eas.json` → `cli.appVersionSource: "remote"` + `build.production.autoIncrement` |
| targetSdk / compileSdk / deployment target | plugin `expo-build-properties`: `["expo-build-properties", {"android": {"targetSdkVersion": 36, "compileSdkVersion": 36}, "ios": {"deploymentTarget": "15.1"}}]`. Sin el plugin, lo fija la versión del SDK de Expo (consulta sus notas de versión) |
| Permisos Android | `expo.android.permissions` (añade), `expo.android.blockedPermissions` (elimina los que meten librerías) |
| Textos Info.plist | `expo.ios.infoPlist.NS…UsageDescription` o la opción del config plugin de cada librería (p. ej. `["expo-camera", {"cameraPermission": "…"}]`). El plugin tiene prioridad si ambos existen |
| Privacy manifest | `expo.ios.privacyManifests: { NSPrivacyAccessedAPITypes: [ { NSPrivacyAccessedAPIType: "…", NSPrivacyAccessedAPITypeReasons: ["…"] } ] }` |
| Sign in with Apple | `expo.ios.usesAppleSignIn: true` + `expo-apple-authentication` |
| iPad | `expo.ios.supportsTablet` |
| Modo oscuro | `expo.userInterfaceStyle` (`light` / `dark` / `automatic`) |
| Tipo de build | `eas.json` → `build.<perfil>.android.buildType` (`app-bundle` por defecto; `apk` solo para pruebas) |
| Ver la config final | `npx expo config --type public` (ejecuta `app.config.js`: requiere permiso) |
| Compilar / comprobar | Con permiso: `npx expo-doctor` (descarga el paquete), `npx tsc --noEmit`, `npx expo prebuild --clean --no-install` en una copia temporal para inspeccionar el manifest y el Info.plist generados. Build real: `eas build -p android --profile production` (sube el código a la nube de Expo y requiere cuenta EAS: pide confirmación expresa) |

## React Native CLI / Expo bare

| Qué | Dónde |
|---|---|
| targetSdk / compileSdk / minSdk | `android/build.gradle` → `ext { targetSdkVersion = … }` |
| versionCode / versionName | `android/app/build.gradle` → `defaultConfig` |
| Firma release | `android/app/build.gradle` → `signingConfigs` / `buildTypes.release` (la plantilla trae `signingConfig signingConfigs.debug`: corrígelo) |
| Permisos | `android/app/src/main/AndroidManifest.xml` (+ `tools:node="remove"`) |
| Info.plist | `ios/<App>/Info.plist` |
| Privacy manifest | `ios/<App>/PrivacyInfo.xcprivacy` (la plantilla de RN ≥ 0.74 ya lo incluye; complétalo) |
| Deployment target | `ios/Podfile` (`platform :ios, min_ios_version_supported`) y `project.pbxproj` |
| 16 KB / NDK | `android/build.gradle` → `ndkVersion`; versión de AGP |
| Compilar | `cd android && ./gradlew bundleRelease` (Windows: `gradlew.bat`); iOS solo en macOS: `xcodebuild -workspace ios/<App>.xcworkspace -scheme <App> -configuration Release -sdk iphoneos -destination generic/platform=iOS build CODE_SIGNING_ALLOWED=NO` |

## Flutter

| Qué | Dónde |
|---|---|
| Versión | `pubspec.yaml` → `version: X.Y.Z+N` (N = versionCode y CFBundleVersion) |
| targetSdk / compileSdk / minSdk | `android/app/build.gradle(.kts)` → `defaultConfig`. Si pone `flutter.targetSdkVersion`, el valor depende del SDK de Flutter instalado (`flutter --version`); para fijarlo, sustitúyelo por el número |
| Permisos | `android/app/src/main/AndroidManifest.xml` |
| Info.plist | `ios/Runner/Info.plist` |
| Privacy manifest | `ios/Runner/PrivacyInfo.xcprivacy` **y** añadirlo al target Runner en `ios/Runner.xcodeproj/project.pbxproj` |
| Deployment target | `ios/Podfile` (`platform :ios, 'X'`) y `IPHONEOS_DEPLOYMENT_TARGET` en el pbxproj |
| iPad | `TARGETED_DEVICE_FAMILY` en el pbxproj |
| Pagos | `in_app_purchase`, `purchases_flutter` (RevenueCat) |
| Compilar | `flutter pub get`, `flutter analyze`, `flutter build appbundle --release`; iOS solo en macOS: `flutter build ipa --no-codesign` |

## Capacitor (Ionic)

| Qué | Dónde |
|---|---|
| Config | `capacitor.config.ts`/`.json` → `appId`, `appName`, `webDir`, **`server.url`** (si es remoto = web envuelta, ver A-CON-01), `server.cleartext` |
| targetSdk / compileSdk / minSdk | `android/variables.gradle` |
| versionCode / versionName | `android/app/build.gradle` |
| Permisos | `android/app/src/main/AndroidManifest.xml` |
| Info.plist | `ios/App/App/Info.plist` |
| Privacy manifest | `ios/App/App/PrivacyInfo.xcprivacy` + añadirlo al target App en `ios/App/App.xcodeproj/project.pbxproj` |
| Deployment target | `ios/App/Podfile` y pbxproj (o `Package.swift` si usa SPM) |
| Web | `src/` o `www/` (HTML/CSS/JS): busca ahí placeholders, enlaces de pago, menciones a otras plataformas, áreas táctiles CSS |
| Compilar | `npm run build && npx cap sync`, `cd android && ./gradlew bundleRelease`; iOS solo en macOS |

## Cordova

| Qué | Dónde |
|---|---|
| Config | `config.xml` → `<content src>`, `<preference name="android-targetSdkVersion">`, `<edit-config>` para Info.plist, `<config-file>` para el manifest |
| Compilar | `cordova build android --release -- --packageType=bundle` |

## Android nativo

`app/build.gradle(.kts)` (`targetSdk`, `compileSdk`, `versionCode`, `signingConfigs`, `ndkVersion`), `app/src/main/AndroidManifest.xml`, `gradle/libs.versions.toml` (AGP). Compilar: `./gradlew bundleRelease`.

## iOS nativo

`<App>.xcodeproj/project.pbxproj`:
- `IPHONEOS_DEPLOYMENT_TARGET`, `TARGETED_DEVICE_FAMILY`, `MARKETING_VERSION`, `CURRENT_PROJECT_VERSION`.
- **`INFOPLIST_KEY_NS…UsageDescription`**: con `GENERATE_INFOPLIST_FILE = YES`, los textos de uso viven aquí y no en Info.plist.

Además: `Info.plist`, `*.entitlements` (`com.apple.developer.applesignin`) y `PrivacyInfo.xcprivacy`.

## Editar `project.pbxproj` con seguridad

- Cambiar valores existentes (`IPHONEOS_DEPLOYMENT_TARGET = 12.0;` → `13.0;`) es seguro: hazlo en todas las configuraciones (Debug/Release/Profile) del target de la app.
- Añadir un archivo nuevo al target (PrivacyInfo.xcprivacy) requiere crear entradas `PBXFileReference`, `PBXBuildFile`, añadirlo al `PBXGroup` y a `PBXResourcesBuildPhase`, con IDs únicos de 24 caracteres hexadecimales. Hazlo solo si entiendes la estructura del archivo concreto. Si dudas, crea el archivo y deja el paso manual en el checklist ("Xcode → arrastra el archivo al grupo de la app → marca el target").
- Nunca reformatees el archivo entero.
