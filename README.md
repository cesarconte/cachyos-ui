# CachyOS UI (`cachyos-ui`) 🧊

> **Framework de interfaz gráfica nativo, réplica pixel-perfect del lenguaje de diseño mac OS y sistema de diseño Liquid Glass para CachyOS Linux.**

`cachyos-ui` proporciona una biblioteca de controles declarativos ultrarrápidos y unificados sobre **Qt 6** y **C++23**, integrados a nivel de kernel y compositor con **KWin 6 Wayland** y **KDE Frameworks 6**.

Inspirado en la filosofía de desacoplamiento de **Cutefish OS (`fishui`)**, `cachyos-ui` elimina la disparidad visual entre aplicaciones, sustituye por completo la dependencia de `Kirigami` / `KirigamiAddons.FormCard` y descarta el bloatware web (cero WebViews / Electron). Toda la aceleración gráfica se ejecuta directamente sobre GPU mediante **Qt Quick Scene Graph (RHI / Vulkan)**.

---

## 💎 Características Principales

- **Física y Geometría Pixel-Perfect (Golden Gate / Liquid Glass)**:
  - Esquinas continuas de ventana (`20px`, `CachyTheme.radiusWindow`) con máscara `MultiEffect` para barras laterales *edge-to-edge*.
  - Botones de semáforo vectoriales interactivos (`#FF5F56`, `#FFBD2E`, `#27C93F`) con brillo especular, revelación simultánea de glifos y expansión elástica al pulsar.
  - Cabecera canónica de `44px` con banda de título autoajustada libre de colisiones entre grupos (`headerLeading`, `headerCenter`, `headerActions`) y divisor duro de `1px`.
  - Redimensionado universal por bordes y esquinas nativo sobre Wayland (`startSystemResize` / `startSystemMove`).
- **Efecto Liquid Glass & KWin Blur**:
  - Integración nativa con `KWindowEffects` (`CachyWindowBlur`) para solicitar regiones vectoriales redondeadas de desenfoque (*blur behind*) y contraste directo al compositor KWin en Wayland.
  - Control reactivo de opacidad (`CachyTheme.glassOpacity`, persistido en `~/.config/cachyosuirc`) que interpola en tiempo real desde *Glassiest (`0.0`)* hasta *Maximum Tint (`1.0`)* pasando por *Medium Glassy (`0.5`)*.
  - Bordes especulares perimetrales (*specular rim*) adaptados dinámicamente a temas claro y oscuro.
- **Internacionalización e Iconografía sin Fallos**:
  - Singleton `CachyI18n` conectado directamente a `KLocalizedString` (`i18n`, `i18nc`, `i18d`) con soporte de marcadores `%1..%3` y fallback garantizado al texto fuente sin marcadores `(I18N_EMPTY_MESSAGE)`.
  - Resolución automática de iconos simbólicos y escalables de Breeze / Hicolor (`CachyTheme.iconUrl(name, fallback)`) coloreados dinámicamente según el tema.
- **Auditoría Automatizada de Layout (`CachyOSUITesting`)**:
  - Biblioteca CMake reutilizable (`LayoutAuditor`) que analiza el árbol `QQuickItem` en tests *offscreen* y detecta automáticamente desbordamientos (`Protrusion`), salidas de ventana (`OutOfWindow`), recortes de texto sin elipsis (`TextClipping`) y solapamientos en la barra de título (`HeaderOverlap`).

---

## 📦 Catálogo Completo del Sistema (`CachyOS.UI 1.0`)

### Núcleo C++ (`src/core/`)

