# PromptQuest — Diseño del MVP

**Fecha:** 2026-07-17
**Estado:** Aprobado en conversación; pendiente de revisión final del documento escrito.
**Decisiones tomadas por el usuario:** arquitectura 100% local (opción A) · contenido ES+EN · primer árbol "Fundamentos de IA" · ambos tipos de ejercicio en el MVP · experiencia Godot del usuario: básica.

---

## 1. Visión

PromptQuest es un juego educativo 2D para Android (Godot 4) con la mecánica de progresión de Duolingo, pero que en vez de idiomas enseña a usar inteligencia artificial generativa, de cero a nivel profesional. A largo plazo cada modelo de IA (Claude, ChatGPT, Gemini, etc.) será un "idioma" con su propio árbol. El MVP construye el camino base común: **Fundamentos de IA**.

### Objetivos del MVP
- Un jugable completo de punta a punta: intro narrativa → mapa → lección → resultado → mapa.
- 1 unidad ("Fundamentos de IA") con 10 lecciones de contenido real, en español e inglés.
- 2 tipos de ejercicio funcionando: opción múltiple y armar-prompt con bloques.
- Economía completa: XP, vidas con regeneración, racha diaria, estrellas por lección.
- Corre en escritorio (desarrollo) y exporta a Android (objetivo Play Store).

### No-objetivos del MVP (explícitamente fuera de alcance)
- Backend, cuentas, sincronización entre dispositivos (decisión: 100% local).
- Ligas/leaderboard (ni siquiera con bots), notificaciones push, monetización, compras.
- Los otros 9 árboles de modelos de IA.
- Sandbox con llamadas reales a APIs de IA.
- Sistema de coronas multinivel (el MVP usa estrellas simples).
- Sonido más allá de efectos básicos (acierto/error/celebración).

---

## 2. Diseño de juego

### 2.1 Loop central
Sesiones de 3–5 minutos: en el **mapa** el jugador toca la siguiente lección desbloqueada → juega **8 ejercicios** en secuencia → ve la **pantalla de resultado** (XP, estrellas, reacción de la mascota) → vuelve al mapa con la siguiente lección desbloqueada.

### 2.2 Economía (constantes exactas)

| Constante | Valor |
|---|---|
| XP base por lección completada | 10 |
| XP extra por ejercicio respondido bien al primer intento | +1 |
| Bonus por lección sin errores | +5 |
| Corazones máximos | 5 |
| Costo por error | 1 corazón |
| Regeneración | 1 corazón cada 30 min (reloj local, se calcula por timestamp al abrir la app; no requiere que la app esté abierta) |
| Sin corazones | No se pueden iniciar lecciones nuevas; sí se puede **repasar** una lección completada, y completar un repaso recupera 1 corazón (máx. 1 recupero por repaso) |
| Racha | Se suma 1 al completar la primera lección (o repaso) del día. Si pasa un día calendario completo sin actividad, la racha vuelve a 0. Se evalúa con la fecha local |

**Estrellas por lección** (se guarda el mejor resultado histórico):
- ⭐ — completada.
- ⭐⭐ — completada sin errores.
- ⭐⭐⭐ — completada sin errores y en ≤ 3 minutos en total.

**Combo:** contador visual de respuestas correctas consecutivas dentro de la lección (3+, 5+, 8 muestran mensajes de ánimo). No otorga XP ni afecta la economía — es solo feedback.

**Quedarse sin corazones a mitad de lección:** la lección se interrumpe, se pierde el progreso de esa lección (no se descuenta nada más) y se vuelve al mapa con un mensaje de Byte sugiriendo repasar.

### 2.3 Desbloqueo
Las lecciones se desbloquean en orden estrictamente lineal: completar la lección N (≥⭐) desbloquea la N+1. La lección 10 (boss) requiere las 9 anteriores completadas.

### 2.4 Lección boss (lección 10)
- 12 ejercicios tomados del pool de las lecciones 1–9 (mezcla de ambos tipos), sin texto de introducción ni explicaciones previas.
- Cronómetro de 20 segundos por ejercicio; si se agota cuenta como error.
- Los errores cuestan corazones igual que siempre.
- Se aprueba con ≥ 9/12 correctas. Aprobar otorga XP doble (20 base) y marca la unidad como completada (pantalla de celebración especial).

