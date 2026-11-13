# CachyOS UI — Principios Arquitectónicos & Guía de Diseño Golden Gate

Este documento consolida las reglas de arquitectura y diseño canónicas de **CachyOS UI (`CachyOS.UI 1.0`)** para garantizar fidelidad pixel-perfect al lenguaje de diseño CachyOS / Liquid Glass en KDE Plasma 6 (Wayland) y erradicar errores de desbordamiento, recorte de texto o valores hardcodeados en cualquier aplicación del ecosistema.

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

### C. Regla de Altura Adaptativa (Cero Desbordes por Altura)
Toda superficie (ventana, popup de plasmoide, tarjeta) debe adaptarse al contenido,
nunca cortar elementos ni dejar espacio vacío injustificado:

1. **`implicitHeight` / `implicitWidth`**: Deben reflejar el tamaño real del
   contenido + márgenes + espaciados. Nunca usar un valor fijo que sea menor
   que el contenido mínimo.
2. **`Layout.minimumHeight` / `Layout.minimumWidth`**: Cada elemento hijo debe
   declarar su mínimo explícito para que el layout padre pueda calcular el
   mínimo real del contenedor.
3. **`Layout.fillHeight` / `Layout.fillWidth`**: Usar solo en elementos que
   deben expandirse. Los elementos que deben mantener su tamaño natural no
   deben tener `fillHeight`/`fillWidth`.
4. **`Layout.preferredHeight` / `Layout.preferredWidth`**: Usar para sugerir un
   tamaño cuando el elemento es redimensionable.
5. **Prohibido**: `implicitHeight: <valor fijo menor que el contenido>` o
   `Layout.minimumHeight: <valor fijo menor que el contenido>`. Esto provoca
   que los elementos se corten o se desborden de su contenedor.
6. **Referencia**: Plasma (`AppletPopup`), QML (`ColumnLayout`/`RowLayout`) y
   Kirigami (`ScrollablePage`) calculan el tamaño del contenedor a partir de
   los `implicitHeight`/`implicitWidth` de los hijos. Replicar ese patrón es
   la forma correcta de garantizar que nada se corte.

### B. Regla de Textos Completos (Cero Truncamientos Inesperados)
- **Títulos y encabezados:** Deben ser claros y concisos. En contenedores fluidos nunca deben recortarse sin elipsis (`CachyHeading` aplica `elide: Text.ElideRight` por defecto).
- **Subtítulos y descripciones:** **NUNCA** usar `elide: Text.ElideRight` si el texto debe ser leído íntegramente por el usuario. En su lugar:
  ```qml
  Layout.fillWidth: true
  Layout.minimumWidth: 0
  wrapMode: Text.WordWrap
  ```
  Esto garantiza que el texto se muestre **100% completo**, adaptándose automáticamente en varias líneas si la ventana o tarjeta se estrecha, sin recortarse jamás con puntos suspensivos.
- **Renglones de listas con nombres de archivos / URLs / títulos de ventana:** Usar `elide: Text.ElideMiddle` o `Text.ElideRight` siempre acompañado de `Layout.minimumWidth: 0`.

---

## 2. Estructura Universal de Ventanas (`CachyWindow`)

Toda ventana del sistema comparte estrictamente la misma arquitectura física:
1. **Contorno Exterior Especular (1 px):** Delineado continuo sobre las esquinas de `20 px` (`CachyTheme.radiusWindow`) con `CachyTheme.specularBorder`.
2. **Desenfoque Wayland (KWin):** Activado automáticamente cuando `showWindowFrame: true` mediante `CachyWindowBlur` con `QRegion` vectorial redondeada para evitar esquinas en ángulo recto.
3. **Barra Lateral *Edge-to-Edge* Opcional (`sidebar`):**
   - Cuando se puebla la propiedad `sidebar` y `sidebarVisible: true`, la ventana divide su interior mediante una máscara `MultiEffect` de `20 px` de radio.
   - El panel lateral (`CachyTheme.sidebarBackground`) aloja el semáforo en su propia cabecera de `44 px` y se separa del área principal con un divisor vertical duro de `1 px` (`CachyTheme.hardDividerColor`).
