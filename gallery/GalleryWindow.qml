/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import CachyOS.UI

CachyWindow {
    id: root

    title: "CachyOS.UI — Catálogo de Componentes Golden Gate"
    width: CachyTheme.windowWidthSettings
    height: CachyTheme.windowHeightSettings
    sidebarWidth: 230

    property int activeNavIndex: 0

    // Golden Gate Navigation Buttons in Leading Header
    headerLeading: [
        CachyNavigationButtons {
            anchors.verticalCenter: parent.verticalCenter
            canGoBack: root.activeNavIndex > 0
            canGoForward: root.activeNavIndex < 5
            onBackClicked: root.activeNavIndex = Math.max(0, root.activeNavIndex - 1)
            onForwardClicked: root.activeNavIndex = Math.min(5, root.activeNavIndex + 1)
        }
    ]

    headerActions: [
        CachyToolbarButton {
            anchors.verticalCenter: parent.verticalCenter
            text: "Info"
            iconName: "info"
            onClicked: aboutDialog.open()
        }
    ]

    // 1. Golden Gate Sidebar with Categorized Navigation
    sidebar: [
        ColumnLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            anchors.bottomMargin: 14
            spacing: 8

            CachySearchField {
                Layout.fillWidth: true
                placeholderText: qsTr("Buscar componente...")
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Repeater {
                    model: [
                        { label: qsTr("Apariencia & Cristal"), icon: "appearance", color: "#1C1C1E" },
                        { label: qsTr("Botones, Selección & Chips"), icon: "check", color: "#007AFF" },
                        { label: qsTr("Navegación & Pestañas"), icon: "chevron-right", color: "#AF52DE" },
                        { label: qsTr("Listas, Tablas & Datos"), icon: "list", color: "#34C759" },
                        { label: qsTr("Formularios Agrupados"), icon: "settings", color: "#FF9500" },
                        { label: qsTr("Multimedia & Fechas"), icon: "media-playback-start", color: "#FA2D48" },
                        { label: qsTr("Diálogos, Paneles & Mensajes"), icon: "info", color: "#FF2D55" }
                    ]

                    CachySidebarItem {
                        required property var modelData
                        required property int index

                        text: modelData.label
                        iconName: modelData.icon
                        iconColor: modelData.color
                        squircleIconBadge: true
                        selected: root.activeNavIndex === index
                        onClicked: root.activeNavIndex = index
                    }
                }
            }

            Item { Layout.fillHeight: true }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    color: CachyTheme.accentColor

                    CachyIcon {
                        anchors.centerIn: parent
                        name: "settings"
                        size: 16
                        color: "#FFFFFF"
                    }
                }

                ColumnLayout {
                    spacing: 1
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0

                    Text {
                        text: "CachyOS.UI 1.0"
                        font.pixelSize: 13
                        font.weight: Font.Bold
                        color: CachyTheme.textPrimary
                        elide: Text.ElideRight
                    }
                    Text {
                        text: "macOS Golden Gate"
                        font.pixelSize: 11
                        color: CachyTheme.textSecondary
                        elide: Text.ElideRight
                    }
                }
            }
        }
    ]

    // 2. Main Content Area with 6 Stacked Category Views
    contentData: [
        StackLayout {
            anchors.fill: parent
            anchors.margins: CachyTheme.marginWindow
            currentIndex: root.activeNavIndex

            // =================================================================
            // SECCIÓN 0: Apariencia & Liquid Glass
            // =================================================================
            CachyScrollablePage {
                ColumnLayout {
                    width: parent.width
                    spacing: 16

                    CachyCard {
                        Layout.fillWidth: true
                        contentItem: ColumnLayout {
                            spacing: 12

                            RowLayout {
                                Layout.fillWidth: true
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.minimumWidth: 0
                                    spacing: 2
                                    Text {
                                        text: "Liquid Glass Calibrator"
                                        font.pixelSize: 16
                                        font.weight: Font.Bold
                                        color: CachyTheme.textPrimary
                                    }
                                    Text {
                                        text: "Desplaza para ajustar el nivel de refracción y translucidez en vivo."
                                        font.pixelSize: 12
                                        color: CachyTheme.textSecondary
                                        wrapMode: Text.WordWrap
                                        Layout.fillWidth: true
                                    }
                                }
                                Text {
                                    text: Math.round(CachyTheme.glassOpacity * 100) + "%"
                                    font.pixelSize: 14
                                    font.weight: Font.Bold
                                    color: CachyTheme.accentColor
                                }
                            }

                            CachySlider {
                                id: glassOpacitySlider
                                Layout.fillWidth: true
                                from: 0
                                to: 100
                                value: Math.round(CachyTheme.glassOpacity * 100)
                                onValueChanged: CachyTheme.glassOpacity = value / 100.0
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                CachyButton {
                                    text: "Cristal Puro (0%)"
                                    flat: true
                                    onClicked: glassOpacitySlider.value = 0
                                }
                                CachyButton {
                                    text: "Golden Gate (50%)"
                                    flat: true
                                    onClicked: glassOpacitySlider.value = 50
                                }
                                CachyButton {
                                    text: "Tinte Máximo (100%)"
                                    flat: true
                                    onClicked: glassOpacitySlider.value = 100
                                }
                            }
                        }
                    }

                    CachySegmentedControl {
                        Layout.fillWidth: true
                        model: ["Automático", "Modo Claro", "Modo Oscuro", "Liquid Glass"]
                        currentIndex: 3
                    }

                    CachyCard {
                        Layout.fillWidth: true
                        contentItem: ColumnLayout {
                            spacing: 10
                            Text {
                                text: "Muestras de Color Semántico (CachyPalette)"
                                font.pixelSize: 13
                                font.weight: Font.Bold
                                color: CachyTheme.textPrimary
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10
                                CachyBadge { text: "Accent Color"; badgeType: "accent" }
                                CachyBadge { text: "Success State"; badgeType: "success" }
                                CachyBadge { text: "Warning State"; badgeType: "warning" }
                                CachyBadge { text: "Error State"; badgeType: "error" }
                            }
                        }
                    }
                }
            }

            // =================================================================
            // SECCIÓN 1: Botones, Selección & Entradas
            // =================================================================
            CachyScrollablePage {
                ColumnLayout {
                    width: parent.width
                    spacing: 16

                    CachyCard {
                        Layout.fillWidth: true
                        contentItem: ColumnLayout {
                            spacing: 12
                            Text {
                                text: "Botones & Píldoras"
                                font.pixelSize: 14
                                font.weight: Font.Bold
                                color: CachyTheme.textPrimary
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10
                                CachyButton { text: "Acción Principal"; primary: true }
                                CachyButton { text: "Secundario" }
                                CachyButton { text: "Plano"; flat: true }
                                CachyButton { text: "Eliminar"; destructive: true }
                            }
                        }
                    }

                    CachyCard {
                        Layout.fillWidth: true
                        contentItem: ColumnLayout {
                            spacing: 12
                            Text {
                                text: "Selectores & Switches"
                                font.pixelSize: 14
                                font.weight: Font.Bold
                                color: CachyTheme.textPrimary
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 20
                                CachySwitch { text: "Wi-Fi"; checked: true }
                                CachyCheckBox { text: "Aceleración GPU"; checked: true }
                                CachyRadioButton { text: "Vulkan RHI"; checked: true }
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 12
                                CachyComboBox {
                                    Layout.preferredWidth: 200
                                    model: ["Resolución 1080p", "Resolución 2K", "Resolución 4K"]
                                }
                                CachySpinBox {
                                    Layout.preferredWidth: 160
                                    from: 1; to: 120; value: 60
                                    suffix: " FPS"
                                }
                            }
                        }
                    }

                    CachyCard {
                        Layout.fillWidth: true
                        contentItem: ColumnLayout {
                            spacing: 10
                            Text {
                                text: "Campos de Texto & Búsqueda"
                                font.pixelSize: 14
                                font.weight: Font.Bold
                                color: CachyTheme.textPrimary
                            }
                            CachyTextField {
                                Layout.fillWidth: true
                                placeholderText: "Escribe aquí tu texto..."
                                text: "CachyOS Golden Gate Design System"
                            }
                            CachyTextArea {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 70
                                text: "Área multilínea con bordes especulares reactivos y desplazamiento suave."
                            }
                        }
                    }

                    CachyCard {
                        Layout.fillWidth: true
                        contentItem: ColumnLayout {
                            spacing: 10
                            Text {
                                text: "Chips & Etiquetas Dinámicas (CachyTagField)"
                                font.pixelSize: 14
                                font.weight: Font.Bold
                                color: CachyTheme.textPrimary
                            }
                            CachyTagField {
                                Layout.fillWidth: true
                                tags: ["CachyOS", "Wayland", "Vulkan", "Plasma 6", "Qt 6"]
                                onTagAdded: (tag) => toastNotification.show("Etiqueta añadida: " + tag, "info")
                                onTagRemoved: (idx) => toastNotification.show("Etiqueta eliminada", "warning")
                            }
                        }
                    }
                }
            }

            // =================================================================
            // SECCIÓN 2: Navegación & Pestañas
            // =================================================================
            CachyScrollablePage {
                ColumnLayout {
                    width: parent.width
                    spacing: 16

                    CachyBreadcrumbBar {
                        Layout.fillWidth: true
                        path: "/home/cesar/Proyectos/cachyos-ui/src/controls"
                    }

                    CachyCard {
                        Layout.fillWidth: true
                        contentItem: ColumnLayout {
                            spacing: 12
                            Text {
                                text: "Barra de Pestañas (CachyTabBar)"
                                font.pixelSize: 14
                                font.weight: Font.Bold
                                color: CachyTheme.textPrimary
                            }
                            CachyTabBar {
                                id: demoTabBar
                                Layout.fillWidth: true
                                CachyTabButton { text: "General"; iconName: "settings" }
                                CachyTabButton { text: "Rendimiento"; iconName: "refresh" }
                                CachyTabButton { text: "Redes"; iconName: "folder" }
                            }
                            CachyTabView {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 120
                                currentIndex: demoTabBar.currentIndex
                                Item {
                                    Text {
                                        anchors.centerIn: parent
                                        text: "Contenido de la vista General"
                                        color: CachyTheme.textSecondary
                                    }
                                }
                                Item {
                                    Text {
                                        anchors.centerIn: parent
                                        text: "Métricas de rendimiento en tiempo real"
                                        color: CachyTheme.textSecondary
                                    }
                                }
                                Item {
                                    Text {
                                        anchors.centerIn: parent
                                        text: "Configuración de adaptadores de red"
                                        color: CachyTheme.textSecondary
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // =================================================================
            // SECCIÓN 3: Listas, Tablas & Datos (Demo Dolphin / Transmission / TableView)
            // =================================================================
            CachyScrollablePage {
                ColumnLayout {
                    width: parent.width
                    spacing: 16

                    Text {
                        text: "Tabla de Datos Virtualizada (CachyTableView)"
                        font.pixelSize: 14
                        font.weight: Font.Bold
                        color: CachyTheme.textPrimary
                    }

                    CachyTableView {
                        id: demoTableView
                        Layout.fillWidth: true
                        Layout.preferredHeight: 180
                        columns: [
                            { role: "name", title: "Archivo / Paquete", width: 220, fillWidth: true },
                            { role: "category", title: "Tipo", width: 100, type: "badge" },
                            { role: "size", title: "Tamaño", width: 90 },
                            { role: "progress", title: "Progreso", width: 120, type: "progress" }
                        ]
                        model: ListModel {
                            ListElement { name: "cachyos-desktop-2026.iso"; category: "ISO"; size: "2.8 GB"; progress: 1.0 }
                            ListElement { name: "linux-cachyos-bore-kernel.tar.zst"; category: "Kernel"; size: "148 MB"; progress: 0.65 }
                            ListElement { name: "kde-plasma-glass-wallpapers.zip"; category: "Artwork"; size: "420 MB"; progress: 0.35 }
                            ListElement { name: "audiotube-extended-master.tar.gz"; category: "Código"; size: "24 MB"; progress: 0.90 }
                        }
                        onRowClicked: (idx, row) => toastNotification.show("Fila seleccionada: " + row.name, "info")
                    }

                    CachyCard {
                        Layout.fillWidth: true
                        contentItem: ColumnLayout {
                            spacing: 8
                            Text {
                                text: "Elementos de Lista Ricos (CachyListItem)"
                                font.pixelSize: 14
                                font.weight: Font.Bold
                                color: CachyTheme.textPrimary
                            }
                            CachyListItem {
                                title: "CachyOS Kernel BORE x86-64-v4"
                                subtitle: "Compilado nativo con Clang/LLVM • LTO activado"
                                progressValue: 0.85
                                badgeText: "Descargando"
                                badgeType: "accent"
                                iconName: "download"
                            }
                            CachyListItem {
                                title: "Recordatorios de Tareas"
                                subtitle: "12 tareas pendientes para hoy"
                                badgeText: "Completado"
                                badgeType: "success"
                                iconName: "check"
                            }
                        }
                    }

                    CachyStatusBar {
                        Layout.fillWidth: true
                        summaryText: "4 elementos • 3.4 GB en cola"
                        secondaryText: "↓ 42.8 MB/s ↑ 8.2 MB/s"
                        leadingIcon: "info"
                    }
                }
            }

            // =================================================================
            // SECCIÓN 4: Formularios Agrupados (CachyFormCard)
            // =================================================================
            CachyScrollablePage {
                ColumnLayout {
                    width: parent.width
                    spacing: 16

                    CachyFormHeader {
                        title: "Preferencias del Sistema"
                    }

                    CachyFormCard {
                        Layout.fillWidth: true

                        CachyFormCheckDelegate {
                            label: "Activar Desenfoque KWin"
                            description: "Aplica blur vectorial con aceleración por hardware."
                            checked: true
                        }

                        CachyFormDelegateSeparator {}

                        CachyFormComboBoxDelegate {
                            label: "Backend de Renderizado"
                            model: ["Vulkan RHI (Nativo)", "OpenGL", "Software Fallback"]
                            currentIndex: 0
                        }

                        CachyFormDelegateSeparator {}

                        CachyFormSpinBoxDelegate {
                            label: "Límite de Tasa de Refresco"
                            from: 30; to: 360; value: 144
                            suffix: " Hz"
                        }

                        CachyFormDelegateSeparator {}

                        CachyFormTextFieldDelegate {
                            label: "Nombre de Equipo"
                            text: "cachyos-workstation"
                        }

                        CachyFormDelegateSeparator {}

                        CachyFormButtonDelegate {
                            text: "Restablecer Valores Predeterminados"
                            description: "Restaura la configuración de fábrica de CachyOS.UI."
                            onClicked: toastNotification.show("Configuración restablecida", "warning")
                        }
                    }
                }
            }

            // =================================================================
            // SECCIÓN 5: Multimedia & Fechas (AudioTube & Recordatorios)
            // =================================================================
            CachyScrollablePage {
                ColumnLayout {
                    width: parent.width
                    spacing: 16

                    CachyCard {
                        Layout.fillWidth: true
                        contentItem: ColumnLayout {
                            spacing: 12
                            Text {
                                text: "Barra de Reproducción Multimedia (CachyMediaBar)"
                                font.pixelSize: 14
                                font.weight: Font.Bold
                                color: CachyTheme.textPrimary
                            }
                            CachyMediaBar {
                                Layout.fillWidth: true
                                trackTitle: "La Graciosa"
                                trackArtist: "Quevedo, Elvis Crespo • Mix Destacado"
                                isPlaying: true
                                position: 0.42
                                positionSeconds: 102
                                durationSeconds: 242
                                onPlayRequested: isPlaying = true
                                onPauseRequested: isPlaying = false
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 16

                        CachyCard {
                            Layout.fillWidth: true
                            contentItem: ColumnLayout {
                                spacing: 8
                                Text {
                                    text: "Selector de Fecha (CachyDatePicker)"
                                    font.pixelSize: 14
                                    font.weight: Font.Bold
                                    color: CachyTheme.textPrimary
                                }
                                CachyDatePicker {
                                    Layout.alignment: Qt.AlignHCenter
                                    onDateSelected: (d) => toastNotification.show("Fecha seleccionada: " + d.toLocaleDateString(), "info")
                                }
                            }
                        }

                        CachyCard {
                            Layout.preferredWidth: 280
                            Layout.fillHeight: true
                            contentItem: ColumnLayout {
                                spacing: 12
                                Text {
                                    text: "Selector de Hora (CachyTimePicker)"
                                    font.pixelSize: 14
                                    font.weight: Font.Bold
                                    color: CachyTheme.textPrimary
                                }
                                CachyTimePicker {
                                    Layout.alignment: Qt.AlignHCenter
                                    is24Hour: false
                                    onTimeSelected: (h, m) => toastNotification.show("Hora: " + h + ":" + m, "info")
                                }
                            }
                        }
                    }
                }
            }

            // =================================================================
            // SECCIÓN 6: Diálogos, Paneles & Feedback
            // =================================================================
            CachyScrollablePage {
                ColumnLayout {
                    width: parent.width
                    spacing: 16

                    CachyInlineMessage {
                        Layout.fillWidth: true
                        messageType: "information"
                        text: "Todos los diálogos y avisos de CachyOS.UI emplean superficies densas sheetBackground para máxima legibilidad."
                    }

                    CachyCard {
                        Layout.fillWidth: true
                        contentItem: ColumnLayout {
                            spacing: 12
                            Text {
                                text: "Disparadores de Diálogo & Notificación"
                                font.pixelSize: 14
                                font.weight: Font.Bold
                                color: CachyTheme.textPrimary
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10
                                CachyButton {
                                    text: "Mostrar Toast Éxito"
                                    onClicked: toastNotification.show("¡Operación completada con éxito!", "success")
                                }
                                CachyButton {
                                    text: "Mostrar Toast Error"
                                    destructive: true
                                    onClicked: toastNotification.show("Error de conexión al servidor", "error")
                                }
                                CachyButton {
                                    text: "Abrir Diálogo Modal"
                                    primary: true
                                    onClicked: demoModalDialog.open()
                                }
                                CachyButton {
                                    text: "Abrir Panel Lateral"
                                    onClicked: demoSideDrawer.toggle()
                                }
                            }
                        }
                    }

                    CachyCard {
                        Layout.fillWidth: true
                        contentItem: ColumnLayout {
                            spacing: 10
                            Text {
                                text: "Indicadores de Carga y Espera"
                                font.pixelSize: 14
                                font.weight: Font.Bold
                                color: CachyTheme.textPrimary
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 20
                                CachyBusyIndicator { running: true }
                                Text {
                                    text: "Procesando tareas en segundo plano..."
                                    color: CachyTheme.textSecondary
                                }
                            }
                        }
                    }
                }
            }
        }
    ]

    // Toast Notification Banner
    CachyToast {
        id: toastNotification
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 24
    }

    // Modal Confirmation Dialog
    CachyDialog {
        id: demoModalDialog
        title: "Confirmar Acción"
        subtitle: "¿Estás seguro de que deseas proceder con la optimización del sistema CachyOS?"
        CachyButton {
            text: "Aceptar"
            primary: true
            onClicked: {
                demoModalDialog.close();
                toastNotification.show("Optimización iniciada", "success");
            }
        }
    }

    // About Dialog
    CachyDialog {
        id: aboutDialog
        title: "Acerca de CachyOS.UI"
        subtitle: "Ecosistema declarativo nativo C++23/QML sobre KDE Plasma 6 y Wayland con lenguaje visual Golden Gate / Liquid Glass."
    }

    // Off-Canvas Drawer Overlay
    CachyDrawer {
        id: demoSideDrawer
        edge: Qt.RightEdge
        drawerSize: 300
        title: "Inspector de Propiedades"
        opened: false

        ColumnLayout {
            anchors.fill: parent
            spacing: 12

            Text {
                text: "Panel lateral off-canvas con superficie sheetBackground, animación continua y cierre por escape o clic exterior."
                font.pixelSize: 12
                color: CachyPalette.textSecondary
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            CachyFormCard {
                Layout.fillWidth: true

                CachyFormCheckDelegate {
                    label: "Sincronización en vivo"
                    checked: true
                }

                CachyFormDelegateSeparator {}

                CachyFormCheckDelegate {
                    label: "Aceleración por GPU"
                    checked: true
                }
            }

            Item { Layout.fillHeight: true }
        }
    }
}
