include(CMakePackageConfigHelpers)

add_library(cachyosui SHARED
    icons/cachyosui_icons.qrc
)
add_library(CachyOSUI::cachyosui ALIAS cachyosui)

qt_add_qml_module(cachyosui
    URI CachyOS.UI
    VERSION 1.0
    SOURCES
        core/cachywindowblur.h
        core/cachywindowblur.cpp
        core/cachywindowshadow.h
        core/cachywindowshadow.cpp
        core/cachysortfilterproxymodel.h
        core/cachysortfilterproxymodel.cpp
        core/cachytheme.h
        core/cachytheme.cpp
        core/cachyi18n.h
        core/cachyi18n.cpp
    QML_FILES
        controls/CachyIcon.qml
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
        controls/CachySidebarItem.qml
        controls/CachyToolbarButton.qml
        controls/CachyHeading.qml
        controls/CachyPlaceholderMessage.qml
        controls/CachyFormLayout.qml
        controls/CachySelectableLabel.qml
        controls/CachyInlineMessage.qml
        controls/CachySectionHeader.qml
        controls/CachyFormCard.qml
        controls/CachyFormHeader.qml
        controls/CachyFormDelegateSeparator.qml
        controls/CachyFormCheckDelegate.qml
        controls/CachyFormTextFieldDelegate.qml
        controls/CachyFormButtonDelegate.qml
        controls/CachyFormCardPage.qml
        controls/CachyIconTitleSubtitle.qml
        controls/CachyPageStack.qml
        controls/CachyDialogLayer.qml
        controls/CachyScrollablePage.qml
        controls/CachySearchField.qml
        controls/CachyAboutPage.qml
        controls/CachyDialog.qml
)

target_include_directories(cachyosui PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/core>
    $<INSTALL_INTERFACE:${KDE_INSTALL_INCLUDEDIR}/CachyOSUI>
)

target_link_libraries(cachyosui PUBLIC
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    KF6::WindowSystem
    KF6::CoreAddons
    KF6::I18n
)

set_target_properties(cachyosui PROPERTIES
    VERSION ${PROJECT_VERSION}
    SOVERSION 1
    EXPORT_NAME cachyosui
    CXX_VISIBILITY_PRESET default
    VISIBILITY_INLINES_HIDDEN OFF
)

set_target_properties(cachyosuiplugin PROPERTIES
    PREFIX "lib"
    OUTPUT_NAME "cachyosuiplugin"
)

# QML Module installation
set(CACHYOS_QML_DIR "lib/qt6/qml/CachyOS/UI")

install(TARGETS cachyosui
    EXPORT CachyOSUITargets
    LIBRARY DESTINATION ${KDE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${KDE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

install(FILES
    core/cachytheme.h
    core/cachyi18n.h
    core/cachywindowblur.h
    core/cachywindowshadow.h
    core/cachysortfilterproxymodel.h
    DESTINATION ${KDE_INSTALL_INCLUDEDIR}/CachyOSUI
)

install(EXPORT CachyOSUITargets
    FILE CachyOSUITargets.cmake
    NAMESPACE CachyOSUI::
    DESTINATION ${KDE_INSTALL_LIBDIR}/cmake/CachyOSUI
)

configure_package_config_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/CachyOSUIConfig.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/CachyOSUIConfig.cmake
    INSTALL_DESTINATION ${KDE_INSTALL_LIBDIR}/cmake/CachyOSUI
)

write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/CachyOSUIConfigVersion.cmake
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
)

install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/CachyOSUIConfig.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/CachyOSUIConfigVersion.cmake
    DESTINATION ${KDE_INSTALL_LIBDIR}/cmake/CachyOSUI
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