4. **Barra de Título Canónica (44 px):**
   - **Grupo izquierdo (`headerLeading`):** Situado a `CachyTheme.marginWindow` (`18 px`) del borde izquierdo (o a `14 px` del divisor de la barra lateral). Incluye el semáforo cuando no hay barra lateral.
   - **Banda central (`headerCenter` / `title`):** Calculada dinámicamente como el espacio libre exacto entre el grupo izquierdo y el derecho (`bandLeft` a `bandRight`), garantizando matemáticamente cero colisiones con las acciones de cabecera.
   - **Acciones derechas (`headerActions`):** Contenedor anclado a `CachyTheme.marginWindow` (`18 px`) del borde derecho.
   - **Divisor inferior duro (`1 px`):** Visible por defecto (`showTitleBarDivider: true`) con `CachyTheme.hardDividerColor`.
5. **Área de Contenido:** Con `contentPadded: true`, el contenido queda automáticamente protegido con un margen perimetral exacto de `18 px` (`CachyTheme.marginWindow`) **en los cuatro lados**, garantizando alineación vertical estricta 1:1 con el semáforo y las herramientas superiores.
   - El divisor de la cabecera separa el *chrome* del contenido, pero **el contenido es una superficie flotante y debe respirar**: nunca queda pegado al divisor.
   - La **única** superficie que llega al divisor es la barra lateral *edge-to-edge*, por definición.

---

## 3. Tokens Centralizados en `CachyTheme` (Cero Dimensiones Hardcodeadas)

Todas las aplicaciones deben recurrir a los tokens métricos y de color provistos por el singleton `CachyTheme`:

### Métricas de Ventana y Contenedores

| Token en `CachyTheme` | Valor | Propósito |
| :--- | :---: | :--- |
| `windowWidthUtility` | `540` | Ancho estándar para utilidades flotantes (Dropover, Kiri, herramientas de escritura) |
| `windowHeightUtility` | `620` | Alto estándar para utilidades flotantes |
| `windowWidthSettings` | `880` | Ancho canónico para aplicaciones con barra lateral (Ajustes, Música, Control Center) |
| `windowHeightSettings` | `640` | Alto canónico para aplicaciones con barra lateral |
| `windowWidthDialog` | `440` | Ancho base para modales y diálogos de confirmación (`minimumWidth` por defecto) |
| `windowHeightDialog` | `320` | Alto base para modales y diálogos |
| `marginWindow` | `18` | Margen perimetral continuo entre el borde de la ventana y los componentes |
| `marginCard` | `14` | Padding interno universal dentro de tarjetas `CachyCard` y `CachyFormCard` |
| `titleBarHeight` | `44` | Altura estándar de la barra de título / botones de semáforo |
| `trafficLightMargin` | `18` | Distancia desde el borde izquierdo de la ventana al primer botón del semáforo |

### Espaciados, Radios y Animaciones

| Token en `CachyTheme` | Valor | Propósito |
| :--- | :---: | :--- |
| `radiusWindow` | `20` | Radio de esquina unificado de las ventanas `CachyWindow` |
| `radiusLarge` | `16` | Contenedores amplios y hojas modales (`CachyDialog`) |
| `radiusMedium` | `12` | Tarjetas elevadas (`CachyCard`, `CachyFormCard`) |
| `radiusSmall` | `8` | Botones (`CachyButton`), campos de texto (`CachyTextField`), avisos e ítems laterales |
| `spacingTiny` | `4` | Separación mínima entre elementos íntimamente ligados |
| `spacingSmall` | `8` | Espaciado compacto en filas y formularios |
| `spacingMedium` | `12` | Espaciado estándar entre controles y tarjetas |
| `spacingLarge` | `16` | Espaciado entre bloques o secciones principales |
| `spacingHuge` | `24` | Separación amplia de bloques mayores |
| `animFast` | `180` | Duración en ms para microinteracciones de hover/foco |
| `animNormal` | `260` | Duración en ms para transiciones de estado e indicadores deslizantes |

### Superficies Liquid Glass e Identidad de Plataforma

