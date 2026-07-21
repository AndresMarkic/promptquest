class_name I18n
## Traducciones de UI. El contenido de lecciones NO pasa por acá (ya es bilingüe
## en JSON). Se usa un diccionario propio en vez del sistema de Translation de
## Godot para no depender de la importación del editor en headless (spec §5.6).

static var idioma_actual := "es"

const DIC := {
	"CONTINUAR": {"es": "CONTINUAR", "en": "CONTINUE"},
	"VERIFICAR": {"es": "VERIFICAR", "en": "CHECK"},
	"CORRECTO": {"es": "¡Correcto!", "en": "Correct!"},
	"INCORRECTO": {"es": "Ups, no era así", "en": "Oops, not quite"},
	"COMBO": {"es": "¡Combo x%d!", "en": "Combo x%d!"},
	"SALIR_CONFIRMA": {"es": "Si salís ahora perdés el progreso de esta lección. ¿Salir?", "en": "If you leave now you lose this lesson's progress. Leave?"},
	"SALIR": {"es": "Salir", "en": "Leave"},
	"SEGUIR": {"es": "Seguir", "en": "Keep going"},
	"SIN_CORAZONES": {"es": "¡Te quedaste sin corazones! Repasá una lección para recuperar uno.", "en": "You ran out of hearts! Review a lesson to recover one."},
	"SIN_CORAZONES_MAPA": {"es": "Sin corazones. Esperá que se regeneren o repasá una lección completada.", "en": "No hearts. Wait for them to regenerate or review a completed lesson."},
	"REPASAR_PREGUNTA": {"es": "Ya completaste esta lección. ¿Repasarla? (recuperás 1 corazón)", "en": "You already completed this lesson. Review it? (recover 1 heart)"},
	"REPASAR": {"es": "Repasar", "en": "Review"},
	"LECCION_COMPLETADA": {"es": "¡Lección completada!", "en": "Lesson complete!"},
	"RACHA_DIAS": {"es": "¡Racha de %d días!", "en": "%d day streak!"},
	"UNIDAD_COMPLETADA": {"es": "¡Venciste al Boss! Unidad completada", "en": "You beat the Boss! Unit complete"},
	"BOSS_FALLADO": {"es": "El Boss te ganó esta vez (necesitás 9 de 12). ¡Reintentá!", "en": "The Boss won this time (you need 9 of 12). Try again!"},
	"INTRO_1": {"es": "En el Mundo Digital, una pequeña IA acaba de despertar...", "en": "In the Digital World, a little AI just woke up..."},
	"INTRO_2": {"es": "\"¡Hola! Soy Byte. Perdí mis fragmentos de memoria y no recuerdo cómo funciono.\"", "en": "\"Hi! I'm Byte. I lost my memory fragments and can't remember how I work.\""},
	"INTRO_3": {"es": "Ayudá a Byte a recuperarlos: cada lección que completes le devuelve un fragmento. ¡Y de paso te volvés experto en IA!", "en": "Help Byte recover them: every lesson you complete returns one fragment. And you become an AI expert along the way!"},
	"EMPEZAR": {"es": "¡EMPEZAR!", "en": "START!"},
	"SALTAR": {"es": "Saltar", "en": "Skip"},
	"AJUSTES": {"es": "Ajustes", "en": "Settings"},
	"IDIOMA": {"es": "Idioma", "en": "Language"},
	"SONIDO": {"es": "Sonido", "en": "Sound"},
	"CERRAR": {"es": "Cerrar", "en": "Close"},
}

static func t(clave: String) -> String:
	return DIC.get(clave, {}).get(idioma_actual, clave) if DIC.has(clave) else clave
