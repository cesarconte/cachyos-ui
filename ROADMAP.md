# Plan Maestro de Evolución de `CachyOS.UI` (Arquitectura `FishUI` + Catálogo `Vuetify`)

Este documento define la hoja de ruta técnica detallada, dividida en **Fases y Pasos verificables**, para convertir **`CachyOS.UI`** en un framework completo de bloques preconstruidos («estilo Vuetify / Kirigami») con todas las optimizaciones de bajo nivel de **`FishUI` (`cutefishos/fishui`)** sobre **Qt 6 / C++23 / KWin Wayland**.

El objetivo es triple:
1. **Cero fricción al crear o migrar aplicaciones y plasmoides** (desde utilidades ligeras hasta aplicaciones complejas como *Dolphin* o *Transmission-Qt*): todos los componentes existen ya construidos, probados y estilizados.
2. **Consistencia visual absoluta (100% Liquid Glass / Golden Gate)** en ventanas, barras laterales, menús contextuales, pestañas, tablas, cuadrículas, diálogos y widgets del panel de Plasma.
3. **Máximo rendimiento y mínimo consumo de CPU, RAM y GPU**: sombras y desenfoque delegados al compositor KWin en C++, filtrado/ordenación en C++, iconos vectoriales tintados en el Scene Graph sin `Qt5Compat.GraphicalEffects` y cero bucles de *binding*.

---

## Fase 1: Núcleo C++ de Alto Rendimiento e Infraestructura (`FishUI` Core Parity) ✅ COMPLETADA

Sustituye soluciones pesadas en QML por primitivas nativas en C++23 y prepara el paquete para ser consumido tanto desde QML (`import CachyOS.UI`) como desde C++ (`find_package(CachyOSUI REQUIRED)`).

### Paso 1.1 — Sombras Nativas del Compositor KWin (`CachyWindowShadow`)
* **Inspiración:** `FishUI/src/platforms/linux/shadowhelper/windowshadow.*` y `boxshadowrenderer.*`.
* **Archivos a crear/modificar:**
  * `src/core/cachywindowshadow.h`
  * `src/core/cachywindowshadow.cpp`
  * `src/controls/CachyWindow.qml`
* **Implementación técnica:**
  * Propiedad adjunta QML (`CachyWindowShadow.enabled`, `CachyWindowShadow.radius`, `CachyWindowShadow.strength`).
  * Generación en memoria de las 9 texturas (`QImage`) del *nine-patch* de sombra Gaussiana con esquinas redondeadas (`cornerRadius`) y registro mediante `KWindowShadow` y `KWindowShadowTile` de `KF6::WindowSystem`.
  * **Beneficio:** KWin compone la sombra directamente en la GPU del compositor; la ventana QML no necesita márgenes extra ni shaders de sombra por fotograma (**0% coste de GPU/CPU en la aplicación**).

### Paso 1.2 — Motor C++ de Filtrado y Ordenación Reactivo (`CachySortFilterProxyModel`)
* **Inspiración:** `FishUI/src/qqmlsortfilterproxymodel.*`.
* **Archivos a crear:**
  * `src/core/cachysortfilterproxymodel.h`
  * `src/core/cachysortfilterproxymodel.cpp`
* **Implementación técnica:**
  * Subclase de `QSortFilterProxyModel` expuesta a QML (`QML_ELEMENT` como `CachySortFilterProxyModel`).
  * Propiedades reactivas listas para usar desde QML:
    * `sourceModel`: cualquier `QAbstractItemModel` o `ListModel`.
    * `filterText`: texto buscado (conectable directamente a `CachySearchField.text`).
    * `filterRoleName` / `filterCaseSensitivity`.
    * `sortRoleName` / `sortOrder` (`Qt.AscendingOrder` / `Qt.DescendingOrder`).
    * `count`: número de elementos visibles tras filtrar (con señal `countChanged`).
    * Método `Q_INVOKABLE QVariantMap get(int row) const` y `mapToSourceRow(int row)`.
  * **Beneficio:** Cualquier lista o tabla (archivos en *Dolphin*, torrents en *Transmission*, ajustes en *Control Center*) obtiene búsqueda instantánea y ordenación por columnas en C++ en **< 1 ms**.