| Propiedad / Método | Propósito |
| :--- | :--- |
| `glassOpacity` (`0.0` .. `1.0`) | Nivel de tinte del cristal (por defecto `0.5`, persistido en `~/.config/cachyosuirc`) |
| `windowBackground` | Color translúcido principal de la ventana interpolado según `glassOpacity` |
| `sidebarBackground` | Material translúcido ligeramente más profundo para barras laterales *edge-to-edge* |
| `cardBackground` / `cardBackgroundHover` | Superficie translúcida de tarjetas y su estado hover |
| `sheetBackground` | Material denso (`alpha 0.88–0.98`) para hojas modales (`CachyDialog`, `CachyDialogLayer`) y popovers legibles sobre cualquier fondo |
| `surfacePill` | Superficie translúcida para botones píldora (`CachyToolbarButton`) en barras de herramientas |
| `specularBorder` | Borde refractivo de `1 px` para ventanas, tarjetas y controles |
| `hardDividerColor` | Divisor estructural visible de `1 px` para barra de título y barra lateral |
| `distroName` / `desktopShell` | Identidad dinámica del sistema leída de `os-release` y `KCoreAddons` (p. ej. `"CachyOS"`, `"Plasma 6"`) |
| `iconUrl(name, fallback)` | Resuelve iconos simbólicos o escalables de Breeze / Hicolor a `file://...` sin dejar huecos visuales |

### Proporción de la ventana

La proporción (ancho ÷ alto) de una ventana es parte de la identidad visual del ecosistema y **debe ser homogénea entre aplicaciones**:

| Clase | Proporción | Medida de referencia |
| :--- | :---: | :--- |
| Ventana de herramienta (documento, lista, panel) | `1,33` – `1,50` | `880 × 640` (`windowWidthSettings`) |
| Utilidad flotante vertical | `0,87` | `540 × 620` (`windowWidthUtility`) |
| Teléfono / dialpad | `0,62` | `396 × 640` |

- **Prohibido** el formato panorámico (proporción `> 2`): una franja de `900 × 250` rompe la lectura del escritorio como conjunto y hace que la aplicación parezca un *banner* en lugar de una ventana.
- Cuando una aplicación original tenía una forma muy alargada (barra de subtítulos, panel de estado), se **redimensiona a la proporción canónica** y el espacio recuperado se llena con contenido real (historial, detalle, lista), nunca con vacío.

---

## 4. Superficies de Plasmoides (no-ventana)

Un plasmoide vive dentro de `plasmashell`, sobre una superficie que pinta
**Plasma**. El diseño es **idéntico** al de una aplicación (mismos colores,
radios, tipografía y formas de elemento); lo único que se ajusta es el
**espaciado**, porque el espacio disponible es mucho menor.

### 4.1 Quién pinta cada superficie

| Superficie | La pinta | Cómo se comporta |
| :--- | :--- | :--- |
| Ventana de aplicación | La propia app (`CachyWindow`) | Opaca y translúcida, con *blur* de KWin |
| Panel de Plasma | El tema de escritorio de Plasma | Transparente, deja ver el fondo de pantalla |
| Popup de un plasmoide | El tema de escritorio de Plasma | Translúcido, con *blur* y borde especular |

**Regla:** un plasmoide **no pinta su propio fondo opaco**. Plasma ya aporta
la superficie con *blur* de Golden Gate; taparla oculta el cristal y rompe la
estética. `CachyPlasmoidSurface` es transparente por defecto (`framed: false`).

### 4.2 Regla del color: la paleta efectiva, no la de la app

El color de primer plano debe describir **la superficie donde se dibuja**:

- En una aplicación, esa superficie la pinta la propia app → el color scheme
  de la aplicación.
- En un plasmoide, esa superficie la pinta Plasma → el **tema de escritorio**
  (su archivo `colors`).

`CachyTheme.isDark()` decide con `QStyleHints::colorScheme()`, que solo
refleja el segundo caso. Con el tema `macOS-GoldenGate` el tema de escritorio
es **siempre oscuro con primer plano blanco** (`ForegroundNormal=252,252,252`)
en todos sus grupos, de modo que usar `CachyTheme.textPrimary` en un
plasmoide produce **texto negro sobre superficie oscura**.

