# Contributing to PromptQuest 💜

Thanks for wanting to help! PromptQuest is built so that **anyone can contribute content
without knowing game development.** The most valuable contributions are lessons and
translations.

> 🇪🇸 También podés contribuir en español — el juego es bilingüe y las lecciones tienen
> texto en `es` y `en`.

## The easiest contribution: add or improve a lesson

Lessons are plain **JSON** files under [`content/`](content/), completely separate from the
game code. To add a lesson you just create/edit a file — no GDScript needed.

```
content/
  unit1/  lesson_01.json … lesson_10.json   ← The Core
  unit2/  lesson_01.json … lesson_10.json   ← The Forge
  ...
```

A lesson is a JSON object with a title, two lines from the mascot (intro/outro), and a list
of exercises. Every player-facing text has an `es` (Spanish) and `en` (English) version.

### Exercise types

**1. Multiple choice**
```json
{
  "type": "multiple_choice",
  "question": { "es": "¿Cuál prompt es más claro?", "en": "Which prompt is clearer?" },
  "options": [
    { "es": "Escribí 3 tips para dormir mejor", "en": "Write 3 tips to sleep better" },
    { "es": "Contame algo del sueño", "en": "Tell me something about sleep" }
  ],
  "correct": 0,
  "explanation": { "es": "El primero define tema y cantidad.", "en": "The first defines topic and amount." }
}
```

**2. Build a prompt with blocks**
```json
{
  "type": "block_builder",
  "goal": { "es": "Armá un pedido claro", "en": "Build a clear request" },
  "solution": {
    "es": ["Actuá como chef", "y dame una receta", "en 5 pasos."],
    "en": ["Act as a chef", "and give me a recipe", "in 5 steps."]
  },
  "distractors": { "es": ["hacé lo que quieras"], "en": ["do whatever"] },
  "explanation": { "es": "…", "en": "…" }
}
```

The **10th lesson of each unit is a boss**: same format plus `"boss": true` and exactly 12
exercises that review the whole unit.

### Rules the validator checks

- Every text field has both `es` and `en`.
- `multiple_choice`: `correct` is a valid index; at least 2 options.
- `block_builder`: `solution.es` and `solution.en` are non-empty arrays.
- Only the two types above are supported.

### Test your lesson

```bash
bash tools/test.sh
```

The content validator (`tests/test_contenido.gd`) automatically checks **every** lesson in
`content/`, so if it passes, your lesson is well-formed. 🎉

## Other ways to help

- **Translations / wording** — improve the Spanish or English of any lesson.
- **New exercise types** — e.g. *match pairs*, *order the steps*, *classify*. These are new
  scenes that follow the `ExerciseBase` contract (see `scenes/exercises/`).
- **Bugs & polish** — open an issue with a screenshot; small PRs are great.
- **Art & sound** — everything is drawn in code today; tasteful additions welcome.

## Workflow

1. Fork the repo and create a branch.
2. Make your change; run `bash tools/test.sh` (all green) and `bash tools/smoke.sh`.
3. Open a Pull Request describing **what** changed and **why**. Screenshots help for UI.

## Ground rules for content

- **Be accurate.** When in doubt about an AI concept, simplify rather than state something
  wrong. Keep it timeless (avoid version numbers that age fast).
- **Be kind and neutral.** Don't bash any company or model.
- Keep it apt for all ages.

Questions? Open an issue. Happy to help you land your first PR. 🚀
