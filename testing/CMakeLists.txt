# SPDX-FileCopyrightText: 2026 CachyOS UI contributors
# SPDX-License-Identifier: GPL-3.0-or-later
#
# CachyOS.UI testing helpers.
#
# Small, dependency free helpers that encode the layout invariants of the
# Golden Gate design language, so every application of the ecosystem can
# verify them automatically instead of relying on visual inspection.

include(CMakePackageConfigHelpers)

add_library(CachyOSUITesting STATIC
    LayoutAuditor.cpp
    LayoutAuditor.h
)

target_include_directories(CachyOSUITesting PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<INSTALL_INTERFACE:${KDE_INSTALL_INCLUDEDIR}/CachyOSUITesting>
)

target_link_libraries(CachyOSUITesting PUBLIC
    Qt6::Core
    Qt6::Gui
    Qt6::Quick
)

set_target_properties(CachyOSUITesting PROPERTIES
    POSITION_INDEPENDENT_CODE ON
    VERSION ${PROJECT_VERSION}
)

# ---------------------------------------------------------------------------
# Installation: a tiny CMake package the applications can consume with
#   find_package(CachyOSUITesting REQUIRED)
#   target_link_libraries(<test> PRIVATE CachyOSUITesting::CachyOSUITesting)
# ---------------------------------------------------------------------------
install(TARGETS CachyOSUITesting
    EXPORT CachyOSUITestingTargets
    ARCHIVE DESTINATION ${KDE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${KDE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

install(FILES LayoutAuditor.h
    DESTINATION ${KDE_INSTALL_INCLUDEDIR}/CachyOSUITesting
)

install(EXPORT CachyOSUITestingTargets
    FILE CachyOSUITestingTargets.cmake
    NAMESPACE CachyOSUITesting::
    DESTINATION ${KDE_INSTALL_LIBDIR}/cmake/CachyOSUITesting
)

configure_package_config_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/CachyOSUITestingConfig.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/CachyOSUITestingConfig.cmake
    INSTALL_DESTINATION ${KDE_INSTALL_LIBDIR}/cmake/CachyOSUITesting
)

write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/CachyOSUITestingConfigVersion.cmake
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
)

install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/CachyOSUITestingConfig.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/CachyOSUITestingConfigVersion.cmake
    DESTINATION ${KDE_INSTALL_LIBDIR}/cmake/CachyOSUITesting
)