`CachyPalette` (singleton) resuelve la paleta efectiva y es la **única**
fuente de color de primer plano del ecosistema:

| Token | Uso |
| :--- | :--- |
| `CachyPalette.text` | Texto principal |
| `CachyPalette.textSecondary` | Etiquetas, cabeceras de columna, ayudas |
| `CachyPalette.textMuted` | Texto decorativo o deshabilitado |
| `CachyPalette.accentText` | Acento **como texto** (legible sobre la superficie) |
| `CachyPalette.cardBackground` | Superficie de tarjeta translúcida |
| `CachyPalette.specularBorder` | Borde refractivo de `1 px` |

Los tonos secundarios y atenuados se derivan del primario por opacidad, de
modo que conservan el tono de la superficie y **nunca** quedan por debajo del
contraste mínimo.

### 4.3 Iconos

`Kirigami.Icon` solo tiñe con `color` cuando `isMask: true`; sin ello, el
SVG se pinta con su clase `ColorScheme-Text` interna (`#232629`) y aparece
negro. `CachyPlasmoidIcon` resuelve el icono en el tema de Plasma (el
elegido por el usuario) y lo tiñe con el primer plano del anfitrión.

### 4.4 Métricas

| Contexto | Margen exterior | Espaciado de bloques | Padding de tarjeta | Radio de tarjeta |
| :--- | :---: | :---: | :---: | :---: |
| Ventana | `marginWindow` (18) | `spacingMedium` (12) | `marginCard` (14) | `radiusMedium` (12) |
| Plasmoide | `marginCard` (14) | `spacingSmall` (8) | `marginCard` (14) | `radiusSmall` (8) |

---

## 5. Tarjetas y Formularios Universales (`CachyCard` y familia `CachyForm*`)

- **Padding interno universal:** `14 px` (`CachyTheme.marginCard`) aplicado automáticamente en `CachyCard` y `CachyFormCard`.
- **Padding horizontal en delegados:** `CachyFormCheckDelegate`, `CachyFormTextFieldDelegate` y `CachyFormButtonDelegate` incluyen margen interno horizontal (`CachyTheme.spacingMedium`) para que el resaltado hover respire sin pegar el texto al borde.
- **Radio de curvatura:** `12 px` (`CachyTheme.radiusMedium`).
- **Borde de 1 px:** `CachyTheme.specularBorder`.
- **Fondo Liquid Glass:** `CachyTheme.cardBackground` con transición reactiva a `CachyTheme.cardBackgroundHover`.

---

## 6. Replicación Pixel-Perfect CachyOS / Liquid Glass

1. **Semáforo Vectorial Oficial (`CachyTrafficLights`):**
   - `13 px` de diámetro por botón, `8 px` de espacio entre círculos (`55 px` de ancho total), situado a `18 px` (`CachyTheme.marginWindow`) del borde izquierdo.
   - Glifos vectoriales trazados con `QtQuick.Shapes` (Cerrar `✕`, Minimizar `─`, Maximizar dos flechas diagonales opuestas `⤢`).
   - Efecto de revelación simultánea al pasar el ratón por la zona de los 3 botones y expansión elástica (`scale: 1.18` con `Easing.OutBack`) al presionar.
2. **Borde Especular Continuo de 1 px:**
   - La ventana dibuja sobre las esquinas de `20 px` un borde continuo de `1 px` con `specularBorder`.
3. **Desenfoque y Contraste Real Wayland (KWin):**
   - Manejado por `CachyWindowBlur` mediante `KWindowEffects::enableBlurBehind` y `enableBackgroundContrast` con una región poligonal redondeada (`QRegion`), asegurando cero artefactos en las esquinas bajo Wayland.
4. **Respuesta Táctil:**
   - Los botones tienen escala elástica al interactuar (`CachyButton`: `0.96` / `1.01`; `CachyToolbarButton`: `0.94` / `1.03`) sin superar la tolerancia (`2.0 px`) verificada por `LayoutAuditor`.