### Paso 1.3 — Sistema de Iconos Vectoriales Embebidos y Renderizador Unificado (`CachyIcon`)
* **Inspiración:** `FishUI/data/icons/*`, `FishUI/src/controls/Icon.qml` y `newiconitem.*`.
* **Archivos a crear/modificar:**
  * `src/icons/cachyosui_icons.qrc` + colección SVG minimalista embebida (`chevron-left`, `chevron-right`, `chevron-up`, `chevron-down`, `close`, `search`, `clear`, `check`, `add`, `remove`, `refresh`, `folder`, `file`, `grid`, `list`, `info`, `warning`, `error`, `success`, `settings`, `pin`, `filter`, `sort-asc`, `sort-desc`, `more-horizontal`, `external-link`, `trash`, `download`, `upload`, `pause`, `play`).
  * `src/core/cachytheme.h` / `src/core/cachytheme.cpp`: hacer que `CachyTheme.iconUrl(name, fallback)` resuelva primero los iconos vectoriales internos (`qrc:/CachyOS/UI/icons/<name>.svg`) como prioridad o *fallback* universal infalible, y después el tema Breeze/Hicolor.
  * `src/controls/CachyIcon.qml`: componente ligero basado en `MultiEffect` (`colorization: 1.0`, `colorizationColor: root.color`) de Qt 6 nativo.
  * **Eliminación de `Qt5Compat.GraphicalEffects`:** migrar `CachyButton.qml` y `CachyToolbarButton.qml` para usar `CachyIcon`, eliminando por completo la dependencia heredada de Qt 5 (`qt6-5compat`) y eliminando todos los glifos/emojis Unicode (`🔍`, `✕`, `‹`, `›`) de los controles del sistema.

### Paso 1.4 — Exportación del Paquete CMake Principal (`CachyOSUIConfig.cmake`)
* **Inspiración:** `FishUIConfig.cmake.in` y `CutefishToolkitConfig.cmake.in`.
* **Archivos a crear/modificar:**
  * `src/CachyOSUIConfig.cmake.in`
  * `src/CMakeLists.txt`
* **Implementación técnica:**
  * Instalar las cabeceras públicas (`cachytheme.h`, `cachyi18n.h`, `cachywindowblur.h`, `cachywindowshadow.h`, `cachysortfilterproxymodel.h`) en `${KDE_INSTALL_INCLUDEDIR}/CachyOSUI`.
  * Exportar el target `CachyOSUI::cachyosui` en `${KDE_INSTALL_LIBDIR}/cmake/CachyOSUI`.
  * **Beneficio:** Aplicaciones C++/Qt existentes (como *Transmission-Qt* o *Dolphin*) pueden enlazar `CachyOSUI::cachyosui` directamente en CMake.

### Paso 1.5 — Tests Unitarios de la Fase 1
* **Archivos a crear/modificar:**
  * `tests/test_core_components.cpp`
  * `tests/CMakeLists.txt`
* **Verificación:**
  * Test de `CachySortFilterProxyModel` (filtrado por texto, insensibilidad a mayúsculas, ordenación ascendente/descendente, `count` y mapeo de filas).
  * Test de resolución de iconos embebidos y de sistema en `CachyTheme::iconUrl`.
  * Test de instanciación de `CachyIcon` y `CachyWindowShadow` en modo *offscreen* sin errores ni advertencias QML.

---

## Fase 2: Controles de Formulario, Selección, Menús y Pestañas (`FishUI` Controls Parity) ✅ COMPLETADA

Completa el repertorio de controles interactivos individuales para que ningún formulario, barra de herramientas o diálogo necesite controles externos.

### Paso 2.1 — Controles de Selección y Entrada (`CheckBox`, `RadioButton`, `ComboBox`, `SpinBox`, `TextArea`)
* **Archivos a crear en `src/controls/`:**
  1. **`CachyCheckBox.qml`**: Casilla de verificación *squircle* (`radius: 5`), relleno animado con `CachyTheme.accentColor`, trazo vectorial de confirmación (`check`) y etiqueta integrada con `wrapMode: Text.WordWrap`.
  2. **`CachyRadioButton.qml`**: Botón de opción circular con anillo exterior especular, punto interior animado con `Easing.OutBack` y soporte automático de exclusividad (`ButtonGroup`).
  3. **`CachyComboBox.qml`** + **`CachyFormComboBoxDelegate.qml`**: Selector desplegable Liquid Glass con flecha `chevron-down`, popup flotante con `CachyTheme.sheetBackground`, `specularBorder` y marca `check` en la opción activa, más su versión delegada para `CachyFormCard`.
  4. **`CachySpinBox.qml`** + **`CachyFormSpinBoxDelegate.qml`**: Control numérico (`from`, `to`, `value`, `stepSize`, `suffix`, `prefix`) con botones `-` / `+` integrados en píldora y edición directa por teclado.
  5. **`CachyTextArea.qml`**: Campo de texto multilínea con `Flickable`/`ScrollBar` integrado, contador opcional de caracteres y borde reactivo al foco idéntico a `CachyTextField`.

