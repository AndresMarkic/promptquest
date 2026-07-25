# PromptQuest — Currículum completo: de cero a IA senior

**Fecha:** 2026-07-25
**Objetivo:** mapa completo del juego terminado. 8 unidades (~80 lecciones) que llevan
al jugador de no saber nada de IA a pensar y diseñar sistemas de IA como un ingeniero senior.
**Decisiones tomadas:** camino único lineal de 8 unidades · práctica 100% offline simulada ·
~10 lecciones por unidad.

Este documento es la fuente de verdad del contenido. Se construye por tandas; al terminar las
8 unidades, el juego está completo y no requiere rediseño estructural.

---

## 1. Filosofía pedagógica

- **Aprender haciendo, no leyendo.** Cada concepto se practica con ejercicios cortos (3-5 min),
  no con teoría. La regla: si no se puede convertir en ejercicio jugable, se simplifica hasta
  que sí.
- **Espiral, no escalera aislada.** Cada unidad repasa y reusa lo anterior (el boss de cada
  unidad integra las lecciones previas; los conceptos vuelven aplicados).
- **De lo concreto a lo abstracto.** Se empieza con ejemplos cotidianos y recién en unidades
  avanzadas aparecen conceptos técnicos, siempre aterrizados en un caso.
- **Honestidad técnica.** Se simplifica sin mentir. Ante la duda entre "impresionante pero
  impreciso" y "simple pero correcto", gana lo correcto (regla ya usada en la Unidad 1).
- **100% offline.** Todo se enseña y practica dentro del juego, sin API keys ni internet. Los
  temas "de sistema" (APIs, agentes, RAG) se practican simulados: ordenar flujos, elegir el
  mejor diseño, arreglar un pipeline con bloques.

---

## 2. La progresión (de cero a senior)

| Unidad | Zona (narrativa) | Nivel del jugador | Qué sabés hacer al terminar |
|---|---|---|---|
| 1 | El Núcleo | Cero → usuario inicial | Le hablás bien a una IA para tareas cotidianas |
| 2 | La Forja | Usuario competente | Resolvés tareas complejas guiando el razonamiento |
| 3 | El Taller | Usuario avanzado | Usás IA como herramienta de trabajo en varios dominios |
| 4 | El Observatorio | Usuario crítico | Elegís la IA correcta y entendés sus límites |
| 5 | La Red | Técnico-práctico | Entendés cómo se conecta una IA al mundo real |
| 6 | El Crisol | Profesional | Diseñás prompts robustos y confiables para producción |
| 7 | La Fábrica | Profesional aplicado | Integrás IA en un flujo de trabajo o negocio completo |
| 8 | La Cima | Ingeniero / senior | Pensás y diseñás sistemas de IA de punta a punta |

**Narrativa:** Byte despertó sin memoria en el Mundo Digital. Cada unidad es una **zona** que el
jugador ayuda a restaurar; al recuperarla, Byte gana una capacidad nueva y el jugador sube de
nivel. Al terminar las 8 zonas, Byte está completo y el jugador recibe la **certificación
in-game "Ingeniero de IA"**.

---

## 3. Las 8 unidades en detalle

> Formato: cada lección tiene un objetivo de aprendizaje claro. Salvo aviso, cada lección son
> 8-12 ejercicios (mezcla de tipos). La lección 10 de cada unidad es siempre un **boss** de
> repaso integrador (cronometrado, aprobás con ≥75%).

### Unidad 1 — El Núcleo · Fundamentos de IA  ✅ (ya construida)

Nivel: cero → usuario inicial.

1. ¿Qué es la IA generativa?
2. ¿Qué es un LLM?
3. Tokens y contexto
4. Cómo "piensa" (predicción)
5. Alucinaciones (y verificar)
6. Tu primer prompt (claro y específico)
7. Contexto y rol
8. Formato de salida
9. Enseñar con ejemplos (few-shot)
10. 👑 Boss del Núcleo

