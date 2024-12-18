# DryTime (App de Clima y Selección de Ubicación)

Una aplicación que permite a los usuarios buscar ubicaciones y ver el clima actual. Con funcionalidades de accesibilidad mejoradas para usuarios con discapacidad visual.

## Funcionalidades principales:
- **Búsqueda de ubicación**: Los usuarios pueden buscar lugares usando un campo de texto.
- **Ubicación en vivo**: Opción para usar la ubicación actual del usuario y ver el clima en esa área.
- **Selección de ubicación**: Los usuarios pueden seleccionar una ubicación desde una lista de resultados o el mapa para ver el clima.
- **Clima actual**: Muestra el clima actual, incluyendo condiciones climáticas (soleado, lluvioso, etc.) y el icono correspondiente.

## Mejoras de accesibilidad:
- **VoiceOver**: Se ha optimizado la app para usuarios de VoiceOver.
  - Descripciones claras y útiles para los elementos interactivos.
  - Botones como "Confirmar ubicación" y "Usar ubicación actual" con descripciones detalladas.
  - Uso de `accessibilityLabel` y `accessibilityHint`.
  - Elementos innecesarios se han ocultado con `accessibilityHidden` para mejorar la experiencia.

## Requisitos:
- iOS 14+.
- Xcode 12+.
