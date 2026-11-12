# SPDX-FileCopyrightText: 2026 CachyOS UI contributors
# SPDX-License-Identifier: GPL-3.0-or-later

add_executable(test_cachyi18n
    test_cachyi18n.cpp
    ../src/core/cachyi18n.cpp
    ../src/core/cachyi18n.h
    ../src/core/cachytheme.cpp
    ../src/core/cachytheme.h
)

target_include_directories(test_cachyi18n PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/../src/core)
target_link_libraries(test_cachyi18n PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::Test
    KF6::I18n
    KF6::CoreAddons
)

add_test(NAME test_cachyi18n COMMAND test_cachyi18n)

# ---------------------------------------------------------------------------
# QML test of the checkable state of CachyToolbarButton.
# ---------------------------------------------------------------------------
# qmltestrunner usually lives in the Qt bin directory, which is not in PATH.
get_target_property(QMAKE_EXECUTABLE Qt6::qmake IMPORTED_LOCATION)
get_filename_component(QT6_BIN_DIR "${QMAKE_EXECUTABLE}" DIRECTORY)
find_program(QMLTESTRUNNER_EXECUTABLE NAMES qmltestrunner HINTS "${QT6_BIN_DIR}")

if(QMLTESTRUNNER_EXECUTABLE)
    add_test(
        NAME test_toolbarbutton
        COMMAND ${QMLTESTRUNNER_EXECUTABLE}
                -input ${CMAKE_CURRENT_SOURCE_DIR}/tst_toolbarbutton.qml
                -import ${CMAKE_INSTALL_PREFIX}/lib/qt6/qml
                -import $ENV{HOME}/.local/lib/qt6/qml
    )
    set_tests_properties(test_toolbarbutton PROPERTIES
        ENVIRONMENT "QT_QPA_PLATFORM=offscreen;QT_QUICK_CONTROLS_STYLE=Basic"
    )
else()
    message(STATUS "qmltestrunner was not found: the QML tests are skipped")
endif()