**Al terminar:** entendés qué es y qué no es una IA, y le pedís cosas de forma clara.

---

### Unidad 2 — La Forja · Prompting Intermedio

Nivel: usuario competente. **Objetivo:** guiar el razonamiento de la IA para tareas que no se
resuelven de un solo tiro.

1. **Pensá paso a paso** — pedir razonamiento explícito (chain-of-thought) y por qué mejora.
2. **Descomponer una tarea grande** — partir un problema en sub-pedidos manejables.
3. **Iterar** — la primera respuesta es un borrador; pedir mejoras concretas.
4. **Poner restricciones** — límites de largo, alcance, "solo usá esto", "no incluyas aquello".
5. **Delimitadores y estructura** — separar instrucción de datos (comillas, secciones, etiquetas).
6. **Ejemplos negativos** — mostrar qué NO querés para afinar el resultado.
7. **Controlar tono, estilo y registro** — mismo contenido, distinta voz según el público.
8. **Conversar** — aprovechar el ida y vuelta en vez de un mega-prompt.
9. **Plantillas reutilizables** — armar un prompt "molde" que reusás cambiando pocas cosas.
10. 👑 Boss de La Forja.

**Al terminar:** resolvés tareas de varios pasos guiando a la IA como un asistente experto.

---

### Unidad 3 — El Taller · Casos de Uso Prácticos

Nivel: usuario avanzado. **Objetivo:** aplicar la IA a trabajo real en distintos dominios.

1. **Escribir con IA** — mails, textos, publicaciones; adaptar al destinatario.
2. **Resumir y extraer** — sacar lo importante de un texto largo; bullet points, ideas clave.
3. **Programar 1: pedir y entender código** — pedir un script, leerlo, hacer que lo explique.
4. **Programar 2: depurar** — pegar un error, encontrar la causa, arreglarlo con la IA.
5. **Analizar datos** — interpretar números y tablas, sacar conclusiones, pedir el formato útil.
6. **Prompts para imágenes** — sujeto, estilo, luz, composición, encuadre; qué controla cada parte.
7. **Investigar y comparar** — pedir pros/contras, contrastar fuentes, evitar la respuesta única.
8. **Traducir y adaptar** — no solo traducir: adaptar tono y cultura al público.
9. **Estudiar con IA** — usar la IA como tutor personal (explicame, tomame examen, corregime).
10. 👑 Boss del Taller.

**Al terminar:** usás IA como herramienta de trabajo en escritura, código, datos, imágenes y estudio.

---

### Unidad 4 — El Observatorio · Comparar Modelos y Elegir Bien

Nivel: usuario crítico. **Objetivo:** entender el ecosistema de modelos y elegir el correcto.

1. **Las familias de IA** — quién es quién (Claude/Anthropic, GPT/OpenAI, Gemini/Google, Llama/Meta,
   Mistral, etc.) sin marketing, con qué los diferencia.
2. **Abiertos vs cerrados** — modelos que podés descargar vs los que se usan por servicio; pros/contras.
3. **Razonamiento, contexto y multimodal** — qué significan estas capacidades y por qué importan.
4. **Velocidad, costo y tamaño** — el triángulo de trade-offs: rápido/barato vs potente.
5. **Temperatura** — creatividad vs precisión; cuándo subirla y cuándo bajarla.
6. **Fechas de corte y versiones** — por qué un modelo "no sabe" algo reciente; leer una versión.
7. **Límites, sesgos y seguridad** — qué NO conviene delegarle; sesgos y cómo detectarlos.
8. **Elegir el modelo para la tarea** — ejercicio central: dado un caso, elegí el modelo y justificá.
9. **Multimodal** — texto, imagen, audio y voz; qué se puede combinar hoy.
10. 👑 Boss del Observatorio.

**Al terminar:** elegís la IA adecuada para cada tarea y conocés sus límites reales.

