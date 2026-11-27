# Guía de migración al diseño `CachyOS.UI` (Golden Gate / Liquid Glass)

Receta canónica para pasar una aplicación del ecosistema KDE/Qt al diseño
**CachyOS.UI**, y checklist de verificación automatizada.

> Cada migración se hace **una por una**. Este documento existe para que el
> proceso sea siempre el mismo, verificable y sin regresiones.

---

## 1. Qué hay que mirar primero

| Pregunta | Por qué importa |
| :--- | :--- |
| ¿La ventana es una `ApplicationWindow`? | Solo las *ventanas* se migran a `CachyWindow`. Un plasmoid, un panel o un *applet* **no** puede usar `CachyWindow`: se migran con la receta de la §3. |
| ¿Tiene superficies de configuración? | `ConfigGeneral.qml` de un plasmoid y los KCM se migran aparte (tokens + `CachyCard` / `CachyFormCard`). |
| ¿Usa `org.kde.ki18n` en QML? | Sustituir por `CachyI18n.i18n(...)`, `CachyI18n.i18nc(...)` o `CachyI18n.i18d(...)` para evitar etiquetas en blanco cuando no existe catálogo instalado. |
| ¿Hay contenido desplazable? | El contenido de un `Flickable` o `CachyScrollablePage` puede exceder su viewport **por diseño**: la auditoría lo excluye automáticamente. |
| ¿Hay solapamientos intencionados? | Se declaran con `property bool auditBleed: true`. |

> **Nota sobre el color.** Desde la Fase 3, el color de primer plano de
> **cualquier** superficie del ecosistema se toma de `CachyPalette`, no de
> `CachyTheme.textPrimary`. La razón está en la §3.1 y es la causa raíz más
> frecuente de «texto negro sobre fondo oscuro» en los plasmoides.

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

    title: CachyI18n.i18n("Mi Aplicación")
    width: CachyTheme.windowWidthSettings
    height: CachyTheme.windowHeightSettings
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

### Tabla de equivalencias Kirigami / FormCard → `CachyOS.UI`

| Necesidad / Componente antiguo | Componente en `CachyOS.UI` |
| :--- | :--- |
| `Kirigami.ApplicationWindow` | `CachyWindow` |
| `Kirigami.PageStack` | `CachyPageStack` (+ `layers` con `CachyDialogLayer`) |
| `Kirigami.ScrollablePage` / `Kirigami.Page` | `CachyScrollablePage` |
| `FormCard.FormCardPage` | `CachyFormCardPage` |
| `FormCard.FormCard` | `CachyFormCard` |
| `FormCard.FormHeader` | `CachyFormHeader` |
| `FormCard.FormDelegateSeparator` | `CachyFormDelegateSeparator` |
| `FormCard.FormCheckDelegate` | `CachyFormCheckDelegate` |
| `FormCard.FormTextFieldDelegate` | `CachyFormTextFieldDelegate` |
| `FormCard.FormButtonDelegate` | `CachyFormButtonDelegate` |
| `Kirigami.FormLayout` | `CachyFormLayout` |
| `Kirigami.Heading` | `CachyHeading` (`level: 1..5`) |
| `Kirigami.PlaceholderMessage` | `CachyPlaceholderMessage` |
| `Kirigami.InlineMessage` | `CachyInlineMessage` (`information` / `warning` / `error`) |
| `Kirigami.SelectableLabel` | `CachySelectableLabel` |
| `Kirigami.ListSectionHeader` | `CachySectionHeader` |
| `Kirigami.IconTitleSubtitle` | `CachyIconTitleSubtitle` |
| `Kirigami.SearchField` | `CachySearchField` |
| `Kirigami.Dialog` / `Kirigami.PromptDialog` | `CachyDialog` |
| `FormCard.AboutPage` / `Kirigami.AboutPage` | `CachyAboutPage` |
| Tarjeta / panel contenedor | `CachyCard` (radio `12 px`, padding `14 px`, borde `1 px`) |
| Botón de barra de herramientas | `CachyToolbarButton` (píldora con `surfacePill` e icono Breeze) |
| Botón de acción | `CachyButton` (`primary` / `destructive` / `flat`) |
| Elemento de barra lateral | `CachySidebarItem` (icono coloreado + negrita al seleccionar) |
| Interruptor | `CachySwitch` |
| Selector segmentado | `CachySegmentedControl` |
| Deslizador | `CachySlider` |
| Campo de texto | `CachyTextField` |
| Barra de progreso | `CachyProgressBar` |
| Separador | `CachyDivider` |
| `KI18n.i18n(...)` | `CachyI18n.i18n(...)` / `i18nc(...)` / `i18d(...)` |