| Componente | Tipo | Descripción |
| :--- | :---: | :--- |
| **`CachyTheme`** | Singleton C++ | Tokens de color reactivos (`windowBackground`, `sidebarBackground`, `cardBackground`, `sheetBackground`, `surfacePill`, `specularBorder`, `hardDividerColor`), `glassOpacity`, métricas canónicas, identidad de plataforma (`distroName`, `desktopShell`), iconos vectoriales embebidos (`iconUrl`) y resolución de iconos del sistema. |
| **`CachyI18n`** | Singleton C++ | Traducción segura sobre `KLocalizedString` (`i18n`, `i18nc`, `i18d`) con sustitución de argumentos y fallback limpio al texto original. |
| **`CachyWindowBlur`** | Attached QML | Propiedad adjunta (`CachyWindowBlur.enabled`) que registra la máscara poligonal redondeada ante `KWindowEffects` para blur y contraste en KWin Wayland. |
| **`CachyWindowShadow`** | Attached QML | Propiedad adjunta (`CachyWindowShadow.enabled`) que genera un *nine-patch* de sombra Gaussiana en C++ y la delega a `KWindowShadow` de KWin (coste 0 en QML). |
| **`CachySortFilterProxyModel`** | Clase QML (C++) | Motor de filtrado y ordenación instantáneo (`< 1 ms`) conectable a cualquier `ListView`, `GridView` o `TableView`. |
| **`CachyPalette`** | Singleton QML | Paleta de colores efectiva de la superficie sobre la que se pinta el contenido (tema Plasma o de aplicación). |

### Ventana, Navegación y Páginas (`src/controls/`)

| Componente | Descripción |
| :--- | :--- |
| **`CachyWindow`** | Ventana frameless Liquid Glass con barra lateral *edge-to-edge* opcional, barra de título de `44px`, semáforo, slots de cabecera (`headerLeading`, `headerCenter`, `headerActions`), capa `overlay` y resize Wayland en 8 direcciones. |
| **`CachyTrafficLights`** | Semáforo vectorial (Cerrar, Minimizar, Maximizar) con gradiente cristalino y animación elástica. |
| **`CachySidebarItem`** | Elemento de barra lateral con insignia *squircle* coloreada, icono vectorial `CachyIcon` o glifo, etiqueta en negrita al seleccionar y contador opcional. |
| **`CachyPageStack`** | Pila de navegación de páginas (`push`, `pop`, `removePage`, `clear`, `get`, `depth`, `currentIndex`, `initialPage`, `pushDialogLayer`) independiente de Kirigami. |
| **`CachyScrollablePage`** | Página desplazable con bandas superiores (`header`) e inferiores (`footer`) con divisores automáticos y adaptación de `Flickable`/`ListView`. |
| **`CachyDialogLayer`** | Capa modal integrada en `CachyPageStack` con fondo sólido (`sheetBackground`) y *scrim* para apilar diálogos sobre el contenido. |
| **`CachyDialog`** | Diálogo modal superpuesto con tarjeta elevada, título, subtítulo, cuerpo personalizable y acciones de pie. |
| **`CachyAboutPage`** | Página modal «Acerca de» con icono de aplicación, versión, descripción seleccionable y tarjetas de enlaces externos. |
| **`CachyTabButton` / `CachyTabBar` / `CachyTabView`** | Pestañas de documentos cerrables con botón `+` de nueva pestaña y contenedor de vistas sincronizado. |
| **`CachyNavigationButtons`** | Píldora canónica `< | >` para `headerLeading` con propiedades `canGoBack` / `canGoForward`. |
| **`CachyBreadcrumbBar`** | Barra de ruta interactiva (`/ > home > cesar > ...`) con segmentos clicables para gestores de archivos. |

### Controles Interactivos y Superficies (`src/controls/`)

