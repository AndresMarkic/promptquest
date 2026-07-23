# Publicar PromptQuest en Google Play Store

Guía paso a paso para llevar el MVP a la tienda. El juego es 100% local (no recolecta
datos), lo que simplifica varios trámites.

> **Estado del entorno en esta máquina:** Godot 4.6.3 instalado y con los *export templates*
> 4.6.3 ya presentes. **Falta** instalar el Android SDK + JDK y crear el keystore (pasos 1–3).
> Hasta hacerlo no se puede generar el `.aab`.

---

## 0. Requisitos de entorno (una sola vez)

1. **JDK 17** (por ejemplo Temurin 17) y **Android Studio** (trae el Android SDK).
2. En Godot: `Editor → Editor Settings → Export → Android`, apuntar:
   - *Android SDK Path* a la carpeta del SDK (normalmente `%LOCALAPPDATA%\Android\Sdk`).
   - *Debug Keystore* (Godot puede generar el de debug solo).
3. Verificar en `Proyecto → Exportar → Android` que no haya advertencias en rojo.

## 1. Keystore de release (¡NO perderlo!)

El keystore firma la app. **Si lo perdés, no vas a poder actualizar la app nunca más.**

```bash
keytool -genkeypair -v -keystore promptquest.keystore \
  -alias promptquest -keyalg RSA -keysize 2048 -validity 10000
```

- Guardá `promptquest.keystore` y sus contraseñas **fuera del repositorio** (está en `.gitignore`).
- Hacé una copia de respaldo en un lugar seguro (gestor de contraseñas, disco externo).

## 2. Cuenta de desarrollador

- Crear cuenta en **Google Play Console** (pago único de USD 25).
- Para cuentas personales nuevas, Google exige un período de **prueba cerrada con testers**
  antes de poder publicar en producción. Verificá el requisito vigente al momento de publicar.

## 3. Configurar el preset de export

El proyecto incluye `export_presets.cfg` con un preset Android inicial. Abrí una vez el editor
(`"$GODOT_EXE" -e --path .`) → `Proyecto → Exportar → Android` y completá/verificá:

- **Unique Name:** `org.promptquest.game` (cambialo si querés otro dominio).
- **Nombre:** PromptQuest.
- **Version Code:** 1 (subilo en cada actualización: 2, 3, ...).
- **Version Name:** 0.1.0.
- **Formato:** **AAB** (Android App Bundle) para release; APK sirve para probar en un teléfono.
- **Keystore Release:** apuntar al `promptquest.keystore` del paso 1 con su alias y contraseñas.

## 4. Target API level

Google Play exige un **target API level mínimo vigente** (sube cada año). Los *export templates*
de Godot 4.6.3 ya apuntan a un target reciente; verificá el requisito actual de Google Play al
publicar y, si hace falta, actualizá Godot / los templates.

## 5. Generar el AAB

Con el SDK y el keystore configurados:

```bash
# Release firmado (AAB para la tienda) — requiere keystore de release configurado:
"$GODOT_EXE" --headless --path . --export-release Android export/promptquest.aab

# APK de debug para probar en un teléfono conectado:
"$GODOT_EXE" --headless --path . --export-debug Android export/promptquest-debug.apk
```

## 6. Ficha de la tienda (en ES y EN)

- **Título:** PromptQuest.
- **Descripción corta** (máx. 80 caracteres).
- **Descripción larga** (máx. 4000).
- **Ícono:** 512×512 (se puede partir de `assets/icon.png`, ampliándolo a 512 con borde).
- **Feature graphic:** 1024×500.
- **Capturas:** mínimo 2 por idioma (mapa, una lección, resultado, boss).

## 7. Política de privacidad

Obligatoria aunque no se recolecten datos. Alcanza una página simple (por ejemplo en un
Google Sites o GitHub Pages) que diga que la app **no recolecta ni comparte datos personales**
y guarda el progreso solo en el dispositivo. Pegá la URL en la Play Console.

## 8. Data safety y clasificación

- **Data safety:** declarar que **no se recolecta ni comparte ningún dato** (ventaja del diseño
  100% local).
- **Clasificación de contenido (IARC):** completar el cuestionario; la app es apta para todo
  público (contenido educativo, sin violencia).

---

## Checklist rápida antes de publicar

- [ ] Keystore de release creado y respaldado fuera del repo.
- [ ] Cuenta de Play Console activa (y prueba cerrada si corresponde).
- [ ] `export_presets.cfg` con package name, versión y formato AAB, firmado con el keystore.
- [ ] Target API level cumple el requisito vigente de Google Play.
- [ ] `.aab` generado sin errores.
- [ ] Ficha en ES y EN con ícono, feature graphic y capturas.
- [ ] URL de política de privacidad cargada.
- [ ] Formulario Data safety: "no se recolectan datos".
- [ ] Clasificación de contenido completada.
