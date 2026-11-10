# CachyOS UI (`cachyos-ui`) 🧊

> **Framework de interfaz gráfica nativo, réplica pixel-perfect de macOS Golden Gate y sistema de diseño Liquid Glass para CachyOS Linux.**

`cachyos-ui` proporciona una biblioteca de controles declarativos ultrarrápidos y unificados sobre **Qt 6.12** y **C++23**, integrados a nivel de kernel y compositor con **KWin 6.8 Wayland**.

Inspirado en la filosofía de desacoplamiento de **Cutefish OS (`fishui`)**, `cachyos-ui` elimina la disparidad visual entre aplicaciones y descarta el bloatware web (cero WebViews / Electron). Toda la aceleración gráfica se ejecuta directamente sobre GPU mediante **Qt Quick Scene Graph (RHI / Vulkan)**.

---

## 💎 Características Principales

- **Física y Geometría Pixel-Perfect**:
  - Curvaturas *squircle* continuas de Apple ($n=4$).
  - Botones de semáforo interactivos (`#FF5F56`, `#FFBD2E`, `#27C93F`) con iconos de acción al pasar el ratón.
  - Microinteracciones táctiles con curvas Bezier elásticas idénticas a CoreAnimation.
- **Efecto Liquid Glass & KWin Blur**:
  - Integración nativa con `KWindowEffects` para solicitar regiones de desenfoque (*blur behind*) y contraste directo al compositor KWin en Wayland.
  - Bordes especulares cenitales (*specular rim*) adaptados dinámicamente a temas claro y oscuro.
- **Rendimiento C++23 Extremo**:
  - Compilación AOT de QML a C++ (`qmltc`).
  - Consumo de memoria en reposo: **~15 - 25 MB** por ventana.
  - Tiempos de arranque en CachyOS: **< 40 ms**.
- **Consistencia Total en el Ecosistema**:
  - Un único punto de verdad para sliders, botones, tarjetas, interruptores y selectores segmentados en todas las herramientas del sistema.

---

## 📦 Componentes del Sistema (`CachyOS.UI 1.0`)

| Componente | Descripción |
| :--- | :--- |
| **`CachyTheme`** | Singleton C++ con tokens de color, curvaturas, espaciados y respuesta reactiva a modo oscuro/claro. |
| **`CachyWindow`** | Ventana frameless con radio de esquinas continuo (22px), barra de título semáforo y KWin blur Wayland automático. |
| **`CachyCard`** | Superficie translúcida Liquid Glass con borde especular y hover feedback interactivo. |
| **`CachySlider`** | Control deslizante continuo idéntico a macOS, con track cilíndrico translúcido y pulgar con sombra suave. |
| **`CachySwitch`** | Interruptor toggle elástico estilo iOS/macOS con transición de color verde/acento y amortiguación elástica. |
| **`CachyButton`** | Botones redondeados con variantes (default, primary, destructive, flat) y compresión háptica visual. |
| **`CachySegmentedControl`** | Selector de modos con píldora deslizante translúcida animada por resorte. |

---

## 🛠️ Requisitos del Sistema

- **Distribución:** CachyOS Linux (o Arch Linux).
- **Entorno:** KDE Plasma 6.8+ sobre Wayland.
- **Compilador:** GCC 14+ o Clang 18+ (C++23 habilitado).
- **Librerías:** `qt6-base`, `qt6-declarative`, `qt6-shadertools`, `extra-cmake-modules`, `kwindowsystem`, `kcoreaddons`.

---

## 🚀 Compilación y Galería de Componentes

### 1. Compilación manual
```bash
git clone https://github.com/cachyos/cachyos-ui.git
cd cachyos-ui
cmake -B build -S . -DCMAKE_BUILD_TYPE=Release
cmake --build build -j$(nproc)
```

### 2. Ejecutar la galería interactiva
Prueba los componentes en vivo bajo Wayland:
```bash
./build/bin/cachyos-ui-gallery
```

### 3. Instalación en el sistema
```bash
./install.sh
# O mediante PKGBUILD en Arch/CachyOS:
cd packaging && makepkg -si
```

---

## 💻 Uso en Aplicaciones

Cualquier proyecto o herramienta de CachyOS puede importar la librería de forma directa:

```qml
import QtQuick
import QtQuick.Layouts
import CachyOS.UI

CachyWindow {
    title: "Mi Aplicación"
    width: 480
    height: 360

    contentData: [
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: CachyTheme.spacingLarge

            CachyCard {
                Layout.fillWidth: true
                
                content: [
                    RowLayout {
                        anchors.fill: parent
                        Text { text: "Activar Aceleración BORE"; color: CachyTheme.textPrimary; Layout.fillWidth: true }
                        CachySwitch { checked: true }
                    }
                ]
            }

            CachySlider {
                Layout.fillWidth: true
                from: 0; to: 100; value: 80
            }

            CachyButton {
                text: "Aplicar Cambios"
                primary: true
                Layout.alignment: Qt.AlignRight
            }
        }
    ]
}
```

---

## 🗺️ Hoja de Ruta (Roadmap)

- [x] Arquitectura base C++23 con `qt_add_qml_module` y CMake.
- [x] Módulo `CachyOS.UI 1.0` con KWin Wayland Blur integrado.
- [x] Componentes maestros (`CachyWindow`, `CachyCard`, `CachySlider`, `CachySwitch`, `CachyButton`, `CachySegmentedControl`).
- [x] Galería interactiva `cachyos-ui-gallery`.
- [x] Paquete `PKGBUILD` y scripts de instalación limpia.
- [ ] Migración de las aplicaciones de `Proyectos/` (`kiri`, `kisland`, `plasma-control-center`, `kpeek`, etc.) a `CachyOS.UI`.
- [ ] Instalador visual GUI unificado con selector modular de componentes para instalaciones nuevas de CachyOS.