| Componente | Descripción |
| :--- | :--- |
| **`CachyCard`** | Superficie translúcida Liquid Glass (`radiusMedium: 12px`, `marginCard: 14px`) con borde especular y modo interactivo (`hover` + `clicked`). |
| **`CachyButton`** | Botón redondeado con soporte de iconos coloreados y variantes `default`, `primary`, `destructive` y `flat`. |
| **`CachyToolbarButton`** | Botón de barra de herramientas en formato píldora (`surfacePill`) con icono Breeze coloreado, tooltip, estado `checkable` sin ruptura de bindings (`toggled(bool)`) y modo `primary`. |
| **`CachySegmentedControl`** | Selector segmentado con píldora deslizante animada y cálculo de métricas fuera de pantalla libre de bucles de binding. |
| **`CachySwitch`** | Interruptor toggle elástico con transición de color (`#34C759`), animación `OutBack` y modo `interactive` desacoplable para filas de formulario. |
| **`CachySlider`** | Control deslizante continuo con track cilíndrico translúcido y pulgar con respuesta elástica. |
| **`CachyTextField`** | Campo de texto con borde de foco reactivo, icono izquierdo opcional y botón rápido de borrado (`clear`). |
| **`CachySearchField`** | Campo de búsqueda especializado con icono de lupa, limpieza rápida y vaciado con tecla `Escape`. |
| **`CachyProgressBar`** | Barra de progreso estilizada con animación continua para modos determinado e indeterminado. |
| **`CachyDivider`** | Separador horizontal o vertical de `1px` con soporte de sangría (`inset`). |
| **`CachyCheckBox`** | Casilla de verificación *squircle* animada con trazo `check` vectorial elástico. |
| **`CachyRadioButton`** | Botón de opción circular con punto interior animado y grupo exclusivo. |
| **`CachyComboBox` / `CachyFormComboBoxDelegate`** | Selector desplegable Liquid Glass con popup `sheetBackground` y marca `check` en la opción activa. |
| **`CachySpinBox` / `CachyFormSpinBoxDelegate`** | Selector numérico (`- | valor | +`) con entrada directa por teclado. |
| **`CachyTextArea`** | Campo de texto multilínea con recorte seguro y foco reactivo. |
| **`CachyMenu` / `CachyMenuItem` / `CachyMenuSeparator`** | Menús contextuales y desplegables con iconos, atajos de teclado y acciones destructivas. |
| **`CachyToast`** | Notificación flotante no intrusiva (`show(message, type, timeoutMs)`) con variantes `info`, `success`, `warning`, `error`. |
| **`CachyBusyIndicator`** | Indicador de carga vectorial continuo en GPU. |
| **`CachyBadge`** | Píldoras/chips de estado (`neutral`, `accent`, `success`, `warning`, `error`) con icono y cierre opcional. |
| **`CachyTooltip`** | Globo de ayuda emergente con `sheetBackground` y `specularBorder`. |
| **`CachyIcon`** | Icono vectorial unificado basado en `MultiEffect` (tintado en GPU, sin `Qt5Compat`). |

### Plasmoides y Paleta Efectiva (`src/controls/`)

| Componente | Descripción |
| :--- | :--- |
| **`CachyPalette`** | Singleton QML con la paleta **efectiva** de la superficie real: `text`, `textSecondary`, `textMuted`, `accentText`, `isDark` y todas las superficies translúcidas. Dentro de una app coincide con `CachyTheme`; dentro de `plasmashell` sigue el tema de escritorio de Plasma (blanco sobre oscuro con Golden Gate), lo que garantiza el contraste en ambos casos. |
| **`CachyPlasmoidSurface`** | Raíz canónica de un plasmoide: transparente por defecto (el anfitrión pinta el fondo con *blur*), cabecera compacta con título, subtítulo y acciones, cuerpo y pie opcional. |
| **`CachyPlasmoidIcon`** | Icono de plasmoide resuelto en el tema de iconos de Plasma y teñido con el primer plano del anfitrión (`isMask`), para que siga el Tema Automático y sea legible en el panel. |

### Bloques de Alto Nivel para Aplicaciones Complejas (`src/controls/`)

| Componente | Descripción |
| :--- | :--- |
| **`CachyListItem`** | Fila universal para listas (`title`, `subtitle`, `statusText`, icono/badge, `progressValue` inline con `CachyProgressBar`, acciones en hover y clic derecho). |
| **`CachyGridItem`** | Celda universal para vistas de iconos/miniaturas con selección redondeada, insignia superpuesta y etiqueta de 2 líneas. |
| **`CachyTableHeader`** | Cabecera de tabla con columnas ordenables (`sortRequested`) conectable en 1 línea a `CachySortFilterProxyModel`. |
| **`CachySplitView`** | Paneles divididos horizontales/verticales con manejador de `1 px` que se ilumina al arrastrar. |
| **`CachyFileDropArea`** | Contenedor reactivo de arrastrar y soltar archivos/URLs con filtro de extensiones y superposición visual automática. |
| **`CachyStatusBar`** | Barra de estado inferior de `28 px` para resúmenes de espacio, conteo de archivos o velocidades `↓ / ↑`. |
| **`CachyPlasmoidSurface`** | Contenedor raíz preconstruido para applets/plasmoides de KDE Plasma con header compacto, body y footer. |
| **`CachyPlasmoidIcon`** | Icono de plasmoide con tintado dinámico y tamaño configurable. |

### Tipografía, Mensajes y Formularios (`src/controls/`)