---

### Unidad 5 — La Red · Herramientas y Ecosistema

Nivel: técnico-práctico. **Objetivo:** entender cómo una IA se conecta a datos y herramientas.
(Todo simulado con ejercicios de ordenar flujos y elegir el mejor diseño.)

1. **Qué es una API** — el concepto sin código: pedir algo a un servicio y recibir respuesta.
2. **Tokens, costos y límites** — cómo se cobra/mide el uso; por qué importa el largo.
3. **La IA que usa herramientas** — function calling / tool use: la IA pide "usá esta herramienta".
4. **Qué es un agente** — una IA que decide pasos y actúa, no solo responde.
5. **Ordenar el flujo de un agente** — ejercicio de bloques: planificar → actuar → observar → repetir.
6. **RAG** — traer información externa al contexto para responder con datos frescos/propios.
7. **Embeddings y búsqueda por significado** — buscar por sentido, no por palabra exacta (concepto).
8. **MCP** — conectar la IA a tus datos y herramientas de forma estándar (concepto y para qué sirve).
9. **Memoria y estado** — qué recuerda una conversación y qué no; cómo se le da "memoria".
10. 👑 Boss de La Red.

**Al terminar:** entendés cómo una IA deja de ser "solo chat" y se conecta al mundo real.

---

### Unidad 6 — El Crisol · Prompt Engineering Avanzado

Nivel: profesional. **Objetivo:** diseñar prompts robustos, seguros y confiables.

1. **System prompt** — la instrucción de fondo que fija rol, reglas y estilo de todo el sistema.
2. **Formatos estructurados** — pedir JSON/esquemas para que la salida sea usable por un programa.
3. **Grounding** — anclar las respuestas a datos provistos para que no invente.
4. **Evaluar salidas** — definir criterios de "está bien" y chequear contra ellos.
5. **La IA como juez** — usar un modelo para evaluar la salida de otro (LLM-as-judge) y sus límites.
6. **Guardrails** — poner límites de seguridad: qué debe y qué no debe hacer el sistema.
7. **Inyección de prompts** — el ataque más común y cómo defenderse (no confiar en la entrada).
8. **Reducir alucinaciones en serio** — técnicas combinadas: grounding + pedir fuentes + verificar.
9. **Contextos largos** — qué poner, qué dejar afuera y dónde ubicar lo importante.
10. 👑 Boss del Crisol.

**Al terminar:** diseñás prompts de nivel producción: robustos, seguros y evaluables.

---

### Unidad 7 — La Fábrica · IA en Flujos de Trabajo Reales

Nivel: profesional aplicado. **Objetivo:** integrar IA en un proceso real de principio a fin.

1. **Automatizar lo repetitivo** — detectar qué tarea repetitiva conviene delegar a la IA.
2. **Encadenar prompts (pipelines)** — la salida de un paso alimenta al siguiente.
3. **Humano en el bucle** — dónde poner una revisión humana y por qué.
4. **Errores y casos borde** — qué hacer cuando la IA falla o entra basura.
5. **Costo y latencia en la práctica** — hacer que rinda sin gastar de más ni tardar de más.
6. **Privacidad y datos sensibles** — qué NO se le manda a un servicio; anonimizar.
7. **Medir si funciona** — métricas simples para saber si el sistema realmente ayuda.
8. **Integrar en un proceso de negocio** — caso completo: de la tarea manual al flujo con IA.
9. **Documentar y mantener** — dejar el sistema entendible y actualizable.
10. 👑 Boss de La Fábrica.

**Al terminar:** llevás una idea con IA de "prueba" a un flujo de trabajo que aguanta el día a día.

---

### Unidad 8 — La Cima · Ingeniería de IA (Senior) + Capstone

Nivel: ingeniero / senior. **Objetivo:** diseñar sistemas de IA completos y decidir como senior.

