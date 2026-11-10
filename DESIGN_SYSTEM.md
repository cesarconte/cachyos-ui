# CachyOS UI — Principios Arquitectónicos & Guía de Diseño Golden Gate

Este documento consolida las reglas de arquitectura y diseño canónicas de **CachyOS UI (`CachyOS.UI 1.0`)** para garantizar fidelidad pixel-perfect al estilo macOS Golden Gate / Liquid Glass en KDE Plasma 6 (Wayland) y erradicar errores de desbordamiento, recorte de texto o valores hardcodeados en cualquier aplicación del ecosistema.

---

## 1. Principios de Contención y Layout (Sin Desbordamientos ni Recortes)

### A. Regla de Oro de Layouts Dinámicos
En Qt Quick (`RowLayout` y `ColumnLayout`), el valor de `Layout.minimumWidth` de cualquier elemento toma por defecto su `implicitWidth`.
- **Regla Estricta:** Cualquier componente contenedor o etiqueta de texto dinámico situada dentro de un `RowLayout` o `ColumnLayout` **DEBE** definir explícitamente:
  ```qml
  Layout.fillWidth: true
  Layout.minimumWidth: 0
  ```
- **Efecto:** Evita que el ancho intrínseco del texto sobrepase o fuerce al layout padre a desbordar los límites de la ventana o contenedor.

### B. Regla de Textos Completos (Cero Truncamientos Inesperados)
- **Títulos y encabezados:** Deben ser claros y concisos. En contenedores fluidos nunca deben truncarse; el contenedor debe calcularse para alojar el título en una sola línea.
- **Subtítulos y descripciones:** **NUNCA** usar `elide: Text.ElideRight` si el texto debe ser leído íntegramente por el usuario. En su lugar:
  ```qml
  Layout.fillWidth: true
  Layout.minimumWidth: 0
  wrapMode: Text.WordWrap
  ```
  Esto garantiza que el texto se muestre **100% completo**, adaptándose automáticamente en varias líneas si la ventana o tarjeta se estrecha, sin recortarse jamás con puntos suspensivos.
- **Renglones de listas con nombres de archivos / URLs:** Usar `elide: Text.ElideMiddle` únicamente en delegates de archivos donde la extensión y el prefijo son críticos, siempre con `Layout.minimumWidth: 0`.

---

## 2. Tokens Centralizados en `CachyTheme` (Cero Dimensiones Hardcodeadas)

Todas las aplicaciones deben recurrir a los tokens métricos provistos por el singleton `CachyTheme`:

| Token en `CachyTheme` | Valor | Propósito |
| :--- | :---: | :--- |
| `windowWidthUtility` | `540` | Ancho estándar para utilidades flotantes (Dropover, Siri/Kiri, Writing Tools) |
| `windowHeightUtility` | `620` | Alto estándar para utilidades flotantes |
| `windowWidthSettings` | `880` | Ancho canónico para aplicaciones con barra lateral (Ajustes, Música, Control Center) |
| `windowHeightSettings` | `640` | Alto canónico para aplicaciones con barra lateral |
| `windowWidthDialog` | `440` | Ancho base para modales y diálogos de confirmación |
| `windowHeightDialog` | `320` | Alto base para modales y diálogos |
| `marginWindow` | `18` | Margen perimetral continuo entre el borde de la ventana y los componentes |
| `marginCard` | `14` | Padding interno dentro de tarjetas `CachyCard` |
| `titleBarHeight` | `44` | Altura estándar de la barra de título / botones de semáforo estilo macOS |
| `trafficLightMargin` | `16` | Distancia desde el borde izquierdo de la ventana al primer botón del semáforo |

### Radios de Esquina Canónicos
- `radiusWindow: 22` (Esquinas de ventana curvada continua estilo macOS Sonoma / Sequoia).
- `radiusLarge: 16` (Contenedores y secciones amplias).
- `radiusMedium: 12` (Tarjetas `CachyCard` elevadas).
- `radiusSmall: 8` (Botones `CachyButton`, campos de texto `CachyTextField`, píldoras).

---

## 3. Replicación Pixel-Perfect macOS Golden Gate / Liquid Glass

1. **Semáforo Vectorial Oficial (`CachyTrafficLights`):**
   - 14 px de diámetro, 8 px de espacio entre círculos, situado a 16 px del borde izquierdo.
   - Glifos vectoriales exactos (Cerrar `✕`, Minimizar `─`, Pantalla completa dos flechas opuestas `⤢`).
   - Efecto de revelación simultánea: al hacer hover sobre el área de los 3 botones, los glifos se desvanecen sutilmente a la vista en los 3 botones a la vez. Al hacer clic o presionar, el botón pulsado se oscurece individualmente.
2. **Borde Especular Continuo de 1 px:**
   - La ventana dibuja sobre las esquinas de 22 px un borde de 1 px continuo con `specularBorder` (`rgba(255, 255, 255, 0.14)` en modo oscuro, `rgba(0, 0, 0, 0.10)` en modo claro).
3. **Desenfoque y Contraste Real Wayland (KWin):**
   - Manejado por `CachyWindowBlur` mediante `KWindowEffects::enableBlurBehind` con una región vectorial poligonal redondeada (`QRegion`) de radio 22 px, asegurando cero artefactos negros en ángulos rectos bajo Wayland.
4. **Respuesta Táctil:**
   - Botones y controles tienen una escala sutil de retorno (`scale: pressed ? 0.96 : (hovered ? 1.01 : 1.0)`) con animación elástica suave (`Easing.OutCubic`, 180 ms).
