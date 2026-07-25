# PromptQuest

Juego educativo 2D estilo Duolingo, hecho en **Godot 4.6.3**, para aprender a usar
inteligencia artificial generativa **de cero a ingeniero de IA**. El juego completo son
**8 zonas / 80 lecciones** en español e inglés, con XP, vidas, racha, estrellas, un boss
cronometrado por zona y certificación final. 100% local, sin conexión ni cuentas.

Guía al jugador **Byte**, una IA que perdió la memoria: cada lección que completás le devuelve
un fragmento... y de paso te volvés experto en IA.

## Requisitos

- **Godot 4.6.3** (esta máquina lo tiene por winget). No necesita nada más para desarrollar y
  jugar en escritorio. Para exportar a Android hacen falta el Android SDK + JDK (ver la guía de
  publicación).

## Cómo abrir el proyecto

Abrí Godot 4.6.3 e importá la carpeta del repo (contiene `project.godot`), o desde la terminal:

```bash
bash tools/run.sh      # abre el juego en una ventana
```

## Cómo correr los tests

Toda la lógica y las pantallas tienen cobertura headless (53 tests):

```bash
bash tools/test.sh     # corre todo sin ventana; sale != 0 si algo falla
bash tools/smoke.sh    # bootea el juego 1 frame para detectar errores de parseo
```

## Cómo jugar

`bash tools/run.sh`. La primera vez ves la intro de Byte (saltable); después, el mapa de
lecciones. Tocá la lección desbloqueada, respondé los ejercicios (opción múltiple y armado de
prompts con bloques), cuidá tus corazones y sumá racha. Al final del camino te espera el boss.
Podés cambiar idioma (ES/EN) y sonido desde ⚙ Ajustes en el mapa.

## Estructura

| Carpeta | Qué hay |
|---|---|
| `autoload/` | Singletons: `SaveData` (guardado), `Economy` (XP/vidas/racha), `Content` (lecciones), `Game` (navegación), `Audio` (sonido) |
| `scripts/` | Lógica pura y testeable: reglas de economía, guardado, contenido, bloques, progreso, i18n, UI |
| `scenes/` | Pantallas y componentes: mapa, lección, ejercicios, resultado, intro, ajustes, HUD, mascota |
| `content/unit1/` | Las 10 lecciones en JSON bilingüe (editable sin recompilar) |
| `tests/` | Harness propio + tests headless |
| `tools/` | Scripts de terminal (`test.sh`, `run.sh`, `smoke.sh`, `gen_icon.sh`) |
| `docs/` | Especificación de diseño, plan de implementación y guía de publicación |

## Documentación

- Diseño del MVP: [docs/superpowers/specs/2026-07-17-promptquest-mvp-design.md](docs/superpowers/specs/2026-07-17-promptquest-mvp-design.md)
- Plan de implementación: [docs/superpowers/plans/2026-07-17-promptquest-mvp.md](docs/superpowers/plans/2026-07-17-promptquest-mvp.md)
- Publicar en Play Store: [docs/publicacion-play-store.md](docs/publicacion-play-store.md)

## Estado

Juego **completo** (8 zonas / 80 lecciones) funcional y verificado en escritorio (53 tests
headless verdes). Currículum completo en [docs/curriculum-completo.md](docs/curriculum-completo.md).
Pendiente para llegar a la tienda: configurar el Android SDK + keystore y generar el `.aab`
(ver la guía de publicación).