1. **Anatomía de un agente** — planificar → actuar → observar → corregir; cuándo un agente sí/no.
2. **Pipelines multi-modelo** — el modelo correcto en cada paso (barato para filtrar, potente para razonar).
3. **RAG de verdad** — partir documentos (chunking), recuperar, re-rankear; por qué falla y cómo mejora.
4. **Evaluación y testing de sistemas de IA** — armar un set de pruebas y medir mejoras/regresiones.
5. **Seguridad a nivel sistema** — pensar el sistema entero como superficie de ataque.
6. **Build vs buy** — qué construir, qué usar hecho, y cómo decidir.
7. **Diseñar para un caso de negocio real** — de un problema a una arquitectura de IA justificada.
8. **Del prototipo a producción** — qué cambia entre "funciona en la demo" y "aguanta usuarios reales".
9. **Ética y responsabilidad** — impacto, transparencia, límites de lo que conviene automatizar.
10. 👑 **Boss Final / Capstone** — el jugador arma un sistema de IA completo resolviendo una serie de
    desafíos integradores de todas las unidades. Al aprobar: **certificación "Ingeniero de IA"**.

**Al terminar:** pensás, diseñás y defendés un sistema de IA como un ingeniero senior.

---

## 4. Tipos de ejercicio (los actuales + los nuevos a construir)

Ya existen y se reusan en todo el juego:
- **Opción múltiple** — elegir la mejor respuesta/prompt/diseño.
- **Armar con bloques (tap-to-place)** — construir un prompt/flujo en el orden correcto.

Nuevos tipos a construir (aplican de la Unidad 2 en adelante; todos respetan el contrato
`ExerciseBase`, así que se enchufan sin tocar el motor):

| Tipo | Qué hace | Unidades donde brilla |
|---|---|---|
| **Ordenar pasos** (`order_steps`) | Reordenar los pasos de un flujo/agente/pipeline | 5, 7, 8 |
| **Emparejar** (`match`) | Unir término ↔ definición (minijuego de memoria) | 4, 5, 6 |
| **Corregí el prompt** (`fix_prompt`) | Dado un prompt malo, elegir/armar la corrección | 2, 6 |
| **Predecí la salida** (`predict_output`) | Dado un prompt, elegir qué respondería la IA | 1-4 |
| **Clasificar** (`classify`) | Arrastrar ítems a categorías (modelo correcto, seguro/inseguro) | 4, 6 |

`predict_output` y `fix_prompt` pueden implementarse como variantes de opción múltiple (rápido);
`order_steps`, `match` y `classify` son escenas nuevas (más trabajo, pero de alto valor lúdico).

---

## 5. Cambios técnicos para soportar 8 unidades

La arquitectura ya lo soporta casi todo (el contenido es JSON separado del código). Cambios
necesarios, todos acotados:

1. **Contenido**: carpetas `content/unit2/` … `content/unit8/` con `lesson_01..10.json` cada una,
   mismo formato validado que la Unidad 1.
2. **Registro de unidades**: hoy `Content.UNIT1_IDS` está fijo. Pasar a una lista de unidades
   (`[{id, titulo, zona, ids[]}]`) para que el mapa y el desbloqueo iteren sobre todas.
3. **Mapa de 8 zonas**: el camino serpenteante se extiende con **separadores de unidad** (banner
   "LA FORJA", etc.) y una **compuerta**: para entrar a la unidad N hay que completar la N-1.
   Reusa el `MapScreen` actual con secciones. (Alternativa futura: mapa-mundo de zonas.)
4. **Desbloqueo entre unidades**: `ProgressLogic` gana el concepto de unidad completada; el boss
   de cada unidad abre la siguiente.
5. **Nuevos ejercicios**: construir los tipos de la sección 4 (uno por vez, con tests).
6. **Pantalla de certificación**: al vencer el Boss Final, una pantalla especial con el diploma
   "Ingeniero de IA" (nombre del jugador, fecha, sello Byte) — compartible como imagen.
