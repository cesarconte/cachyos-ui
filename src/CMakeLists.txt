add_library(cachyosui SHARED)

qt_add_qml_module(cachyosui
    URI CachyOS.UI
    VERSION 1.0
    SOURCES
        core/cachywindowblur.h
        core/cachywindowblur.cpp
        core/cachytheme.h
        core/cachytheme.cpp
    QML_FILES
        controls/CachyWindow.qml
        controls/CachyCard.qml
        controls/CachySlider.qml
        controls/CachySwitch.qml
        controls/CachyButton.qml
        controls/CachySegmentedControl.qml
        controls/CachyTrafficLights.qml
        controls/CachyTextField.qml
        controls/CachyProgressBar.qml
        controls/CachyDivider.qml
)

target_include_directories(cachyosui PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/core
)

target_link_libraries(cachyosui PUBLIC
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    KF6::WindowSystem
    KF6::CoreAddons
)

set_target_properties(cachyosuiplugin PROPERTIES
    PREFIX "lib"
    OUTPUT_NAME "cachyosuiplugin"
)

# QML Module installation
set(CACHYOS_QML_DIR "lib/qt6/qml/CachyOS/UI")

install(TARGETS cachyosui
    LIBRARY DESTINATION ${KDE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${KDE_INSTALL_LIBDIR}
)

install(TARGETS cachyosuiplugin
    LIBRARY DESTINATION ${CACHYOS_QML_DIR}
)

install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/qmldir
    ${CMAKE_CURRENT_BINARY_DIR}/cachyosui.qmltypes
    DESTINATION ${CACHYOS_QML_DIR}
)

install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/controls
    DESTINATION ${CACHYOS_QML_DIR}
)
