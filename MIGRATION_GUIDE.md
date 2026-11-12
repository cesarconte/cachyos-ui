# Guía de migración al diseño `CachyOS.UI` (Golden Gate / Liquid Glass)

Receta canónica para pasar una aplicación del ecosistema KDE/Qt al diseño
**CachyOS.UI**, y checklist de verificación automatizada.

> Cada migración se hace **una por una**. Este documento existe para que el
> proceso sea siempre el mismo, verificable y sin regresiones.

---

## 1. Qué hay que mirar primero

| Pregunta | Por qué importa |
| :--- | :--- |
| ¿La ventana es una `ApplicationWindow`? | Solo las *ventanas* se migran a `CachyWindow`. Un plasmoid, un panel o un *applet* **no** puede usar `CachyWindow`: se migran sustituyendo `Kirigami.Theme` por `CachyTheme`. |
| ¿Tiene superficies de configuración? | `ConfigGeneral.qml` de un plasmoid y los KCM se migran aparte (tokens + `CachyCard`). |
| ¿Hay contenido desplazable? | El contenido de un `Flickable` puede exceder su viewport **por diseño**: la auditoría lo excluye automáticamente. |
| ¿Hay solapamientos intencionados? | Se declaran con `property bool auditBleed: true`. |

---

## 2. Migración de la ventana (`Kirigami.ApplicationWindow` → `CachyWindow`)

```qml
// ANTES
import org.kde.kirigami as Kirigami

Kirigami.ApplicationWindow {
    width: 640; height: 480
    color: Kirigami.Theme.backgroundColor
    pageStack: Kirigami.PageStack { ... }
}
```

```qml
// DESPUÉS
import CachyOS.UI

CachyWindow {
    id: window

    title: "Mi Aplicación"
    width: 880
    height: 640
    minimumWidth: 560
    minimumHeight: 400

    // Geometría canónica Golden Gate
    showTrafficLights: true
    showTitleBarDivider: true          // divisor duro de 1 px
    showWindowFrame: true              // Liquid Glass + blur KWin + rim especular
    resizable: true
    cornerRadius: CachyTheme.radiusWindow   // 20 px
    contentPadded: true                // margen perimetral de 18 px
    sidebarWidth: 240

    // NO sobrescribir `backgroundColor`: cancelaría el glass
}
```

### Reglas invariables

1. **Nunca** asignar `backgroundColor`: el glass es `CachyTheme.windowBackground`.
2. `showTitleBarDivider: true` siempre (divisor duro de `1 px`).
3. Todo color, radio y espaciado sale de `CachyTheme`; nada de hex literales
   en el cromo.
4. Los textos dinámicos dentro de un `RowLayout`/`ColumnLayout` llevan
   `Layout.fillWidth: true` **y** `Layout.minimumWidth: 0`.
5. Las descripciones que deben leerse enteras usan `wrapMode: Text.WordWrap`;
   los títulos de lista usan `elide: Text.ElideRight` con `Layout.minimumWidth: 0`.
6. El botón **Preferencias** va **siempre en el extremo derecho** de la
   cabecera, precedido del botón *Fijar ventana* cuando aplique.

### Componentes a usar

| Necesidad | Componente |
| :--- | :--- |
| Tarjeta / panel | `CachyCard` (radio `12 px`, padding `14 px`, borde `1 px`) |
| Botón de barra | `CachyToolbarButton` (píldora con `surfacePill`) |
| Botón de acción | `CachyButton` (`primary` / `destructive` / `flat`) |
| Elemento de barra lateral | `CachySidebarItem` (icono coloreado + negrita al seleccionar) |
| Interruptor | `CachySwitch` |
| Segmentado | `CachySegmentedControl` |
| Deslizador | `CachySlider` |
| Campo de texto | `CachyTextField` |
| Separador | `CachyDivider` |

---

## 3. Auditoría de layout (obligatoria)

`CachyOS.UI` instala el auditor como paquete CMake reutilizable:

```cmake
list(APPEND CMAKE_PREFIX_PATH "$ENV{HOME}/.local" "/usr/local")
find_package(CachyOSUITesting REQUIRED)

add_executable(test_layout_audit test_layout_audit.cpp)
target_link_libraries(test_layout_audit PRIVATE
    Qt6::Core Qt6::Gui Qt6::Qml Qt6::Quick Qt6::QuickControls2 Qt6::Test
    CachyOSUITesting::CachyOSUITesting
)
add_test(NAME test_layout_audit COMMAND test_layout_audit)
```

El test monta la escena *offscreen* y verifica cuatro invariantes:

| Regla | Detecta |
| :--- | :--- |
| `protrusion` | Un elemento que sobresale de su contenedor. |
| `out-of-window` | Un elemento que sobresale de la ventana. |
| `text-clipping` | Un texto que se recorta sin usar la elipsis. |
| `header-overlap` | El título de la ventana solapando los grupos de la cabecera. |

Cobertura mínima exigida: **todos los estados de la interfaz** (pestañas,
hojas, paneles plegados) en **varios tamaños de ventana**, más un **barrido
de anchos** con varios títulos.

```cpp
void TestLayoutAudit::auditWindowStates_data()
{
    QTest::addColumn<int>("width");
    QTest::addColumn<int>("height");
    QTest::newRow("minimum") << 620 << 520;
    QTest::newRow("default")  << 980 << 680;
    QTest::newRow("wide")     << 1440 << 900;
}
```

El caso de referencia completo está en
[`kphonemirroring/tests/test_layout_audit.cpp`](../../kphonemirroring/tests/test_layout_audit.cpp).

---

## 4. Checklist de cierre de una migración

- [ ] La ventana usa `CachyWindow` con la geometría canónica completa.
- [ ] No queda ningún `backgroundColor` opaco.
- [ ] Cero colores, radios o espaciados literales en el cromo.
- [ ] Barra lateral *edge-to-edge* con iconos coloreados y negrita al seleccionar.
- [ ] Preferencias en el extremo derecho de la cabecera.
- [ ] Cero desbordes: verificado por `ctest` (auditoría de layout en verde).
- [ ] `ctest` completo en verde.
- [ ] Capturas reales verificadas (tamaño mínimo, por defecto, ancho, oscuro).
- [ ] Compilado e instalado en `~/.local`.
- [ ] Commit semántico (`Conventional Commits`) y `git push`.

---

## 5. Instalación del módulo y del auditor

```bash
cd cachyos-ui
cmake -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/
cmake --build build -j"$(nproc)"
DESTDIR=$HOME/.local cmake --install build
```

Esto instala el módulo QML `CachyOS.UI` en `~/.local/lib/qt6/qml/CachyOS/UI`
y el auditor en `~/.local/lib/cmake/CachyOSUITesting`.