| Componente | Descripción |
| :--- | :--- |
| **`CachyHeading`** | Encabezado tipográfico semántico con 5 niveles de escala (`level: 1..5`) y truncamiento seguro. |
| **`CachySectionHeader`** | Encabezado compacto en seminegrita atenuada para agrupar secciones de listas o paneles. |
| **`CachySelectableLabel`** | Etiqueta de texto de solo lectura seleccionable con ratón y teclado. |
| **`CachyIconTitleSubtitle`** | Elemento de lista interactivo con icono temático, título principal, subtítulo secundario y estado seleccionado. |
| **`CachyInlineMessage`** | Aviso contextual integrado con icono y código de color semántico (`information`, `warning`, `error`). |
| **`CachyPlaceholderMessage`** | Estado vacío centrado con insignia circular de icono, mensaje explicativo, contenido extra y botón de acción (`helpfulAction`). |
| **`CachyFormCardPage`** | Página desplazable optimizada para columnas de tarjetas de configuración (`CachyFormCard`). |
| **`CachyFormCard`** | Tarjeta agrupadora para filas y delegados de formularios de preferencias. |
| **`CachyFormHeader`** | Título de sección para grupos de tarjetas de formulario. |
| **`CachyFormLayout`** | Layout vertical con espaciado canónico para formularios de configuración. |
| **`CachyFormCheckDelegate`** | Fila de formulario interactiva con etiqueta multi-línea y `CachySwitch` sincronizado. |
| **`CachyFormTextFieldDelegate`** | Fila de formulario con etiqueta lateral y `CachyTextField` integrado. |
| **`CachyFormButtonDelegate`** | Fila de formulario clicable con icono opcional y resaltado hover. |
| **`CachyFormDelegateSeparator`** | Separador horizontal de ancho completo entre delegados de un `CachyFormCard`. |

### Auditoría y Testing (`testing/`)

| Paquete CMake / Clase | Descripción |
| :--- | :--- |
| **`CachyOSUITesting::CachyOSUITesting`** (`LayoutAuditor`) | Auditor estático de árboles `QQuickItem` que verifica 4 reglas geométricas (`Protrusion`, `OutOfWindow`, `TextClipping`, `HeaderOverlap`) con tolerancia para animaciones elásticas (`2.0px`) y exclusión inteligente de áreas desplazables. |

---

## 🛠️ Requisitos del Sistema

- **Distribución:** CachyOS Linux (o Arch Linux).
- **Entorno:** KDE Plasma 6 sobre Wayland.
- **Compilador:** GCC 14+ o Clang 18+ (C++23 habilitado).
- **Librerías:** `qt6-base`, `qt6-declarative`, `qt6-5compat`, `qt6-shadertools`, `extra-cmake-modules`, `kwindowsystem`, `kcoreaddons`, `ki18n`.

---

## 🚀 Compilación, Tests y Galería de Componentes

### 1. Compilación manual
```bash
git clone https://github.com/cesarconte/cachyos-ui.git
cd cachyos-ui
cmake -B build -S . -DCMAKE_BUILD_TYPE=Release
cmake --build build -j"$(nproc)"
```

### 2. Ejecutar la suite de tests (`ctest`)
```bash
ctest --test-dir build --output-on-failure
```

### 3. Ejecutar la galería interactiva
Prueba los componentes y el deslizador de opacidad Liquid Glass en vivo bajo Wayland:
```bash
./build/bin/cachyos-ui-gallery
```

### 4. Instalación en el sistema o en `~/.local`
```bash
# Instalación global (/usr):
./install.sh

# Instalación en el directorio de usuario (~/.local):
cmake -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/
cmake --build build -j"$(nproc)"
DESTDIR=$HOME/.local cmake --install build

# O mediante PKGBUILD en Arch/CachyOS:
cd packaging && makepkg -si
```

---

## 💻 Uso en Aplicaciones

Cualquier aplicación del ecosistema importa `CachyOS.UI` directamente:

```qml
import QtQuick
import QtQuick.Layouts
import CachyOS.UI

CachyWindow {
    title: CachyI18n.i18n("Mi Aplicación")
    width: CachyTheme.windowWidthUtility
    height: CachyTheme.windowHeightUtility
    contentPadded: true

    ColumnLayout {
        anchors.fill: parent
        spacing: CachyTheme.spacingMedium

        CachyCard {
            Layout.fillWidth: true

            contentItem: RowLayout {
                spacing: CachyTheme.spacingMedium

                Text {
                    text: CachyI18n.i18n("Activar Aceleración BORE")
                    color: CachyTheme.textPrimary
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    wrapMode: Text.WordWrap
                }

                CachySwitch {
                    checked: true
                }
            }
        }

        CachySlider {
            Layout.fillWidth: true
            from: 0
            to: 100
            value: 80
        }

        CachyButton {
            text: CachyI18n.i18n("Aplicar Cambios")
            primary: true
            Layout.alignment: Qt.AlignRight
        }
    }
}
```

---

## 📚 Documentación Adicional

- [**`DESIGN_SYSTEM.md`**](./DESIGN_SYSTEM.md): Principios arquitectónicos, tokens métricos de `CachyTheme`, proporciones canónicas de ventana y reglas contra desbordamientos y recortes.
- [**`MIGRATION_GUIDE.md`**](./MIGRATION_GUIDE.md): Guía paso a paso para migrar aplicaciones de Kirigami / Qt Quick a `CachyOS.UI` y configurar la auditoría automatizada con `CachyOSUITesting`.

---

## 🗺️ Hoja de Ruta (Roadmap)

- [x] Arquitectura base C++23 con `qt_add_qml_module` y CMake.
- [x] Módulo `CachyOS.UI 1.0` con KWin Wayland Blur integrado (`CachyWindowBlur`).
- [x] Componentes maestros (`CachyWindow`, `CachyCard`, `CachySlider`, `CachySwitch`, `CachyButton`, `CachySegmentedControl`, `CachyToolbarButton`, `CachySidebarItem`, `CachyTextField`, `CachySearchField`, `CachyProgressBar`, `CachyDivider`).
- [x] Familia completa de navegación, páginas, diálogos y formularios (`CachyPageStack`, `CachyDialogLayer`, `CachyScrollablePage`, `CachyDialog`, `CachyAboutPage`, `CachyFormCardPage`, `CachyFormCard`, `CachyFormCheckDelegate`, `CachyFormTextFieldDelegate`, `CachyFormButtonDelegate`, `CachyHeading`, `CachyPlaceholderMessage`, `CachyInlineMessage`).
- [x] Controles de selección y entrada (`CachyCheckBox`, `CachyRadioButton`, `CachyComboBox`, `CachyFormComboBoxDelegate`, `CachySpinBox`, `CachyFormSpinBoxDelegate`, `CachyTextArea`).
- [x] Menús contextuales, notificaciones y estados (`CachyMenu`, `CachyMenuItem`, `CachyMenuSeparator`, `CachyToast`, `CachyBusyIndicator`, `CachyBadge`, `CachyTooltip`).
- [x] Navegación de ventana y pestañas (`CachyTabButton`, `CachyTabBar`, `CachyTabView`, `CachyNavigationButtons`, `CachyBreadcrumbBar`).
- [x] Bloques de alto nivel para aplicaciones complejas (`CachyListItem`, `CachyGridItem`, `CachyTableHeader`, `CachySplitView`, `CachyFileDropArea`, `CachyStatusBar`, `CachyPlasmoidSurface`, `CachyPlasmoidIcon`, `CachyPalette`).
- [x] Iconos vectoriales embebidos (`CachyIcon` + 37 SVG) y sombras de compositor nativas (`CachyWindowShadow`).
- [x] Motor C++ de filtrado y ordenación instantáneo (`CachySortFilterProxyModel`).
- [x] Internacionalización robusta (`CachyI18n`) y resolución de iconos del sistema (`CachyTheme.iconUrl`).
- [x] Librería de auditoría geométrica automatizada (`CachyOSUITesting` / `LayoutAuditor`) y suite de tests con `ctest`.
- [x] Galería interactiva `cachyos-ui-gallery`.
- [x] Paquete `PKGBUILD` y scripts de instalación limpia.
- [x] Migración de las aplicaciones de `Proyectos/` (`kiri`, `kisland`, `plasma-control-center`, `kpeek`, etc.) a `CachyOS.UI`.
- [ ] Instalador visual GUI unificado con selector modular de componentes para instalaciones nuevas de CachyOS.
