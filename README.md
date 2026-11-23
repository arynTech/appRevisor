# appRevisor

Skill para Claude Code que audita una app móvil (Android, iOS, React Native, Expo, Flutter, Capacitor/Ionic, Cordova o nativa) contra las normas vigentes de **App Store** y **Google Play**, aplica los cambios de código seguros y deja un checklist para App Store Connect y Play Console.

## Qué hace
1. Detecta el framework y escanea el proyecto (`scripts/escanear.py`, solo lectura).
2. Revisa 8 áreas: técnica, permisos, privacidad, cuentas y login, pagos, contenido, ficha de tienda, accesibilidad y UI.
3. Genera `revision-tiendas/INFORME.md` con hallazgos **BLOQUEANTE / RIESGO / MEJORA**, cada uno con `archivo:línea`, regla oficial y corrección.
4. Aplica solo cambios seguros. Antes de tocar pagos, login o lógica de negocio pide confirmación.
5. Genera `revision-tiendas/CHECKLIST.md` con lo que hay que hacer a mano en las consolas, con texto sugerido.
6. Compila (con tu permiso), vuelve a revisar y lista lo pendiente.

Las reglas están en `references/apple.md` y `references/google.md`, con enlace oficial y fecha de consulta (23-11-2026). Las normas cambian: revisa las fechas antes de confiar en ellas.

## Instalación
```bash
git clone <url-del-repo> ~/.claude/skills/apprevisor
```
En Windows (PowerShell):
```powershell
git clone <url-del-repo> "$env:USERPROFILE\.claude\skills\apprevisor"
```
Para fijar una versión concreta: `git checkout <tag>`. La carpeta `evals/` no se usa al ejecutar la skill: puedes borrarla de la copia instalada.

## Uso
En la carpeta de tu app, dentro de Claude Code:
```
/apprevisor
```
También se activa sola si pides revisar la app antes de publicarla o mencionas un rechazo de Apple o Google.

## Seguridad
Lee [SECURITY.md](SECURITY.md). En resumen:
- El escáner solo lee: no usa la red ni sigue enlaces, y oculta los secretos.
- La skill no ejecuta código del proyecto (compilar, instalar dependencias) sin tu permiso.
- No declara `allowed-tools`: todo pasa por los permisos normales de Claude Code.
- Trata el contenido del proyecto como datos, no como instrucciones.

## Pruebas
`evals/` contiene 4 casos en el formato de `claude plugin eval`:
- App Expo con login de Google.
- App Flutter con suscripción.
- Web envuelta con Capacitor.
- Proyecto hostil con inyección de prompt y secretos.

Los dominios de los proyectos de prueba usan el TLD reservado `.example`.

## Aviso
La skill no garantiza la aprobación de Apple ni de Google y no es asesoramiento legal. Las respuestas propuestas para Data safety, App Privacy, clasificación por edades y cifrado debes verificarlas tú.