---

## 3. Narrativa y mascota

**Byte** (nombre provisional): una pequeña IA que despierta en el Mundo Digital con la memoria fragmentada. Cada lección completada le devuelve un fragmento de conocimiento. La Zona 1 del mapa es **el Núcleo** (Fundamentos de IA); las zonas futuras serán los territorios de cada modelo.

En el MVP:
- **Intro:** 3 pantallas estáticas con texto + imagen simple, solo la primera vez que se abre el juego (flag `intro_seen` en el guardado). Se puede saltar.
- **Micro-diálogos:** 1 línea de Byte al empezar cada lección y 1 al terminar (definidas por lección en el JSON de contenido).
- **Expresiones:** 4 estados — neutral, feliz (acierto), triste (error), celebración (fin de lección/boss). Byte aparece en la pantalla de lección y en la de resultado.
- **Arte:** placeholder vectorial simple (formas geométricas con carácter), generado durante la implementación. Todo el arte se referencia por ruta, reemplazable sin tocar código.

---

## 4. Curriculum — Unidad 1: "Fundamentos de IA"

| # | Lección | Objetivo de aprendizaje |
|---|---|---|
| 1 | ¿Qué es la IA generativa? | Distinguir IA generativa de software tradicional; qué puede y no puede hacer |
| 2 | ¿Qué es un LLM? | Entender que es un modelo entrenado con texto; entrenamiento vs. uso |
| 3 | Tokens y contexto | Qué es un token; la ventana de contexto como "memoria de trabajo" limitada |
| 4 | Cómo "piensa" | Predicción de la siguiente palabra; por qué eso produce respuestas útiles y también errores |
| 5 | Alucinaciones | Reconocer cuándo la IA inventa; hábito de verificar datos importantes |
| 6 | Tu primer prompt | Instrucciones claras y específicas superan a las vagas |
| 7 | Contexto y rol | Dar contexto relevante y asignar un rol mejora la respuesta |
| 8 | Formato de salida | Pedir listas, tablas, pasos, longitud — controlar la forma de la respuesta |
| 9 | Enseñar con ejemplos | Few-shot: mostrar 1–2 ejemplos del resultado esperado |
| 10 | 👹 Boss del Núcleo | Repaso integrador cronometrado de las lecciones 1–9 |

Cada lección (1–9): **8 ejercicios**, mezclando los dos tipos (proporción orientativa 5 opción múltiple / 3 bloques; las lecciones 1–5, más conceptuales, pueden ser 6/2). El contenido completo de las 10 lecciones se escribe durante la implementación, en ES y EN, con revisión de exactitud técnica.

---

## 5. Arquitectura técnica

### 5.1 Plataforma
- **Godot 4.4+** (fijar la versión exacta al iniciar la implementación según lo instalado), proyecto 2D, renderer **Mobile**.
- Resolución base **720×1280 portrait**, stretch mode `canvas_items`, aspect `expand` (se adapta a cualquier pantalla).
- Lenguaje: GDScript. Código comentado en español (el usuario tiene nivel básico de Godot).
- Objetivo de exportación: Android (.aab para Play Store). Desarrollo y pruebas en escritorio Windows.

### 5.2 Estructura de carpetas

```
res://
├── project.godot
├── autoload/                  # Singletons (registrados en Project Settings)
│   ├── SaveData.gd            # persistencia local
│   ├── Economy.gd             # XP, corazones, racha, estrellas
│   ├── Content.gd             # carga y localiza el contenido JSON
│   └── Game.gd                # navegación entre pantallas
├── scenes/
│   ├── main/Main.tscn         # raíz: contiene la pantalla activa
│   ├── intro/IntroScreen.tscn
│   ├── map/MapScreen.tscn     # camino vertical con nodos de lección
│   ├── map/LessonNode.tscn    # botón de lección (estado: bloqueada/actual/completada + estrellas)
│   ├── lesson/LessonScreen.tscn  # encadena ejercicios, HUD, Byte
│   ├── exercises/
│   │   ├── ExerciseBase.gd    # clase base (contrato común)
│   │   ├── MultipleChoice.tscn/.gd
│   │   └── BlockBuilder.tscn/.gd
│   ├── ui/
│   │   ├── Hud.tscn           # corazones, barra de progreso, combo
│   │   ├── ResultScreen.tscn  # XP, estrellas, celebración
│   │   ├── DialogBox.tscn     # micro-diálogos de Byte
│   │   └── SettingsPanel.tscn # idioma ES/EN, sonido on/off
│   └── mascot/Mascot.tscn     # Byte + 4 expresiones
├── content/
│   └── unit1/lesson_01.json … lesson_10.json
├── i18n/ui.csv                # traducciones de UI (keys → es, en)
└── assets/                    # sprites, fuente, sonidos
```