7. **Economía**: sin cambios estructurales. Opcional a futuro (post-lanzamiento): logros por
   unidad y una liga semanal (requiere backend → fuera del alcance offline actual).

Nada de esto cambia el motor ni rompe lo hecho; son extensiones sobre la base ya construida.

---

## 6. Volumen y plan de construcción por tandas

**Volumen total:** 8 unidades × ~10 lecciones × ~9 ejercicios × 2 idiomas ≈ **~1.400 bloques de
contenido** + 5 tipos de ejercicio + ajustes de mapa/certificación. Es un curso completo: el grueso
del trabajo es **escribir contenido correcto**, no programar.

**Orden de tandas propuesto** (cada tanda = un entregable jugable y verificado, con tests verdes):

| Tanda | Qué se construye | Por qué en este orden |
|---|---|---|
| **0** (hecho) | Unidad 1 + rediseño visual + assets de tienda | Base publicable ya |
| **1** | Soporte multi-unidad (registro, mapa de zonas, desbloqueo, certificación) + **Unidad 2** | Desbloquea todo lo demás; Unidad 2 es el siguiente escalón natural |
| **2** | Tipos de ejercicio nuevos (`predict_output`, `fix_prompt`, `order_steps`) + **Unidad 3** | Los casos de uso lucen con ejercicios variados |
| **3** | Tipo `match` + `classify` + **Unidad 4** (comparar modelos) | Unidad 4 usa mucho emparejar/clasificar |
| **4** | **Unidad 5** (herramientas/ecosistema) | Ya con `order_steps` listo para flujos de agentes |
| **5** | **Unidad 6** (prompt engineering avanzado) | — |
| **6** | **Unidad 7** (flujos reales) | — |
| **7** | **Unidad 8** (ingeniería senior) + **Boss Final / Capstone** + pantalla de certificación | Cierre del juego completo |

**Estrategia de lanzamiento (recomendada):** publicar en la tienda al terminar la **Tanda 1**
(2 unidades completas + estructura para el resto) con ficha honesta, y liberar las unidades 3-8 como
**actualizaciones** cada pocas semanas. Ventajas: salís antes, recibís feedback real, y cada
actualización reengancha jugadores (bueno para el ranking de la tienda). Alternativa: esperar a
tener las 8 y lanzar todo junto (más tiempo sin feedback, pero "juego terminado" de una).

---

## 7. Criterio de "juego terminado"

El juego está completo cuando:
- Las 8 unidades (80 lecciones) existen en ES y EN y pasan el validador de contenido.
- El mapa muestra las 8 zonas con desbloqueo lineal y bosses.
- Los 5 tipos de ejercicio funcionan y tienen tests.
- El Boss Final / Capstone y la certificación funcionan.
- La batería de tests headless está verde y el smoke boot limpio.
- Los assets de tienda están actualizados (capturas de varias unidades).

A partir de ahí, no hay que "modificar" nada estructural: solo, si se quiere, sumar el modo
per-modelo (árboles de Claude/GPT/Gemini) como expansión opcional a futuro.

---

## 8. Notas de rigor

- **Exactitud:** los temas técnicos (RAG, agentes, function calling, embeddings, MCP) se enseñan
  simplificados pero correctos. Cada lección avanzada se revisa contra fuentes al escribirla; ante
  la duda, se simplifica antes que afirmar algo incorrecto.
- **Atemporalidad:** se evita atar el contenido a nombres de versiones que envejecen ("GPT-4.5",
  "Claude 3.7"); se habla de familias y capacidades. Los datos que cambian rápido se enseñan como
  "esto cambia seguido, verificá la versión actual".
- **Offline:** ninguna lección requiere internet ni API keys. Los temas de API/agentes se practican
  con ejercicios de diseño y ordenamiento, no con llamadas reales.