---

## 3. Migración de plasmoides (superficie no-ventana)

Un plasmoide **no es una ventana**: vive dentro de `plasmashell`, sobre una
superficie que pinta **Plasma** (el panel, o el popup del applet con su
transparencia y su *blur*). Eso cambia dos reglas respecto a una aplicación.

### 3.1 Regla del color: `CachyPalette`, no `CachyTheme.textPrimary`

`CachyTheme.isDark()` decide el modo claro/oscuro con
`QStyleHints::colorScheme()`, que refleja el **color scheme de la
aplicación** (`BreezeLight`/`BreezeDark` de `kdeglobals`). El *chrome* del
panel, en cambio, lo pinta el **tema de escritorio** de Plasma, que tiene su
propio archivo `colors`.

Con el tema `macOS-GoldenGate` ambos discrepan: el tema de escritorio es
siempre oscuro con primer plano blanco (`ForegroundNormal=252,252,252`) en
*todos* sus grupos, mientras el color scheme de la aplicación puede ser
claro. El resultado de usar `CachyTheme.textPrimary` en un plasmoide es
**texto negro sobre un popup oscuro**: ilegible.

`CachyPalette` resuelve la paleta **efectiva de la superficie real**:

| Token | Significado |
| :--- | :--- |
| `CachyPalette.text` | Primer plano principal (el color de la superficie) |
| `CachyPalette.textSecondary` | Primer plano secundario (72 % de opacidad) |
| `CachyPalette.textMuted` | Primer plano atenuado (48 % de opacidad) |
| `CachyPalette.isDark` | Si la superficie real es oscura |
| `CachyPalette.accentColor` | Acento del tema (rellenos, bordes) |
| `CachyPalette.accentText` | Acento **legible como texto** sobre la superficie |
| `CachyPalette.cardBackground` / `cardBackgroundHover` | Superficie de tarjeta translúcida |
| `CachyPalette.surfacePill` | Superficie de píldora |
| `CachyPalette.windowBackground` / `sheetBackground` | Material de ventana / panel flotante |
| `CachyPalette.specularBorder` / `hardDividerColor` / `dividerColor` | Bordes y divisores |
| `CachyPalette.successColor` / `warningColor` / `errorColor` | Colores semánticos |

Dentro de una aplicación, `CachyPalette` y `CachyTheme` coinciden (misma
superficie); dentro de un plasmoide, `CachyPalette` gana.

### 3.2 Regla del fondo: el anfitrión ya lo pinta

Un plasmoide **no debe pintar su propio fondo opaco**: Plasma ya aporta la
superficie translúcida con *blur* de Golden Gate. Pintarla oculta el
*blur* y rompe la estética. Ésta fue la causa del «fondo blanco» que
apareció al migrar con `CachyTheme.sheetBackground` en vez de con la
superficie real.

`CachyPlasmoidSurface` encapsulates esto: por defecto es **transparente**
(`framed: false`) y solo pinta una superficie si se pide explícitamente.

### 3.3 Regla del icono: `CachyPlasmoidIcon`

`Kirigami.Icon` **solo aplica `color` cuando `isMask: true`**. Sin ello, el
SVG se pinta con su clase `ColorScheme-Text` interna (`#232629`) y aparece
**negro**, ignorando el color del tema. Además, `CachyIcon` resuelve el
fichero con `CachyTheme.iconUrl()`, que busca en directorios fijos de
Breeze/Hicolor e **ignora el tema de iconos elegido por el usuario**.

`CachyPlasmoidIcon` resuelve el icono en el tema de Plasma y lo tiñe con el
primer plano del anfitrión:

```qml
CachyPlasmoidIcon {
    iconName: "games-highscores-symbolic"
    iconSize: 18
}
```

### 3.4 Receta completa

```qml
// ANTES (plasmoid)
import org.kde.kirigami as Kirigami

Rectangle {
    color: "#000000"                       // fondo opaco: oculta el blur
    Text { color: Kirigami.Theme.textColor }
    Kirigami.Icon { source: "apps-symbolic" }   // sin isMask: iconos negros
}
```

