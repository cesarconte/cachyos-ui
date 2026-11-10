add_executable(cachyos-ui-gallery
    main.cpp
)

qt_add_qml_module(cachyos-ui-gallery
    URI CachyOS.UI.Gallery
    VERSION 1.0
    QML_FILES
        GalleryWindow.qml
)

target_link_libraries(cachyos-ui-gallery PRIVATE
    cachyosui
    cachyosuiplugin
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
)

install(TARGETS cachyos-ui-gallery ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
