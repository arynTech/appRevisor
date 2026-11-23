# Reglas de Apple (App Store)

Fuentes oficiales consultadas el **2026-11-23**. Las App Store Review Guidelines indican "Last Updated: October 16, 2026".
Si hoy es más de 3 meses posterior a esa fecha, avisa en el informe de que conviene volver a comprobar las fuentes.

Formato de cada regla:
- **Exige**: qué pide Apple.
- **Comprobar**: dónde y cómo mirarlo en el proyecto (las rutas por framework están en `frameworks.md`).
- **Corregir**: qué cambiar. 🔧 = cambio seguro, se aplica sin preguntar. ✋ = pide confirmación antes.
- **Nivel** por defecto. Ajústalo si el contexto lo justifica y explica por qué.

Enlaces base:
- Guidelines: https://developer.apple.com/app-store/review/guidelines/
- Requisitos próximos/vigentes: https://developer.apple.com/news/upcoming-requirements/
- HIG: https://developer.apple.com/design/human-interface-guidelines/

## Índice
1. [Técnico](#1-técnico) · 2. [Permisos](#2-permisos) · 3. [Privacidad](#3-privacidad) · 4. [Cuentas y login](#4-cuentas-y-login) · 5. [Pagos](#5-pagos) · 6. [Contenido y funcionalidad](#6-contenido-y-funcionalidad) · 7. [Ficha de tienda](#7-ficha-de-tienda) · 8. [Accesibilidad y UI](#8-accesibilidad-y-ui) · 9. [Tablas de apoyo](#9-tablas-de-apoyo)

---

## 1. Técnico

### A-TEC-01 · Xcode y SDK mínimos
- **Exige**: desde el 2026-04-28, todo lo que se sube a App Store Connect debe compilarse con **Xcode 26 o posterior** y el **SDK de iOS 26 / iPadOS 26**.
- **Comprobar**: configuración de CI (`eas.json` → `build.*.ios.image`, `codemagic.yaml`, `.github/workflows/*` → `xcode-version`, `.xcode-version`), versión del framework (Expo SDK, Flutter, RN, Capacitor) y si esa versión soporta Xcode 26 según sus notas de versión.
- **Corregir**: compilar con Xcode 26+. En EAS, imagen de build reciente. ✋ Si el framework es demasiado antiguo para Xcode 26, propón actualizarlo (cambio de versión mayor).
- **Nivel**: BLOQUEANTE.
- **Fuente**: [Upcoming requirements](https://developer.apple.com/news/upcoming-requirements/) · consultado 2026-11-23.

### A-TEC-02 · Deployment target mínimo iOS 13
- **Exige**: desde el 2026-09-09, las apps iOS/iPadOS subidas deben tener como objetivo **iOS 13 o posterior**.
- **Comprobar**: `IPHONEOS_DEPLOYMENT_TARGET` en `*.xcodeproj/project.pbxproj`, `platform :ios, 'X'` en `Podfile`, `expo-build-properties` → `ios.deploymentTarget`.
- **Corregir**: 🔧 subir a ≥ 13.0 (o al mínimo que exija el framework, si es mayor). Mantén Podfile y pbxproj coherentes.
- **Nivel**: BLOQUEANTE.
- **Fuente**: [Upcoming requirements](https://developer.apple.com/news/upcoming-requirements/) · consultado 2026-11-23.

### A-TEC-03 · Solo APIs públicas (2.5.1)
- **Exige**: usar únicamente APIs públicas, para su propósito previsto, y funcionar en el iOS que se distribuye actualmente.
- **Comprobar**: en código nativo (`.swift`, `.m`, `.mm`) busca `LSApplicationWorkspace`, `UIGetScreenImage`, `PrivateFrameworks`, `NSSelectorFromString(@"_…")`, `valueForKey:@"_…"`, `dlopen` de frameworks del sistema no públicos. Revisa también plugins nativos locales.
- **Corregir**: ✋ sustituir por la API pública equivalente o eliminar la función.
- **Nivel**: BLOQUEANTE.
- **Fuente**: [Guideline 2.5.1](https://developer.apple.com/app-store/review/guidelines/#software-requirements) · consultado 2026-11-23.

### A-TEC-04 · Código autocontenido (2.5.2)
- **Exige**: la app no puede leer/escribir fuera de su contenedor ni descargar o ejecutar código que cambie sus funciones o características.
- **Comprobar**: OTA (`expo-updates`, CodePush, Shorebird, Capgo/Appflow live updates), `eval` de scripts remotos, carga de bundles JS desde URL remota en producción.
- **Corregir**: las OTA que solo corrigen errores son práctica habitual; si se usan para añadir funciones nuevas sin revisión, ✋ avisa. No cambies la configuración OTA sin confirmar.
- **Nivel**: RIESGO.
- **Fuente**: [Guideline 2.5.2](https://developer.apple.com/app-store/review/guidelines/#software-requirements) · consultado 2026-11-23.

### A-TEC-05 · Funcionamiento en redes solo IPv6 (2.5.5)
- **Exige**: la app debe funcionar completamente en redes IPv6-only.
- **Comprobar**: IPs literales en URLs (`https?://\d+\.\d+\.\d+\.\d+`), `localhost`, `10.0.2.2`, `127.0.0.1` en configuración de producción, sockets con `AF_INET` sin `AF_INET6`, `inet_addr`, `gethostbyname`.
- **Corregir**: 🔧 sustituir IPs por nombres de dominio si el dominio está claro en el proyecto (p. ej. en `.env.production`); si no, ✋ pide el dominio. Usar `URLSession`/Network.framework o el cliente HTTP del framework. Para probar: Mac con "Compartir Internet" → "Crear red NAT64".
- **Nivel**: BLOQUEANTE si hay IP literal en producción; si no, nada que reportar.
- **Fuente**: [Guideline 2.5.5](https://developer.apple.com/app-store/review/guidelines/#software-requirements) · consultado 2026-11-23.

### A-TEC-06 · Sin crashes ni errores evidentes (2.1)
- **Exige**: las apps que se cierran o muestran problemas técnicos obvios se rechazan. Hay que probar en dispositivo real y tener el backend activo durante la revisión.
- **Comprobar**: compila y arranca si puedes. Causas típicas de crash al arrancar: falta una clave NS*UsageDescription para un recurso que se pide (crash inmediato), falta `GoogleService-Info.plist`, variables de entorno vacías en release, URLs a `localhost`, `fatalError`/`!` en el arranque, fuentes o assets no incluidos.
- **Corregir**: 🔧 claves de Info.plist ausentes y configuración evidente; ✋ cambios de lógica.
- **Nivel**: BLOQUEANTE.
- **Fuente**: [Guideline 2.1](https://developer.apple.com/app-store/review/guidelines/#app-completeness) · consultado 2026-11-23.

### A-TEC-07 · Modos en segundo plano solo para su fin (2.5.4)
- **Exige**: `UIBackgroundModes` solo para su propósito (audio, ubicación, VoIP, finalización de tareas, notificaciones…).
- **Comprobar**: `UIBackgroundModes` en Info.plist / `expo.ios.infoPlist` / `expo.ios.backgroundModes` frente al código. Ej.: `location` declarado sin seguimiento en segundo plano real; `audio` sin reproducción en segundo plano.
- **Corregir**: 🔧 quitar los modos que no se usan. ✋ si sí se usan, documentarlo en las notas para el revisor.
- **Nivel**: RIESGO.
- **Fuente**: [Guideline 2.5.4](https://developer.apple.com/app-store/review/guidelines/#software-requirements) · consultado 2026-11-23.

### A-TEC-08 · Declaración de cifrado
- **Exige**: App Store Connect pregunta por el uso de cifrado en cada build salvo que esté declarado en Info.plist.
- **Comprobar**: clave `ITSAppUsesNonExemptEncryption` (aparece en la lista oficial de claves de Info.plist).
- **Corregir**: ✋ es una declaración de cumplimiento de exportación que firma el usuario, así que no la añadas por tu cuenta. Si la app parece usar solo HTTPS o el cifrado del sistema, propón `ITSAppUsesNonExemptEncryption = false` y pide al usuario que confirme que no hay cifrado propio ni librerías criptográficas adicionales.
- **Nivel**: MEJORA.
- **Fuente**: [Protected resources / claves Info.plist](https://developer.apple.com/documentation/bundleresources/protected-resources) · consultado 2026-11-23.

> 64 bits: en iOS no aplica como regla aparte (todas las builds actuales son arm64).

---

## 2. Permisos

### A-PER-01 · Texto de uso para cada recurso protegido (5.1.1(ii))
- **Exige**: cada recurso protegido que la app solicita necesita su clave de descripción en Info.plist; el texto debe explicar claramente el uso. Sin la clave, iOS cierra la app al pedir el permiso.
- **Comprobar**: cruza dependencias y código (cámara, fotos, ubicación, micrófono, contactos, calendario, Bluetooth, Face ID, movimiento, voz, salud, tracking, red local, NFC) con las claves presentes. Tabla en [9.1](#91-recursos-protegidos-y-clave-de-infoplist). Ojo: algunas librerías piden permisos aunque no uses la función (p. ej. `image_picker` necesita fotos y cámara si se usa la cámara).
- **Corregir**: 🔧 añadir la clave con un texto concreto (plantilla en A-PER-02). En Expo, en `expo.ios.infoPlist` o en la opción del plugin correspondiente.
- **Nivel**: BLOQUEANTE.
- **Fuente**: [Guideline 5.1.1](https://developer.apple.com/app-store/review/guidelines/#data-collection-and-storage) y [Protected resources](https://developer.apple.com/documentation/bundleresources/protected-resources) · consultado 2026-11-23.

### A-PER-02 · Textos de uso claros y específicos (5.1.1(ii))
- **Exige**: el texto debe describir claramente para qué se usa el dato.
- **Comprobar**: marca como insuficientes los textos de menos de ~25 caracteres, genéricos ("Necesitamos acceso", "Camera access", "This app needs…"), plantillas de librerías ("Allow $(PRODUCT_NAME) to access your camera"), o en un idioma distinto del de la app sin localizar.
- **Corregir**: 🔧 reescribir con esta plantilla: `«[Nombre] usa [recurso] para [función concreta], por ejemplo [ejemplo].»` Ej.: «MiClínica usa la cámara para que hagas una foto de tu tarjeta sanitaria y rellenar tus datos automáticamente.» Si la app tiene varios idiomas, localiza con `InfoPlist.strings` (nativo/Flutter/Capacitor) o `expo.locales`.
- **Nivel**: RIESGO.
- **Fuente**: [Guideline 5.1.1(ii)](https://developer.apple.com/app-store/review/guidelines/#data-collection-and-storage) · consultado 2026-11-23.

### A-PER-03 · Minimización de datos (5.1.1(iii))
- **Exige**: pedir solo datos relevantes para la función principal; usar el selector del sistema (PHPicker, selector de contactos, hoja de compartir) en lugar de acceso completo cuando sea posible.
- **Comprobar**: acceso completo a la fototeca solo para elegir una imagen; contactos completos para invitar a alguien; claves de permisos que ninguna parte del código usa.
- **Corregir**: 🔧 quitar claves de permisos sin uso. ✋ cambiar a selector del sistema si implica tocar lógica.
- **Nivel**: RIESGO.
- **Fuente**: [Guideline 5.1.1(iii)](https://developer.apple.com/app-store/review/guidelines/#data-collection-and-storage) · consultado 2026-11-23.

### A-PER-04 · Respetar la denegación (5.1.1(iv) y 5.1.2(i))
- **Exige**: respetar lo que el usuario decide, no forzar ni engañar para obtener permisos, ofrecer alternativa si se deniega (p. ej. escribir la dirección a mano) y no exigir notificaciones, ubicación o tracking para usar la app.
- **Comprobar**: pantallas que bloquean el uso hasta conceder un permiso ("Activa la ubicación para continuar"), pre-alertas con un único botón "Continuar" que fuerzan el diálogo, botones "Aceptar" engañosos antes de ATT.
- **Corregir**: ✋ añadir ruta alternativa y botón de cerrar/omitir.
- **Nivel**: RIESGO (BLOQUEANTE si la app queda inutilizable sin el permiso).
- **Fuente**: [Guidelines 5.1.1(iv), 5.1.2(i)](https://developer.apple.com/app-store/review/guidelines/#privacy) · consultado 2026-11-23.

---

## 3. Privacidad

### A-PRI-01 · Política de privacidad en la ficha y dentro de la app (5.1.1(i))
- **Exige**: enlace a la política en el campo de App Store Connect **y** accesible dentro de la app de forma sencilla. La URL de política es obligatoria para apps iOS.
- **Comprobar**: busca `privacy`, `privacidad`, `privacy-policy` en pantallas de ajustes, registro, login y "Acerca de". Debe ser un enlace que se abre, no solo texto.
- **Corregir**: 🔧 añadir una fila "Política de privacidad" en Ajustes/Perfil y un enlace en la pantalla de registro, leyendo la URL de una constante única (`PRIVACY_POLICY_URL`). Si no conoces la URL real, ✋ pídela: **nunca inventes una URL ni dejes un placeholder** (eso es motivo de rechazo 2.1).
- **Nivel**: BLOQUEANTE.
- **Fuente**: [Guideline 5.1.1(i)](https://developer.apple.com/app-store/review/guidelines/#data-collection-and-storage) y [App information](https://developer.apple.com/help/app-store-connect/reference/app-information) · consultado 2026-11-23.

### A-PRI-02 · Contenido de la política (5.1.1(i))
- **Exige**: qué datos se recogen, cómo y para qué; terceros con los que se comparten (analítica, publicidad, SDK) y que ofrecen igual protección; retención y borrado; cómo retirar el consentimiento o pedir el borrado.
- **Comprobar**: si la política está en el repo (web estática, markdown), revísala contra los SDK detectados. Si es una URL externa, añade al checklist que el usuario la revise.
- **Corregir**: ✋ proponer texto de las secciones que faltan (no publicar nada sin confirmar).
- **Nivel**: RIESGO.
- **Fuente**: [Guideline 5.1.1(i)](https://developer.apple.com/app-store/review/guidelines/#data-collection-and-storage) · consultado 2026-11-23.

### A-PRI-03 · Privacy manifest con Required Reason APIs
- **Exige**: desde el 2024-05-01, si el código de la app o de sus SDK usa una API de "motivo requerido", el `PrivacyInfo.xcprivacy` debe declarar la categoría y un motivo aprobado. Si falta, la subida se rechaza.
- **Comprobar**:
  1. ¿Existe `PrivacyInfo.xcprivacy` en el target de la app (o `expo.ios.privacyManifests` en Expo)? En proyectos nativos, comprueba que el archivo figura en `project.pbxproj` (si no está en el target, no cuenta).
  2. Uso de APIs de la tabla [9.2](#92-required-reason-apis) en código nativo propio.
  3. React Native/Expo usan internamente `UserDefaults`, marcas de tiempo de archivo y tiempo de arranque: como mínimo suelen necesitar `CA92.1`, `C617.1` y `35F9.1` (orientativo; confirma con el informe de privacidad de Xcode: *Product → Archive → Generate Privacy Report*).
- **Corregir**: 🔧 crear/completar el manifest:
  ```xml
  <?xml version="1.0" encoding="UTF-8"?>
  <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
  <plist version="1.0"><dict>
    <key>NSPrivacyTracking</key><false/>
    <key>NSPrivacyTrackingDomains</key><array/>
    <key>NSPrivacyCollectedDataTypes</key><array/>
    <key>NSPrivacyAccessedAPITypes</key><array>
      <dict>
        <key>NSPrivacyAccessedAPIType</key><string>NSPrivacyAccessedAPICategoryUserDefaults</string>
        <key>NSPrivacyAccessedAPITypeReasons</key><array><string>CA92.1</string></array>
      </dict>
    </array>
  </dict></plist>
  ```
  En Expo: `expo.ios.privacyManifests.NSPrivacyAccessedAPITypes` en `app.json`. En Flutter/Capacitor/nativo: archivo en `ios/Runner/` o `ios/App/App/` **y** añadido al target. Si no puedes editar `project.pbxproj` con seguridad, crea el archivo y deja en el checklist: "Xcode → arrastrar PrivacyInfo.xcprivacy al grupo de la app → marcar el target".
- **Nivel**: BLOQUEANTE.
- **Fuente**: [Upcoming requirements](https://developer.apple.com/news/upcoming-requirements/), [Privacy manifest files](https://developer.apple.com/documentation/bundleresources/privacy-manifest-files), [Describing use of required reason API](https://developer.apple.com/documentation/bundleresources/describing-use-of-required-reason-api) · consultado 2026-11-23.

### A-PRI-04 · SDK de terceros con manifest y firma
- **Exige**: si la app incluye un SDK de la lista de Apple (cualquier versión, o un SDK que lo reempaquete), ese SDK debe traer su privacy manifest y, si es binario, firma. Aplica a apps nuevas y a actualizaciones que añaden el SDK.
- **Comprobar**: compara dependencias con la lista de [9.3](#93-sdk-que-exigen-manifest-y-firma). Versiones antiguas de esas librerías no incluyen manifest.
- **Corregir**: ✋ actualizar esas dependencias a versiones que incluyan manifest (suele ser una subida menor; si es mayor, pide confirmación).
- **Nivel**: BLOQUEANTE si la versión instalada no trae manifest; si no puedes saberlo, RIESGO.
- **Fuente**: [Third-party SDK requirements](https://developer.apple.com/support/third-party-SDK-requirements/) · consultado 2026-11-23.

### A-PRI-05 · Etiquetas de privacidad (App Privacy) coherentes
- **Exige**: declarar en App Store Connect los datos que recoges tú **o tus SDK**, su finalidad, si se vinculan a la identidad y si se usan para tracking. "Recoger" = sacar datos del dispositivo y conservarlos más allá de atender la petición en tiempo real.
- **Comprobar**: no se ve en el código. Genera la propuesta a partir de los SDK detectados (`sdks.md`) y de los datos que envía la app a su backend.
- **Corregir**: checklist manual con la tabla de tipos de dato y finalidades propuestas.
- **Nivel**: BLOQUEANTE (no se puede enviar sin completarlo; incoherencias provocan rechazo).
- **Fuente**: [App privacy details](https://developer.apple.com/app-store/app-privacy-details/) · consultado 2026-11-23.

### A-PRI-06 · App Tracking Transparency (5.1.2(i))
- **Exige**: si la app recoge datos y los comparte con otras empresas para rastrear al usuario entre apps y webs (publicidad dirigida, medición de anuncios, data brokers), debe pedir permiso con ATT antes de rastrear. Incluir un SDK que lo hace cuenta aunque tú no uses los anuncios.
- **Comprobar**: SDK de publicidad/atribución (`sdks.md`: AdMob, Meta, AppsFlyer, Adjust, Branch…), uso de IDFA; presencia de `NSUserTrackingUsageDescription` y de la llamada `requestTrackingAuthorization` (o `expo-tracking-transparency`, `app_tracking_transparency`). Revisa `NSPrivacyTracking` y `NSPrivacyTrackingDomains` del manifest.
- **Corregir**:
  - 🔧 añadir `NSUserTrackingUsageDescription` con texto claro y poner `NSPrivacyTracking=true` con los dominios si el tracking existe.
  - ✋ añadir la petición ATT antes de inicializar el SDK (toca lógica de arranque).
  - Si se muestra el diálogo ATT pero no hay tracking, quítalo: la incoherencia con App Privacy provoca rechazos.
- **Nivel**: BLOQUEANTE si hay tracking sin ATT.
- **Fuente**: [Guideline 5.1.2(i)](https://developer.apple.com/app-store/review/guidelines/#data-use-and-sharing), [AppTrackingTransparency](https://developer.apple.com/documentation/apptrackingtransparency) · consultado 2026-11-23.

### A-PRI-07 · Borrado de cuenta desde la app (5.1.1(v))
- **Exige**: si la app permite crear cuenta, debe permitir **iniciar el borrado de la cuenta dentro de la app**. Requisitos:
  - Fácil de encontrar (normalmente en ajustes de cuenta).
  - Borrar el registro de la cuenta y los datos personales asociados; desactivar o "congelar" no basta.
  - Si hay que terminar en web, enlace directo a la página de borrado.
  - Informar si tarda, qué datos se conservan por ley y cómo afecta a las suscripciones (la facturación sigue en Apple: enlazar a gestionar suscripciones).
  - Confirmación o reautenticación sí; obstáculos innecesarios no. "Escríbenos a soporte" no vale salvo sectores muy regulados.
  - Con Sign in with Apple: revocar tokens mediante la REST API.
  - Aplica también a cuentas de invitado o creadas automáticamente, y en todos los países.
- **Comprobar**: ¿hay registro? (`signUp`, `register`, `createUserWithEmailAndPassword`, pantallas "Crear cuenta", login social que crea cuenta). ¿Hay opción "Eliminar cuenta"? ¿Hay endpoint o SDK claro para borrar (`DELETE /users/me`, `deleteAccount()`, Firebase `user.delete()`, Supabase función de borrado)?
- **Corregir**:
  - 🔧 si hay backend claro: botón "Eliminar cuenta" en ajustes → pantalla de confirmación que explica las consecuencias → llamada al endpoint → cerrar sesión, borrar tokens y datos locales (almacén seguro, caché) y volver al inicio.
  - Usa el cliente autenticado que ya existe. El borrado solo debe afectar a la cuenta del usuario con sesión iniciada: no pases IDs de usuario desde la UI ni crees endpoints nuevos. No llames al endpoint para probarlo.
  - Firebase `user.delete()` borra la autenticación pero no los datos de Firestore/Storage: avísalo y propón borrarlos también.
  - ✋ si no hay endpoint: crea la UI con el enlace web de borrado (si existe) y deja pendiente el backend en el checklist.
- **Nivel**: BLOQUEANTE.
- **Fuente**: [Guideline 5.1.1(v)](https://developer.apple.com/app-store/review/guidelines/#data-collection-and-storage), [Offering account deletion in your app](https://developer.apple.com/support/offering-account-deletion-in-your-app/) · consultado 2026-11-23.

### A-PRI-08 · No exigir cuenta sin motivo (5.1.1(v))
- **Exige**: si la app no tiene funciones importantes ligadas a cuenta, debe poder usarse sin iniciar sesión; no pedir datos personales salvo que sean esenciales o legalmente necesarios.
- **Comprobar**: login obligatorio en la primera pantalla de un catálogo, calculadora, contenido público…
- **Corregir**: ✋ proponer modo invitado.
- **Nivel**: RIESGO.
- **Fuente**: [Guideline 5.1.1(v)](https://developer.apple.com/app-store/review/guidelines/#data-collection-and-storage) · consultado 2026-11-23.

### A-PRI-09 · Apps para niños (1.3, 5.1.4)
- **Exige**: cuidado especial con datos de menores; las apps dirigidas a niños no deben incluir analítica ni publicidad de terceros (salvo excepciones limitadas); las apps fuera de la categoría Niños no pueden usar términos que sugieran que el público son niños.
- **Comprobar**: público objetivo declarado, textos "para niños", SDK de anuncios/analítica.
- **Corregir**: ✋ quitar SDK o cambiar el posicionamiento.
- **Nivel**: BLOQUEANTE si es app infantil con SDK de anuncios/analítica.
- **Fuente**: [Guideline 5.1.4](https://developer.apple.com/app-store/review/guidelines/#kids) · consultado 2026-11-23.

---

## 4. Cuentas y login

### A-LOG-01 · Opción de login equivalente: Sign in with Apple (4.8)
- **Exige**: si la cuenta principal se crea o autentica con un login de terceros o social (Google, Facebook, X, LinkedIn, Amazon, WeChat…), la app debe ofrecer **otra opción** que:
  1. Limite los datos a nombre y email.
  2. Permita ocultar el email.
  3. No recoja interacciones para publicidad sin consentimiento.

  Sign in with Apple cumple los tres requisitos.
- **Excepciones**:
  - La app solo usa el sistema de cuentas propio de la empresa (email/contraseña propio).
  - Es una app educativa, empresarial o de negocio que exige una cuenta existente.
  - Usa una identificación ciudadana o e-ID.
  - Es cliente de un servicio concreto de un tercero (p. ej. un cliente de Gmail).
  - Es un marketplace alternativo con su propio login.
- **Comprobar**: dependencias de login social (`sdks.md`) y llamadas (`GoogleSignin.signIn`, `signInWithGoogle`, `GoogleAuthProvider`, `FacebookAuth`, `LoginManager`), frente a dependencias y llamadas de Apple (`expo-apple-authentication`, `@invertase/react-native-apple-authentication`, `sign_in_with_apple`, `@capacitor-community/apple-sign-in`, `ASAuthorizationAppleIDProvider`) y el entitlement `com.apple.developer.applesignin` (en Expo, `ios.usesAppleSignIn: true`).
- **Corregir**: ✋ siempre con confirmación (toca login y backend). Propuesta:
  1. Librería según framework.
  2. Botón "Continuar con Apple" con el estilo oficial, a la misma altura que Google.
  3. Capability/entitlement.
  4. Validación del token en el backend.
  5. Revocación de tokens al borrar la cuenta.

  Alternativa válida: otro login que cumpla los 3 criterios.
- **Nivel**: BLOQUEANTE.
- **Fuente**: [Guideline 4.8](https://developer.apple.com/app-store/review/guidelines/#login-services) · consultado 2026-11-23.

### A-LOG-02 · Cuenta demo y backend activo (2.1(a))
- **Exige**: si hay login, incluir los datos de una cuenta demo en App Review Information y tener el backend encendido. Un modo demo integrado solo con aprobación previa de Apple y mostrando todas las funciones.
- **Comprobar**: no se ve en el código. Detecta si hay login, 2FA/OTP por SMS, verificación por email o funciones de pago que el revisor necesite ver.
- **Corregir**: checklist manual con la plantilla de notas en inglés. La cuenta no debe caducar ni pedir OTP; si hay pagos, debe tener acceso a las funciones premium o explicar cómo probar el IAP en sandbox.
- **Nivel**: BLOQUEANTE.
- **Fuente**: [Guideline 2.1](https://developer.apple.com/app-store/review/guidelines/#app-completeness) · consultado 2026-11-23.

### A-LOG-03 · Revocar credenciales sociales desde la app (5.1.1(v))
- **Exige**: las credenciales de redes sociales deben poder revocarse desde la app (desconectar la cuenta).
- **Comprobar**: cierre de sesión que no llama a `signOut`/`revokeAccess` del proveedor.
- **Corregir**: 🔧 llamar a `signOut()` del SDK al cerrar sesión; ✋ añadir "Desconectar Google" si implica cambios de backend.
- **Nivel**: MEJORA.
- **Fuente**: [Guideline 5.1.1(v)](https://developer.apple.com/app-store/review/guidelines/#data-collection-and-storage) · consultado 2026-11-23.

---

## 5. Pagos

Todos los cambios de esta sección son ✋: pide confirmación siempre.

### A-PAG-01 · Bienes digitales con In-App Purchase (3.1.1)
- **Exige**: desbloquear funciones o contenido digital (suscripciones, monedas, niveles, contenido premium, versión completa, propinas, tarjetas regalo digitales) debe hacerse con IAP. Tampoco valen claves de licencia, QR ni cripto como mecanismo de desbloqueo. Debe haber mecanismo de **restaurar compras** y los créditos no caducan.
- **Comprobar**: SDK de pago externo (Stripe, PayPal, Braintree, Redsys…) o URLs de checkout junto a palabras como "premium", "suscripción", "pro", "desbloquear"; campos para canjear códigos; ausencia de StoreKit/RevenueCat/`in_app_purchase`.
- **Corregir**: ✋ migrar a StoreKit (`react-native-iap`, `expo-iap`, `react-native-purchases`, `in_app_purchase`, `purchases_flutter`, `cordova-plugin-purchase`…) con productos creados en App Store Connect. Añadir botón "Restaurar compras".
- **Nivel**: BLOQUEANTE.
- **Fuente**: [Guideline 3.1.1](https://developer.apple.com/app-store/review/guidelines/#in-app-purchase) · consultado 2026-11-23.

### A-PAG-02 · Enlaces o botones a otros métodos de pago (3.1.1(a), 3.1.3)
- **Exige**:
  - **Escaparate de EE. UU.**: no hace falta entitlement para botones o enlaces externos de compra.
  - **Resto de países** (España/UE incluidos): la app y sus metadatos no pueden tener botones, enlaces ni llamadas a la acción hacia otros métodos de compra, salvo con un entitlement *StoreKit External Purchase Link* concedido para ese escaparate, o en las excepciones de 3.1.3.
  - Fuera de la app sí se puede comunicar con los usuarios sobre otros métodos.
- **Comprobar**: `Linking.openURL`/`launchUrl`/`window.open` hacia páginas de pago o de precios; textos "más barato en la web".
- **Corregir**: ✋ ocultar el enlace fuera de EE. UU. (por escaparate), solicitar el entitlement o pasar a IAP.
- **Nivel**: BLOQUEANTE si se distribuye fuera de EE. UU. sin entitlement.
- **Fuente**: [Guidelines 3.1.1(a) y 3.1.3](https://developer.apple.com/app-store/review/guidelines/#payments) · consultado 2026-11-23.

### A-PAG-03 · Bienes físicos y servicios fuera de la app (3.1.3(e)): **no usar IAP**
- **Exige**: los bienes físicos o servicios que se consumen fuera de la app deben cobrarse con métodos **distintos** de IAP (Apple Pay, tarjeta…). Ejemplos: tienda de ropa, comida a domicilio, reservas, turnos, citas, transporte, entradas.
- **Comprobar**: qué se vende realmente. No confundas "pago con tarjeta" con infracción.
- **Corregir**: nada. Si el revisor lo cuestiona, se explica en las notas.
- **Nivel**: no es hallazgo. Si la app usa IAP para bienes físicos, es BLOQUEANTE al revés.
- **Fuente**: [Guideline 3.1.3(e)](https://developer.apple.com/app-store/review/guidelines/#other-purchase-methods) · consultado 2026-11-23.

### A-PAG-04 · Otras excepciones (3.1.3)
- **(a) Apps "lectoras"** (revistas, libros, música, vídeo comprados fuera): pueden dar acceso; existe un entitlement *External Link Account*.
- **(b) Multiplataforma**: se puede dar acceso a lo comprado en otra plataforma si también se vende por IAP dentro de la app.
- **(c) Empresa**: ventas solo a organizaciones.
- **(d) Servicios persona a persona en tiempo real** (clases particulares, consultas, entrenador): otros métodos permitidos. Los servicios de uno a muchos van por IAP.
- **(f) Apps gratuitas complementarias** de herramientas web de pago (VoIP, almacenamiento, email, hosting): sin compras ni llamadas a la acción dentro de la app.
- **(g) Gestión de campañas publicitarias**.
- **Fuente**: [Guideline 3.1.3](https://developer.apple.com/app-store/review/guidelines/#other-purchase-methods) · consultado 2026-11-23.

### A-PAG-05 · Suscripciones (3.1.2)
- **Exige**: periodo mínimo de 7 días; valor continuado; funcionar en todos los dispositivos del usuario; antes de suscribirse, describir con claridad qué obtiene por el precio. No se pueden quitar funciones ya pagadas al pasar a suscripción.
- **Comprobar**: el paywall debe mostrar precio, periodo, renovación automática y cómo cancelar, más enlaces a Términos (EULA) y Política de privacidad (práctica habitual de revisión). También el botón "Restaurar compras".
- **Corregir**: ✋ completar el paywall (es UI de pagos).
- **Nivel**: RIESGO; BLOQUEANTE si no se ve el precio ni el periodo.
- **Fuente**: [Guideline 3.1.2](https://developer.apple.com/app-store/review/guidelines/#subscriptions) · consultado 2026-11-23.

### A-PAG-06 · IAP completos y visibles para el revisor (2.1(b))
- **Exige**: las compras in-app deben estar completas, visibles para el revisor y funcionar; si no se ven, explicarlo en las notas.
- **Corregir**: checklist (productos en estado "Listo para enviar" y adjuntos a la versión).
- **Nivel**: BLOQUEANTE.
- **Fuente**: [Guideline 2.1](https://developer.apple.com/app-store/review/guidelines/#app-completeness) · consultado 2026-11-23.

---

## 6. Contenido y funcionalidad

### A-CON-01 · Funcionalidad mínima: no "web envuelta" (4.2)
- **Exige**: la app debe ofrecer más que una web reempaquetada; si no es útil, única o "app-like", no tiene sitio en la App Store. Según 4.2.2, no debe ser principalmente marketing, anuncios, recortes web, agregador o colección de enlaces.
- **Comprobar**:
  - Capacitor/Cordova: `server.url` remoto en `capacitor.config.*` o `<content src="http…">` en `config.xml`.
  - RN/Flutter: la pantalla raíz es solo un `WebView`.
  - Pocas o ninguna funciones nativas: push, offline, cámara, biometría, widgets, compartir, notificaciones locales, almacenamiento local, navegación nativa.
  - Enlaces que abren el navegador para la mayoría de funciones.
- **Corregir**: ✋ propón un plan concreto con 3–5 funciones nativas que aporten valor real a esa app (no genéricas). Ejemplos:
  - Notificaciones push de estado de pedido.
  - Modo offline del catálogo.
  - Barra de pestañas nativa.
  - Login con Face ID.
  - Escaneo con cámara.
  - Widget o compartir nativo.

  Empaqueta la web en local (`webDir`) en lugar de `server.url`. Explica en las notas para el revisor qué hace la app que no hace la web.
- **Nivel**: BLOQUEANTE.
- **Fuente**: [Guideline 4.2](https://developer.apple.com/app-store/review/guidelines/#minimum-functionality) · consultado 2026-11-23.

### A-CON-02 · Sin placeholders ni contenido incompleto (2.1(a))
- **Exige**: envío final, metadatos completos, URLs que funcionan; sin texto de relleno ni webs vacías.
- **Comprobar**: `lorem ipsum`, `TODO`, `FIXME`, "Próximamente", "Coming soon", "En construcción", `placeholder`, datos de prueba (`test@test.com`, "Usuario Prueba"), botones sin acción (`onPress={() => {}}`, `onPressed: null`, `href="#"`), pantallas vacías, imágenes de stock con marca de agua.
- **Corregir**: ✋ el texto real lo decide el usuario; 🔧 puedes ocultar elementos claramente sin implementar (botones vacíos) si no rompen la navegación, y lo indicas en el informe.
- **Nivel**: BLOQUEANTE si es visible para el usuario; MEJORA si solo está en comentarios.
- **Fuente**: [Guideline 2.1](https://developer.apple.com/app-store/review/guidelines/#app-completeness) · consultado 2026-11-23.

### A-CON-03 · Contenido generado por usuarios (1.2)
- **Exige**: si hay contenido de usuarios o funciones sociales:
  - (a) filtro de material inapropiado antes de publicarse;
  - (b) mecanismo para denunciar contenido, con respuesta rápida;
  - (c) bloqueo de usuarios abusivos;
  - (d) información de contacto publicada.

  En apps de creadores (1.2.1), mecanismo de restricción por edad.
- **Comprobar**: chats, comentarios, perfiles públicos, subida de fotos o vídeos, publicaciones, reseñas; busca `report`/`denunciar`/`reportar` y `block`/`bloquear`. Unos términos de uso (EULA) aceptados en el registro ayudan a cumplir (a).
- **Corregir**: ✋ añadir "Denunciar" y "Bloquear usuario" en el menú de cada contenido o perfil, endpoint o cola de moderación, aceptación de términos en el registro y email de contacto visible.
- **Nivel**: BLOQUEANTE.
- **Fuente**: [Guideline 1.2](https://developer.apple.com/app-store/review/guidelines/#user-generated-content) · consultado 2026-11-23.

### A-CON-04 · Clasificación por edades (2.3.6)
- **Exige**: responder con honestidad el cuestionario. Desde el 2026-01-31 rige el nuevo sistema: **4+, 9+, 13+, 16+, 18+**; una app "Unrated" no se publica. El cuestionario incluye:
  - Controles: control parental, verificación de edad.
  - Capacidades: acceso web sin restricciones, contenido de usuarios, redes sociales, mensajería/chat, ubicación compartida, publicidad.
  - Temas maduros, información médica o de bienestar, sexualidad o desnudez, violencia, apuestas, apuestas simuladas, concursos y loot boxes.
- **Comprobar**: deduce las respuestas del código (WebView con navegación libre → acceso web sin restricciones; chat → mensajería; anuncios → publicidad).
- **Corregir**: checklist manual con las respuestas propuestas y la clasificación resultante estimada.
- **Nivel**: BLOQUEANTE si no está hecho; RIESGO si las respuestas no cuadran con la app.
- **Fuente**: [Guideline 2.3.6](https://developer.apple.com/app-store/review/guidelines/#accurate-metadata), [Age ratings values and definitions](https://developer.apple.com/help/app-store-connect/reference/age-ratings-values-and-definitions), [Upcoming requirements](https://developer.apple.com/news/upcoming-requirements/) · consultado 2026-11-23.

### A-CON-05 · Spam y apps duplicadas (4.3)
- **Exige**: no publicar varias apps con distinto bundle ID que sean la misma, ni apps indistinguibles de lo que ya abunda (linternas, horóscopos, ligue… necesitan algo diferente).
- **Comprobar**: apps hechas con plantilla o "white label" con varios targets casi iguales.
- **Corregir**: ✋ consolidar en una app.
- **Nivel**: RIESGO.
- **Fuente**: [Guideline 4.3](https://developer.apple.com/app-store/review/guidelines/#spam) · consultado 2026-11-23.

### A-CON-06 · Petición de valoraciones con la API oficial (5.6.1)
- **Exige**: las peticiones de reseña deben usar la API proporcionada; no se permiten diálogos propios de valoración.
- **Comprobar**: diálogos propios "¿Te gusta la app? Valóranos" que abren la App Store, frente a `SKStoreReviewController`/`requestReview`, `expo-store-review`, `in_app_review`.
- **Corregir**: 🔧 sustituir por la API oficial si el cambio es local y evidente.
- **Nivel**: RIESGO.
- **Fuente**: [Guideline 5.6.1](https://developer.apple.com/app-store/review/guidelines/#developer-code-of-conduct) · consultado 2026-11-23.

### A-CON-07 · Navegación web con WebKit (2.5.6)
- **Exige**: las apps que navegan por la web deben usar WebKit (motores alternativos solo con entitlement en la UE y Japón).
- **Comprobar**: motores web empaquetados (GeckoView, Chromium embebido) en iOS.
- **Nivel**: BLOQUEANTE si aplica (raro).
- **Fuente**: [Guideline 2.5.6](https://developer.apple.com/app-store/review/guidelines/#software-requirements) · consultado 2026-11-23.

### A-CON-08 · Descargas adicionales al primer arranque (4.2.3)
- **Exige**: la app debe funcionar sola, sin requerir otra app instalada; si descarga recursos extra al iniciarse, debe indicar el tamaño y preguntar antes.
- **Comprobar**: descargas de paquetes de contenido en el primer arranque sin aviso.
- **Corregir**: ✋ añadir aviso con tamaño.
- **Nivel**: RIESGO.
- **Fuente**: [Guideline 4.2.3](https://developer.apple.com/app-store/review/guidelines/#minimum-functionality) · consultado 2026-11-23.

---

## 7. Ficha de tienda

### A-FIC-01 · Nombre, subtítulo, keywords y descripción (2.3.7)
- **Exige**:
  - Límites: nombre de 2 a 30 caracteres; subtítulo ≤ 30; keywords ≤ 100 bytes (cada palabra de más de 2 caracteres, sin repetir el nombre de la app ni de la empresa ni nombres de otras apps o empresas); descripción ≤ 4000; texto promocional ≤ 170; "Novedades" ≤ 4000 (obligatorio desde la segunda versión).
  - Sin relleno de keywords, marcas de terceros, nombres de apps populares ni precios en nombre, subtítulo o capturas.
- **Comprobar**: `fastlane/metadata/ios/**`, `store.config.json` (EAS Metadata) o lo que el usuario aporte. Cuenta caracteres.
- **Corregir**: 🔧 en archivos de metadatos del repo, recorta y limpia; si no hay archivos, propón los textos en el checklist.
- **Nivel**: BLOQUEANTE si supera límites; RIESGO si hay relleno.
- **Fuente**: [Guideline 2.3.7](https://developer.apple.com/app-store/review/guidelines/#accurate-metadata), [App information](https://developer.apple.com/help/app-store-connect/reference/app-information), [Platform version information](https://developer.apple.com/help/app-store-connect/reference/platform-version-information) · consultado 2026-11-23.

### A-FIC-02 · Sin menciones a otras plataformas (2.3.10)
- **Exige**: ni la app ni sus metadatos pueden incluir nombres, iconos o imágenes de otras plataformas móviles o tiendas alternativas (Android, Google Play, Play Store…), salvo funcionalidad interactiva aprobada.
- **Comprobar**: textos visibles en iOS ("Descárgala en Google Play", "también en Android"), badges de Google Play en la web empaquetada, capturas hechas en un Android, descripción.
- **Corregir**: 🔧 ocultar en iOS con condición de plataforma (`Platform.OS`, `Platform.isIOS`, `Capacitor.getPlatform()`) o eliminar el texto; en metadatos, borrarlo.
- **Nivel**: BLOQUEANTE si es visible en la build de iOS o en la ficha.
- **Fuente**: [Guideline 2.3.10](https://developer.apple.com/app-store/review/guidelines/#accurate-metadata) · consultado 2026-11-23.

### A-FIC-03 · Capturas de pantalla (2.3.3)
- **Exige**:
  - Las capturas muestran la app en uso, no solo portada, login o splash.
  - Entre 1 y 10 por tamaño de dispositivo, en .jpeg/.jpg/.png, sin canal alfa ni transparencias.
  - **iPhone obligatorio**: "iPhone with Dynamic Island (medium display)", a 1179×2556 o 1206×2622 (o en horizontal).
  - Además, si no aportas "Dynamic Island (large display)" (1260×2736, 1290×2796 o 1320×2868), es obligatorio "Face ID (large display)" (1284×2778 o 1242×2688).
  - **iPad**, obligatorio si la app funciona en iPad: 13", a 2064×2752 o 2048×2732.
  - Desde abril de 2027, las apps con SDK de iOS 27.1+ también necesitarán capturas de "iPhone Duo".
- **Comprobar**: carpeta de capturas en el repo (`fastlane/screenshots`, `store/`), con dimensiones (`python -c "from PIL import Image…"` o `file`). Captura hecha en Android o con marco de Android = A-FIC-02.
- **Corregir**: checklist. Las medidas proceden de la página oficial leída el 2026-11-23; confirma en App Store Connect al subir.
- **Nivel**: BLOQUEANTE (sin capturas obligatorias no se envía).
- **Fuente**: [Guideline 2.3.3](https://developer.apple.com/app-store/review/guidelines/#accurate-metadata), [Screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications) · consultado 2026-11-23.

### A-FIC-04 · Icono (2.3.8 y HIG)
- **Exige**:
  - 1024×1024 px para iOS/iPadOS (bitmap PNG o archivo de Icon Composer), cuadrado y sin máscara aplicada.
  - Adecuado para 4+ y parecido al nombre o a los demás iconos de la app.
  - Error de subida conocido: el icono de App Store no puede tener transparencia ni canal alfa (ITMS-90717). Este dato no aparece en las páginas consultadas.
- **Comprobar**: `Assets.xcassets/AppIcon.appiconset`, `expo.icon`, `flutter_launcher_icons`; tamaño y canal alfa.
- **Corregir**: 🔧 si hay alfa y Pillow ya está instalado, aplanar sobre el color de fondo del icono (guarda el original con otro nombre). No instales Pillow sin permiso; si no está, al checklist.
- **Nivel**: BLOQUEANTE si falta o tiene alfa.
- **Fuente**: [Guideline 2.3.8](https://developer.apple.com/app-store/review/guidelines/#accurate-metadata), [HIG App icons](https://developer.apple.com/design/human-interface-guidelines/app-icons) · consultado 2026-11-23.

### A-FIC-05 · URL de soporte y notas para el revisor (2.3.1, 2.1)
- **Exige**: URL de soporte obligatoria que lleve a información de contacto real; notas de revisión que describan funciones nuevas concretas (no genéricas); en apps con login, cuenta demo.
- **Corregir**: checklist con plantilla de notas en inglés.
- **Nivel**: BLOQUEANTE (URL de soporte); RIESGO (notas).
- **Fuente**: [Platform version information](https://developer.apple.com/help/app-store-connect/reference/platform-version-information), [Guideline 2.3.1](https://developer.apple.com/app-store/review/guidelines/#accurate-metadata) · consultado 2026-11-23.

---

## 8. Accesibilidad y UI

### A-UI-01 · Áreas táctiles mínimas
- **Exige** (HIG): tamaño de control por defecto de 44×44 pt en iOS/iPadOS (mínimo 28×28 pt); separación de unos 12 pt entre elementos con borde y unos 24 pt sin borde.
- **Comprobar**:
  - RN: `width`/`height` < 44 en `Pressable`/`Touchable*` sin `hitSlop`.
  - Flutter: `IconButton` con `constraints` pequeños o `visualDensity` compacta, `GestureDetector` en `SizedBox` < 44.
  - CSS (Capacitor): botones o enlaces con `height` < 44px.
- **Corregir**: 🔧 `hitSlop` (RN), `minimumSize: Size(44,44)`/`MaterialTapTargetSize.padded` (Flutter), `min-height:44px; min-width:44px` (CSS), siempre que no cambie el diseño visible.
- **Nivel**: MEJORA (RIESGO si hay controles críticos de 20 pt o menos).
- **Fuente**: [HIG Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility) · consultado 2026-11-23.

### A-UI-02 · Modo oscuro sin roturas
- **Exige** (HIG): soportar ambas apariencias con colores semánticos o del sistema; contraste mínimo de 4.5:1 (objetivo 7:1 para texto pequeño con colores propios); no ofrecer un ajuste de apariencia propio de la app que ignore el del sistema.
- **Comprobar**:
  - Texto con color fijo oscuro sobre fondo del sistema (que se vuelve negro), `StatusBar` fija.
  - Expo `userInterfaceStyle: "automatic"` sin tema oscuro implementado.
  - Flutter sin `darkTheme` pero con widgets del sistema.
  - Capacitor/CSS sin `prefers-color-scheme` y con `color-scheme` sin definir.
- **Corregir**: 🔧 si la app **no** implementa tema oscuro, fijar apariencia clara (`UIUserInterfaceStyle = Light`, Expo `userInterfaceStyle: "light"`, CSS `color-scheme: light`). Es seguro y evita textos invisibles. ✋ Implementar tema oscuro completo es un trabajo aparte.
- **Nivel**: RIESGO si hay texto ilegible; si no, MEJORA.
- **Fuente**: [HIG Dark Mode](https://developer.apple.com/design/human-interface-guidelines/dark-mode) · consultado 2026-11-23.

### A-UI-03 · Contraste, Dynamic Type y VoiceOver
- **Exige** (HIG):
  - Contraste de 4.5:1 en texto hasta 17 pt y de 3:1 en texto de 18 pt o más, o en negrita.
  - Permitir agrandar el texto al menos al 200 %; tamaño por defecto de 17 pt y mínimo de 11 pt en iOS.
  - Describir la interfaz para VoiceOver.
- **Comprobar**: tamaños de fuente < 11 pt, `allowFontScaling={false}` generalizado, `textScaleFactor: 1.0` forzado, iconos-botón sin `accessibilityLabel`/`Semantics`/`aria-label`.
- **Corregir**: 🔧 añadir etiquetas de accesibilidad a botones de icono; ✋ cambios de tipografía.
- **Nivel**: MEJORA.
- **Fuente**: [HIG Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility) · consultado 2026-11-23.

### A-UI-04 · Soporte de iPad si se declara (2.4.1)
- **Exige**: las apps de iPhone deberían funcionar en iPad siempre que sea posible. Si la app declara iPad (`TARGETED_DEVICE_FAMILY = "1,2"`, Expo `ios.supportsTablet: true`), el revisor la probará en iPad: el diseño no puede romperse y hacen falta capturas de 13".
- **Comprobar**: familia de dispositivos declarada, layouts con anchos fijos, orientaciones de iPad (`UISupportedInterfaceOrientations~ipad`), `UIRequiresFullScreen`.
- **Corregir**: si el usuario no quiere soporte de iPad, 🔧 `supportsTablet: false` / `TARGETED_DEVICE_FAMILY = 1` (la app seguirá ejecutándose en iPad en modo compatibilidad y no debe fallar); si sí lo quiere, ✋ ajustar layouts.
- **Nivel**: RIESGO (BLOQUEANTE si el layout en iPad está claramente roto).
- **Fuente**: [Guideline 2.4.1](https://developer.apple.com/app-store/review/guidelines/#hardware-compatibility) · consultado 2026-11-23.

---

## 9. Tablas de apoyo

### 9.1 Recursos protegidos y clave de Info.plist
Fuente: [Protected resources](https://developer.apple.com/documentation/bundleresources/protected-resources) · consultado 2026-11-23.

| Recurso | Clave | Señales en el proyecto |
|---|---|---|
| Cámara | `NSCameraUsageDescription` | expo-camera, expo-image-picker (cámara), react-native-vision-camera, image_picker, camera, mobile_scanner, @capacitor/camera, escáner QR |
| Fototeca (lectura) | `NSPhotoLibraryUsageDescription` | expo-image-picker, expo-media-library, image_picker, photo_manager, @capacitor/camera |
| Fototeca (solo añadir) | `NSPhotoLibraryAddUsageDescription` | guardar imágenes: expo-media-library, gal, image_gallery_saver |
| Ubicación en uso | `NSLocationWhenInUseUsageDescription` | expo-location, react-native-geolocation, geolocator, location, @capacitor/geolocation, mapas con "mi ubicación" |
| Ubicación siempre | `NSLocationAlwaysAndWhenInUseUsageDescription` | `requestBackgroundPermissionsAsync`, `Geolocator` en segundo plano, geofencing |
| Micrófono | `NSMicrophoneUsageDescription` | grabación de audio o vídeo con sonido, expo-av, record, speech |
| Contactos | `NSContactsUsageDescription` | expo-contacts, react-native-contacts, flutter_contacts |
| Calendario | `NSCalendarsFullAccessUsageDescription` / `NSCalendarsWriteOnlyAccessUsageDescription` | expo-calendar, device_calendar, add_2_calendar |
| Recordatorios | `NSRemindersFullAccessUsageDescription` | expo-calendar (recordatorios) |
| Bluetooth | `NSBluetoothAlwaysUsageDescription` | react-native-ble-plx, flutter_blue_plus, @capacitor-community/bluetooth-le |
| Face ID | `NSFaceIDUsageDescription` | expo-local-authentication, local_auth, react-native-biometrics, @capgo/capacitor-native-biometric |
| Movimiento | `NSMotionUsageDescription` | expo-sensors (podómetro), sensors_plus, pedometer |
| Reconocimiento de voz | `NSSpeechRecognitionUsageDescription` | @react-native-voice/voice, speech_to_text |
| Salud | `NSHealthShareUsageDescription` / `NSHealthUpdateUsageDescription` | react-native-health, health |
| Tracking | `NSUserTrackingUsageDescription` | expo-tracking-transparency, app_tracking_transparency, SDK de anuncios |
| Red local | `NSLocalNetworkUsageDescription` | descubrimiento LAN, Bonjour, Chromecast, depuración Flutter en local |
| NFC | `NFCReaderUsageDescription` | react-native-nfc-manager, nfc_manager |
| Biblioteca multimedia | `NSAppleMusicUsageDescription` | acceso a la biblioteca musical |
| Siri | `NSSiriUsageDescription` | intents de Siri |
| HomeKit | `NSHomeKitUsageDescription` | HomeKit |

Las claves `NSCalendarsUsageDescription`, `NSRemindersUsageDescription`, `NSLocationAlwaysUsageDescription` y `NSBluetoothPeripheralUsageDescription` están obsoletas. Mantenlas solo si el deployment target es antiguo y además pon la nueva.

### 9.2 Required Reason APIs
Fuente: [NSPrivacyAccessedAPIType](https://developer.apple.com/documentation/bundleresources/app-privacy-configuration/nsprivacyaccessedapitypes/nsprivacyaccessedapitype) · consultado 2026-11-23.

| Categoría (`NSPrivacyAccessedAPIType`) | APIs | Motivos |
|---|---|---|
| `NSPrivacyAccessedAPICategoryFileTimestamp` | `creationDate`, `modificationDate`, `fileModificationDate`, `contentModificationDateKey`, `creationDateKey`, `stat`, `fstat`, `fstatat`, `lstat`, `getattrlist*` | `DDA9.1` mostrar fechas al usuario (sin enviarlas fuera) · `C617.1` archivos del contenedor de la app, app group o CloudKit · `3B52.1` archivos que el usuario ha elegido · `0A2A.1` SDK envoltorio (solo SDK) |
| `NSPrivacyAccessedAPICategorySystemBootTime` | `systemUptime`, `mach_absolute_time()` | `35F9.1` medir tiempo entre eventos o temporizadores · `8FFB.1` calcular marcas de tiempo absolutas de eventos · `3D61.1` incluirlo en un informe de error que el usuario decide enviar |
| `NSPrivacyAccessedAPICategoryDiskSpace` | `volumeAvailableCapacity*Key`, `volumeTotalCapacityKey`, `systemFreeSize`, `systemSize`, `statfs`, `statvfs`, `fstatfs`, `fstatvfs`, `getattrlist*` | `85F4.1` mostrar el espacio al usuario · `E174.1` comprobar si hay espacio para escribir o liberar · `7D9E.1` informe de error enviado por el usuario · `B728.1` apps de investigación de salud |
| `NSPrivacyAccessedAPICategoryActiveKeyboards` | `activeInputModes` | `3EC4.1` app de teclado personalizado · `54BD.1` adaptar la UI a los teclados activos |
| `NSPrivacyAccessedAPICategoryUserDefaults` | `UserDefaults` / `NSUserDefaults` | `CA92.1` datos solo de la propia app · `1C8F.1` compartidos en un App Group · `C56D.1` SDK envoltorio (solo SDK) · `AC6B.1` configuración gestionada (MDM) |

Claves de nivel superior de `PrivacyInfo.xcprivacy`:
- `NSPrivacyTracking` (bool): si es `true`, hay que rellenar `NSPrivacyTrackingDomains`.
- `NSPrivacyTrackingDomains`: dominios de tracking; se bloquean si el usuario no da permiso ATT.
- `NSPrivacyCollectedDataTypes`: datos que se recogen.
- `NSPrivacyAccessedAPITypes`: APIs de la tabla anterior.

### 9.3 SDK que exigen manifest y firma
Fuente: [Third-party SDK requirements](https://developer.apple.com/support/third-party-SDK-requirements/) · consultado 2026-11-23.

- **Generales**: Abseil, AFNetworking, Alamofire, AppAuth, BoringSSL/openssl_grpc, Charts, DKImagePickerController, DKPhotoGallery, FMDB, GoogleDataTransport, GoogleSignIn, GoogleToolboxForMac, GoogleUtilities, grpcpp, GTMAppAuth, GTMSessionFetcher, IQKeyboardManager(Swift), Kingfisher, leveldb, Lottie, MBProgressHUD, nanopb, OpenSSL, OrderedSet, Promises, FBLPromises, Protobuf, Reachability, RealmSwift, RxCocoa, RxRelay, RxSwift, SDWebImage, SnapKit, Starscream, SVProgressHUD, SwiftyGif, SwiftyJSON, Toast, UnityFramework.
- **Meta**: FBAEMKit, FBSDKCoreKit, FBSDKCoreKit_Basics, FBSDKLoginKit, FBSDKShareKit.
- **Firebase**: FirebaseABTesting, FirebaseAuth, FirebaseCore, FirebaseCoreDiagnostics, FirebaseCoreExtension, FirebaseCoreInternal, FirebaseCrashlytics, FirebaseDynamicLinks, FirebaseFirestore, FirebaseInstallations, FirebaseMessaging, FirebaseRemoteConfig.
- **OneSignal**: OneSignal, OneSignalCore, OneSignalExtension, OneSignalOutcomes.
- **Frameworks multiplataforma**: Capacitor, Cordova, Flutter, hermes (React Native).
- **Plugins de Flutter**: connectivity_plus, device_info_plus, file_picker, flutter_inappwebview, flutter_local_notifications, fluttertoast, geolocator_apple, image_picker_ios, package_info, package_info_plus, path_provider, path_provider_ios, share_plus, shared_preferences_ios, sqflite, url_launcher, url_launcher_ios, video_player_avfoundation, wakelock, webview_flutter_wkwebview.