### Paso 2.2 — Menús Contextuales, Notificaciones No Intrusivas y Estados (`Menu`, `Toast`, `BusyIndicator`, `Badge`, `Tooltip`)
* **Archivos a crear en `src/controls/`:**
  1. **`CachyMenu.qml`** + **`CachyMenuItem.qml`** + **`CachyMenuSeparator.qml`**: Menú emergente y contextual (clic derecho) con superficie `sheetBackground`, borde especular, soporte de icono izquierdo (`iconName`), texto de atajo de teclado a la derecha (`shortcutText`), estado destructivo (en rojo para «Eliminar» / «Mover a la papelera») y casilla `checkable`.
  2. **`CachyToast.qml`**: Píldora flotante no intrusiva (`show(message, type, duration)`) con variantes `info`, `success`, `warning` y `error`, icono automático y animación de entrada/salida suave en la parte superior o inferior de la ventana.
  3. **`CachyBusyIndicator.qml`**: Indicador de actividad vectorial continuo en GPU, con propiedad `running` y tamaño escalable (`small`, `medium`, `large`).
  4. **`CachyBadge.qml`** (o Chip): Etiqueta en píldora compacta para estados («Activo», «Sembrando», «Error», contadores numéricos) con variantes semánticas (`neutral`, `accent`, `success`, `warning`, `error`) y botón opcional de cierre (`closable`).
  5. **`CachyTooltip.qml`**: Globo emergente estilizado con `sheetBackground` y `specularBorder` para descripciones rápidas al pasar el ratón.

### Paso 2.3 — Navegación de Ventana y Pestañas (`TabBar`, `TabButton`, `TabView`, `NavigationButtons`, `BreadcrumbBar`)
* **Archivos a crear en `src/controls/`:**
  1. **`CachyTabBar.qml`** + **`CachyTabButton.qml`** + **`CachyTabView.qml`**: Barra de pestañas de documentos inspirada en `FishUI/TabBar.qml` y `window_tab_bar.cpp`, con pestañas cerrables (`closable`), icono opcional, botón `+` para nueva pestaña y contenedor de vistas sincronizado.
  2. **`CachyNavigationButtons.qml`**: Píldora canónica `< | >` para `headerLeading` de `CachyWindow` con propiedades `canGoBack`, `canGoForward` y señales `backClicked()`, `forwardClicked()`.
  3. **`CachyBreadcrumbBar.qml`**: Barra de ruta interactiva (ej. `/ > home > cesar > Descargas`) con segmentos clicables, separadores `chevron-right` y colapso automático cuando la ventana se estrecha.

### Paso 2.4 — Tests y Auditoría de Layout de la Fase 2
* Verificar todos los controles nuevos de la Fase 2 con `ctest` y `LayoutAuditor` (cero `Protrusion`, cero `TextClipping`, cero bucles de *binding*).

---

## Fase 3: Bloques de Alto Nivel «Estilo Vuetify» (Para *Dolphin*, *Transmission* y Plasmoides) ✅ COMPLETADA

Proporciona los bloques estructurales completos para armar gestores de archivos, clientes de descargas, monitores de sistema y widgets de escritorio en pocas líneas de QML.

