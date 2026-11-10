add_library(cachyosui STATIC)

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

# QML Module installation
install(TARGETS cachyosui
    LIBRARY DESTINATION ${KDE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${KDE_INSTALL_LIBDIR}
)