```qml
// DESPUÉS (plasmoid)
import CachyOS.UI

CachyPlasmoidSurface {          // transparente: el anfitrión pinta el fondo
    title: i18n("Mi plasmoide")

    Text { color: CachyPalette.text }

    CachyPlasmoidIcon { iconName: "apps-symbolic" }
}
```

### 3.5 Tabla de equivalencias

| Necesidad | Componente |
| :--- | :--- |
| Raíz de la representación completa | `CachyPlasmoidSurface` (transparente, cabecera compacta) |
| Icono en el panel o dentro del popup | `CachyPlasmoidIcon` |
| Color de texto / superficies | `CachyPalette` |
| Color de acento | `CachyTheme.accentColor` (rellenos) · `CachyPalette.accentText` (texto) |
| Geometría (radios, espaciados, márgenes) | `CachyTheme.radius*` · `CachyTheme.spacing*` · `CachyTheme.marginCard` |
| Tarjeta, botón, chip, separador | `CachyCard` · `CachyButton` · `CachyToolbarButton` · `CachyDivider` |
| Formulario de configuración | `CachyFormCard` + `CachyForm*Delegate` |

### 3.6 Distancias: iguales salvo el tamaño

La estética (colores, radios, tipografía, forma de los elementos) es
**idéntica** a la de una aplicación. Lo único que cambia es el **espaciado**,
porque un applet tiene mucho menos sitio que una ventana:

| Contexto | Margen exterior | Espaciado de bloques | Padding de tarjeta |
| :--- | :---: | :---: | :---: |
| Ventana (`CachyWindow`) | `CachyTheme.marginWindow` (18) | `CachyTheme.spacingMedium` (12) | `CachyTheme.marginCard` (14) |
| Plasmoide (`CachyPlasmoidSurface`) | `CachyTheme.marginCard` (14) | `CachyTheme.spacingSmall` (8) | `CachyTheme.marginCard` (14) |

---

## 4. Auditoría de layout (obligatoria)

`CachyOS.UI` instala el auditor como paquete CMake reutilizable:

```cmake
list(APPEND CMAKE_PREFIX_PATH "/usr" "/usr/local")
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
[`kphonemirroring/tests/test_layout_audit.cpp`](../kphonemirroring/tests/test_layout_audit.cpp).

---

## 5. Checklist de cierre de una migración

**Aplicación:**

- [ ] La ventana usa `CachyWindow` con la geometría canónica completa.
- [ ] No queda ningún `backgroundColor` opaco.
- [ ] Cero colores, radios o espaciados literales en el cromo.
- [ ] Barra lateral *edge-to-edge* con iconos coloreados y negrita al seleccionar.
- [ ] Preferencias en el extremo derecho de la cabecera.
- [ ] Cero desbordes: verificado por `ctest` (auditoría de layout en verde).
- [ ] `ctest` completo en verde.
- [ ] Capturas reales verificadas (tamaño mínimo, por defecto, ancho, oscuro).
- [ ] Compilado e instalado en `/usr`.
- [ ] Commit semántico (`Conventional Commits`) y `git push`.

**Plasmoid (además de lo anterior):**

- [ ] El color de texto sale de `CachyPalette`, nunca de `CachyTheme.textPrimary`.
- [ ] El plasmoide **no** pinta un fondo opaco: el anfitrión ya aporta la
      superficie con *blur* (`CachyPlasmoidSurface` con `framed: false`).
- [ ] Los iconos usan `CachyPlasmoidIcon` (o `Kirigami.Icon` con
      `isMask: true`), nunca `Kirigami.Icon` a secas.
- [ ] Cero colores literales: ni `#ffffff`, ni `#0a84ff`, ni `#ff9f0a`.
- [ ] Los radios de superficie usan `CachyTheme.radius*` (los radios de
      elementos decorativos mínimos pueden ser literales).
- [ ] El icono del panel se ve del mismo color que el resto de iconos del
      panel, en modo claro y en modo oscuro.
- [ ] Captura real del **panel** y del **popup** verificada.

---

## 6. Instalación del módulo y del auditor

```bash
cd cachyos-ui
cmake -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/
cmake --build build -j"$(nproc)"
sudo -n cmake --install build --prefix /usr
```

Esto instala el módulo QML `CachyOS.UI` en `~/.local/lib/qt6/qml/CachyOS/UI`
y el auditor en `~/.local/lib/cmake/CachyOSUITesting`.