### Paso 3.1 — Vistas de Datos: Listas Ricas, Cuadrículas y Tablas Ordenables
* **Archivos a crear en `src/controls/`:**
  1. **`CachyListItem.qml`**: Fila universal todoterreno para `ListView` (inspirada en `v-list-item` de Vuetify). Soporta:
     * `iconName` / `iconColor` o avatar izquierdo.
     * `title`, `subtitle` y `statusText` (con `Layout.minimumWidth: 0` garantizado).
     * `progressValue` (`-1` oculto, `0.0..1.0` muestra un `CachyProgressBar` integrado debajo del título: ideal para *Transmission* o gestores de descargas).
     * `badgeText` / `badgeType` y slot `trailingActions` (botones rápidos que aparecen en hover o siempre visibles).
     * Selección simple/múltiple y señal `contextMenuRequested(real x, real y)` con clic derecho.
  2. **`CachyGridItem.qml`**: Celda universal para `GridView` (inspirada en `fishui/cell_layout.cpp`). Soporta icono o miniatura (`thumbnailSource`), insignia superpuesta, selección redondeada translúcida y etiqueta de hasta 2 líneas con `Text.ElideMiddle` (base directa para la vista de iconos de *Dolphin*).
  3. **`CachyTableHeader.qml`**: Cabecera de tabla interactiva con columnas definidas por modelo (`[{ role: "name", title: "Nombre", width: 240 }, ...]`), indicador de ordenación (`sortRole`, `sortOrder`) conectable en 1 línea a `CachySortFilterProxyModel`, y divisores sutiles.

### Paso 3.2 — Contenedores de Aplicación: SplitView, Zona Drag & Drop y Barra de Estado
* **Archivos a crear en `src/controls/`:**
  1. **`CachySplitView.qml`**: Paneles divididos horizontales o verticales (basado en `T.SplitView`) con manejador de `1 px` (`hardDividerColor`) que se ilumina con `accentColor` al arrastrar (imprescindible para vista doble en *Dolphin* o panel de detalles en *Transmission*).
  2. **`CachyFileDropArea.qml`**: Contenedor reactivo de arrastrar y soltar archivos/URLs (`onFilesDropped(list<url> urls)`), con filtro opcional de extensiones (`acceptedExtensions: ["torrent", "magnet"]`) y superposición visual translúcida automática mientras el usuario arrastra archivos sobre la ventana.
  3. **`CachyStatusBar.qml`**: Barra inferior canónica de `28 px` con divisor superior duro de `1 px`, texto de resumen izquierdo (`summaryText`, ej. «24 elementos • 142 GB disponibles»), slot central/derecho para indicadores de velocidad o zoom (ej. deslizador de tamaño de iconos en *Dolphin* o velocidades `↓ 12.4 MB/s ↑ 1.8 MB/s` en *Transmission*).

### Paso 3.3 — Superficie Estándar para Plasmoides (`CachyPlasmoidSurface`) y Estilo Automático (`CachyStyle`)

* **Estado:** ✅ COMPLETADO. El componente se llama `CachyPlasmoidSurface` y la
  paleta efectiva se expone en el singleton `CachyPalette`.
* **Archivos implementados:**
  1. **`src/controls/CachyPlasmoidSurface.qml`**: Contenedor raíz para applets/plasmoides de KDE Plasma (que no usan `CachyWindow`). Proporciona cabecera compacta con título, subtítulo y acciones, área de contenido con `marginCard` y pie opcional. Es **transparente por defecto** (`framed: false`): el anfitrión (Plasma) ya pinta la superficie con su *blur* de Golden Gate y el plasmoide no debe taparla.
  2. **`src/controls/CachyPlasmoidIcon.qml`**: Icono de plasmoide resuelto en el tema de iconos de Plasma y teñido con el primer plano del anfitrión (`isMask: true`). Sustituye tanto a `Kirigami.Icon` sin `isMask` (que se pinta negro con su `ColorScheme-Text` interna) como a `CachyIcon` (que ignora el tema de iconos elegido por el usuario).
  3. **`src/controls/CachyPalette.qml`**: Singleton QML con la paleta **efectiva** de la superficie real (`text`, `textSecondary`, `textMuted`, `accentText`, `isDark`, `cardBackground`, `surfacePill`, `windowBackground`, `sheetBackground`, `specularBorder`, `hardDividerColor`, `dividerColor`). Resuelve la causa raíz del «texto negro sobre popup oscuro»: `CachyTheme.isDark()` decide con `QStyleHints::colorScheme()` (color scheme de la app), mientras que el chrome del panel lo pinta el tema de escritorio de Plasma, que con Golden Gate es siempre oscuro con primer plano blanco.
  4. **`src/core/cachytheme.h`**: tokens semánticos `successColor` (`#34C759`), `warningColor` (`#FF9500`) y `errorColor` (`#FF3B30`), para que ningún plasmoid escriba literales de estado.