### 5.3 Contratos de los módulos (interfaces)

- **`Content`**: `get_unit_lessons(unit: String) -> Array` (metadatos: id, título localizado, orden) · `get_lesson(id: String) -> Dictionary` (contenido ya localizado al idioma activo) · `set_language(code: String)`.
- **`Economy`**: `can_start_lesson() -> bool` · `on_answer(correct: bool)` · `on_lesson_finished(lesson_id, mistakes, seconds, is_review) -> Dictionary` (devuelve XP ganado y estrellas para la pantalla de resultado; internamente actualiza racha y guarda) · `hearts() -> int` · señal `hearts_changed`.
- **`SaveData`**: `get_value(key, default)` · `set_value(key, value)` · `persist()` (escribe `user://save.json`). Nadie más toca el disco.
- **`Game`**: `goto(screen: String, params: Dictionary)` — única forma de cambiar de pantalla.
- **`ExerciseBase`** (contrato de todo ejercicio): método `setup(data: Dictionary)` para recibir su JSON; señal `answered(correct: bool)` emitida exactamente una vez; la escena muestra su propio feedback (correcto/incorrecto + explicación) y luego emite `continue_pressed`. `LessonScreen` no conoce los tipos concretos: instancia por nombre de tipo y habla solo por el contrato.

Agregar un tipo de ejercicio nuevo = crear una escena que cumpla el contrato + usar su `type` en el JSON. Nada más se toca.

### 5.4 Esquema de contenido (JSON por lección)

```json
{
  "id": "u1l06",
  "title": { "es": "Tu primer prompt", "en": "Your first prompt" },
  "byte_intro": { "es": "…", "en": "…" },
  "byte_outro": { "es": "…", "en": "…" },
  "exercises": [
    {
      "type": "multiple_choice",
      "question": { "es": "¿Cuál de estos prompts es más claro?", "en": "…" },
      "options": [
        { "es": "Escribime algo sobre perros", "en": "…" },
        { "es": "Escribí 3 consejos breves para adiestrar a un cachorro", "en": "…" }
      ],
      "correct": 1,
      "explanation": { "es": "Un prompt específico define tema, cantidad y formato.", "en": "…" }
    },
    {
      "type": "block_builder",
      "goal": { "es": "Armá un prompt que pida una receta en 5 pasos", "en": "…" },
      "solution": {
        "es": ["Actuá como chef.", "Dame una receta de pasta", "en 5 pasos numerados."],
        "en": ["Act as a chef.", "Give me a pasta recipe", "in 5 numbered steps."]
      },
      "distractors": {
        "es": ["Hacé lo que quieras.", "no sé, algo rico"],
        "en": ["Do whatever.", "idk, something tasty"]
      },
      "explanation": { "es": "…", "en": "…" }
    }
  ]
}
```

Reglas: en `block_builder` se muestran los bloques de `solution` + `distractors` mezclados; la respuesta es correcta solo con los bloques de `solution` en su orden exacto. `correct` en `multiple_choice` es el índice (base 0). Todo texto visible al jugador lleva `es` y `en`; si falta un idioma, se usa el otro como fallback (nunca se crashea por contenido incompleto: se loguea una advertencia).

La lección 10 (boss) usa el mismo esquema con `"boss": true` y su pool de ejercicios propio dentro del archivo.

### 5.5 Esquema de guardado (`user://save.json`)

```json
{
  "version": 1,
  "language": "es",
  "xp_total": 0,
  "hearts": 5,
  "hearts_regen_unix": 0,
  "streak_days": 0,
  "last_activity_date": "",
  "lessons": { "u1l01": { "stars": 2 } },
  "intro_seen": false,
  "settings": { "sound": true }
}
```

`version` permite migrar el formato en el futuro. Si el archivo no existe o está corrupto, se arranca con valores por defecto (nunca se crashea por guardado inválido).

### 5.6 Internacionalización
- **UI** (botones, menús, mensajes fijos): claves en `i18n/ui.csv` cargado como Translation de Godot; los nodos usan `tr("KEY")`.
- **Contenido de lecciones**: campos `es`/`en` en el JSON, resueltos por `Content` según el idioma activo.
- Idioma inicial: el del sistema si es `es` o `en`; si no, `en`. Cambiable en ajustes; el cambio aplica en vivo.

---

## 6. Pantallas y flujo

```
[IntroScreen] → (solo 1ª vez, saltable)
[MapScreen] ──toca lección──▶ [LessonScreen] ──termina──▶ [ResultScreen] ──▶ [MapScreen]
     │                              │ sin corazones a mitad de lección
     │◀─────────────────────────────┘ (vuelve con mensaje de Byte)
     └── botón ⚙ → [SettingsPanel] (overlay)
```

- **MapScreen:** camino vertical scrolleable con 10 nodos; HUD superior fijo (🔥 racha, ❤️ corazones, ⚡ XP total). Nodo bloqueado (gris con candado), actual (resaltado y animado), completado (estrellas ganadas). Tocar un nodo completado ofrece "Repasar".
- **LessonScreen:** barra de progreso (ejercicio N/8), corazones, combo, Byte reaccionando a cada respuesta, botón salir (con confirmación: se pierde el progreso de la lección).
- **ResultScreen:** XP ganado (contador animado), estrellas, racha del día si corresponde, Byte celebrando, botón continuar.

---

## 7. Checklist Play Store (referencia para la fase de publicación)

1. Cuenta de desarrollador de Google Play (pago único de USD 25).
2. Exportar `.aab` firmado: keystore propio (guardarlo — perderlo = no poder actualizar la app), export templates de Android en Godot, Android SDK configurado.
3. **Target API level vigente** al momento de publicar (verificar el requisito actual de Google Play en ese momento; Godot 4.4+ lo cubre con sus export templates actualizados).
4. Ficha de la tienda en ES y EN: título, descripción corta (80) y larga (4000), ícono 512×512, feature graphic 1024×500, mínimo 2 capturas por idioma.
5. URL de política de privacidad (obligatoria aunque no se recolecten datos).
6. Formulario **Data safety**: declarar que no se recolecta ni comparte ningún dato (ventaja directa del diseño 100% local).
7. Cuestionario de clasificación de contenido (IARC) — apto para todo público / E.
8. Prueba cerrada con testers según los requisitos vigentes de Google Play para cuentas personales nuevas (verificar requisito al publicar).

---

## 8. Riesgos y notas

- **Exactitud del contenido:** las afirmaciones técnicas sobre IA (tokens, entrenamiento, alucinaciones) se revisan durante la escritura del contenido; se prefiere simplificar antes que afirmar algo incorrecto.
- **Versión de Godot:** hay rastros de instalación en la máquina (`AppData\Local\Godot`); al iniciar la implementación se verifica la versión instalada y se fija el proyecto a esa versión (mínimo 4.4).
- **Reloj local:** vidas y racha usan la hora del dispositivo; un usuario puede hacer trampa cambiando la hora. Aceptado para el MVP (sin backend no hay alternativa).
- **Migración futura a backend:** aunque se eligió 100% local, `SaveData` es el único módulo que toca disco, lo que deja un punto único de reemplazo si algún día se agrega sincronización.

---

## 9. Criterio de éxito del MVP

Un APK instalable en un teléfono Android donde una persona sin conocimientos previos puede: ver la intro, jugar las 10 lecciones de Fundamentos de IA en español o inglés, perder y regenerar corazones, mantener una racha de varios días, vencer al boss y ver la unidad completada — sin crashes y sin conexión a internet.