* **Documentación:** `MIGRATION_GUIDE.md` §3 (receta de migración de plasmoides con tabla de equivalencias y checklist propio) y `DESIGN_SYSTEM.md` §4 (superficies de plasmoides, quién pinta cada una, regla del color y métricas).
* **Regla de estética unificada:** el diseño de plasmoides y aplicaciones es **idéntico** (mismos colores, radios, tipografía y formas de elemento); solo cambia el **espaciado** (margen `14` frente a `18`, y `spacingSmall` frente a `spacingMedium`), porque un applet dispone de mucho menos espacio.
* **Puente de Estilo para `QtQuick.Controls`**: cada control de `CachyOS.UI` funciona como reemplazo 1:1 de `QtQuick.Controls` con la misma API (`text`, `checked`, `value`, `model`, `currentIndex`, `onClicked`, `onToggled`) para que migrar código QML existente sea mecánico.

### Paso 3.4 — Tests y Auditoría de Layout de la Fase 3
* Tests unitarios y de `LayoutAuditor` montando una escena tipo *Gestor de Archivos (Dolphin)* y una escena tipo *Cliente de Descargas (Transmission)* usando los nuevos bloques en tamaños mínimo, estándar y panorámico.

---

## Fase 4: Galería Interactiva «Catálogo Vuetify», Modo `--capture` y Documentación ✅ COMPLETADA Viva

Convierte `cachyos-ui-gallery` en el escaparate interactivo completo de todos los componentes y añade la verificación visual automatizada de `cutefishos/fishui`.

### Paso 4.1 — Rediseño Completo de `cachyos-ui-gallery` por Categorías
* **Archivos a modificar:**
  * `gallery/GalleryWindow.qml`
  * `gallery/main.cpp`
* **Secciones navegables desde el `sidebar` de la galería:**
  1. **Apariencia & Liquid Glass**: Calibrador `glassOpacity` en vivo (`0%..100%`), tokens de color y superficies.
  2. **Botones, Selección & Entradas**: `CachyButton`, `CachyToolbarButton`, `CachySegmentedControl`, `CachySwitch`, `CachyCheckBox`, `CachyRadioButton`, `CachyComboBox`, `CachySpinBox`, `CachySlider`, `CachyTextField`, `CachySearchField`, `CachyTextArea`.
  3. **Navegación & Pestañas**: `CachyTabBar` / `CachyTabView`, `CachyBreadcrumbBar`, `CachyNavigationButtons`, `CachyPageStack`.
  4. **Listas, Cuadrículas & Archivos (Demo Dolphin / Transmission)**: `CachyListItem` con progreso en vivo + filtro instantáneo con `CachySortFilterProxyModel`, `CachyGridItem`, `CachyTableHeader`, `CachyFileDropArea`, `CachySplitView`, `CachyStatusBar`.
  5. **Formularios (`CachyFormCard`)**: Todos los delegados (`Check`, `TextField`, `ComboBox`, `SpinBox`, `Button`).
  6. **Diálogos, Menús & Feedback**: `CachyDialog`, `CachyMenu`, `CachyToast`, `CachyInlineMessage`, `CachyPlaceholderMessage`, `CachyBadge`, `CachyBusyIndicator`, `CachyAboutPage`.

### Paso 4.2 — Modo Headless `--capture` y Auditoría Integral en `ctest`
* **Inspiración:** `cutefishos/fishui/examples/gallery/main.cpp` (`--capture=<dir>`).
* **Implementación técnica:**
  * Añadir soporte de línea de comandos `--audit` y `--capture=<directorio>` a `cachyos-ui-gallery`.
  * En modo `--audit`, recorre automáticamente todas las secciones de la galería en 3 resoluciones (`minimum`, `default`, `wide`), ejecuta `LayoutAuditor::audit()` en cada una y falla con código `!= 0` si algún componente presenta el más mínimo desborde o recorte de texto.
  * Registrar `cachyos-ui-gallery --audit` como test oficial dentro de `ctest`.

### Paso 4.3 — Actualización Final de Documentación (`README.md`, `DESIGN_SYSTEM.md`, `MIGRATION_GUIDE.md`) y Push a GitHub
* Documentar todos los nuevos componentes con tablas de propiedades y recetas listas para copiar y pegar (receta de ventana tipo *Dolphin*, receta de lista con filtro tipo *Transmission*, receta de *Plasmoide*).
