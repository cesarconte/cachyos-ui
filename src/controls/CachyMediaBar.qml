/*
 * SPDX-FileCopyrightText: 2026 CachyOS UI contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Universal Media Transport Bar of the CachyOS.UI design system (Golden Gate / Liquid Glass).
 * Standardized audio/video playback bar for AudioTube, media players and streaming widgets.
 * Features cover art, track metadata, responsive transport controls, scrub timeline and volume.
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import CachyOS.UI

Rectangle {
    id: root

    // ── Track Metadata ─────────────────────────────────────────────────────
    property string trackTitle: CachyI18n.i18n("Ningún medio en reproducción")
    property string trackArtist: ""
    property string coverArtSource: ""
    property string defaultIconName: "audio-x-generic"

    // ── Playback State ─────────────────────────────────────────────────────
    property bool isPlaying: false
    property bool isShuffle: false
    property bool isRepeat: false
    property bool isFavorite: false
    property real position: 0.0 // 0.0 to 1.0
    property int positionSeconds: 0
    property int durationSeconds: 0
    property real volume: 0.8 // 0.0 to 1.0
    property bool isMuted: false

    // ── Public Signals ─────────────────────────────────────────────────────
    signal playRequested()
    signal pauseRequested()
    signal nextRequested()
    signal previousRequested()
    signal shuffleToggled(bool active)
    signal repeatToggled(bool active)
    signal favoriteToggled(bool active)
    signal seekRequested(real position)
    signal volumeModified(real volume)

    function formatTime(seconds: int): string {
        var m = Math.floor(seconds / 60);
        var s = seconds % 60;
        return (m < 10 ? "0" : "") + String(m) + ":" + (s < 10 ? "0" : "") + String(s);
    }

    implicitWidth: 720
    implicitHeight: 76
    color: CachyPalette.cardBackground
    border.width: 0

    // 1px Top Divider
    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 1
        color: CachyPalette.hardDividerColor
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: CachyTheme.marginWindow
        anchors.rightMargin: CachyTheme.marginWindow
        spacing: 16

        // ── 1. Left Zone: Cover Art & Track Info ───────────────────────────
        RowLayout {
            Layout.preferredWidth: 220
            Layout.fillHeight: true
            spacing: 12

            Rectangle {
                Layout.preferredWidth: 44
                Layout.preferredHeight: 44
                radius: CachyTheme.radiusSmall
                color: Qt.rgba(0, 0, 0, 0.20)
                border.width: 1
                border.color: CachyPalette.specularBorder
                clip: true

                Image {
                    id: coverArtImage
                    anchors.fill: parent
                    source: root.coverArtSource
                    visible: root.coverArtSource.length > 0 && status === Image.Ready
                    fillMode: Image.PreserveAspectCrop
                }

                CachyIcon {
                    anchors.centerIn: parent
                    size: 22
                    name: root.defaultIconName
                    color: CachyPalette.textMuted
                    visible: !root.coverArtSource.length || coverArtImage.status !== Image.Ready
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                spacing: 2

                Text {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    text: root.trackTitle
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    color: CachyPalette.text
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    text: root.trackArtist.length > 0 ? root.trackArtist : CachyI18n.i18n("Detenido")
                    font.pixelSize: 11
                    color: CachyPalette.textSecondary
                    elide: Text.ElideRight
                }
            }

            CachyToolbarButton {
                iconName: root.isFavorite ? "favorite" : "favorite-outline"
                tooltipText: root.isFavorite ? CachyI18n.i18n("Quitar de favoritas") : CachyI18n.i18n("Marcar como favorita")
                onClicked: {
                    root.isFavorite = !root.isFavorite;
                    root.favoriteToggled(root.isFavorite);
                }
            }
        }

        // ── 2. Center Zone: Transport & Scrubber ───────────────────────────
        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            spacing: 4

            // Transport Buttons Row
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 12

                CachyToolbarButton {
                    iconName: "media-playlist-shuffle"
                    checked: root.isShuffle
                    tooltipText: CachyI18n.i18n("Aleatorio")
                    onClicked: {
                        root.isShuffle = !root.isShuffle;
                        root.shuffleToggled(root.isShuffle);
                    }
                }

                CachyToolbarButton {
                    iconName: "media-skip-backward"
                    tooltipText: CachyI18n.i18n("Anterior")
                    onClicked: root.previousRequested()
                }

                // Main Play/Pause Button
                Rectangle {
                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 36
                    radius: 18
                    color: CachyTheme.accentColor

                    CachyIcon {
                        anchors.centerIn: parent
                        size: 16
                        name: root.isPlaying ? "media-playback-pause" : "media-playback-start"
                        color: "#FFFFFF"
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.isPlaying) {
                                root.pauseRequested();
                            } else {
                                root.playRequested();
                            }
                        }
                    }
                }

                CachyToolbarButton {
                    iconName: "media-skip-forward"
                    tooltipText: CachyI18n.i18n("Siguiente")
                    onClicked: root.nextRequested()
                }

                CachyToolbarButton {
                    iconName: "media-playlist-repeat"
                    checked: root.isRepeat
                    tooltipText: CachyI18n.i18n("Repetir")
                    onClicked: {
                        root.isRepeat = !root.isRepeat;
                        root.repeatToggled(root.isRepeat);
                    }
                }
            }

            // Timeline & Scrubber Row
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: root.formatTime(root.positionSeconds)
                    font.pixelSize: 10
                    color: CachyPalette.textMuted
                }

                CachyWaveformSlider {
                    Layout.fillWidth: true
                    position: root.position
                    onSeekRequested: (pos) => root.seekRequested(pos)
                }

                Text {
                    text: root.formatTime(root.durationSeconds)
                    font.pixelSize: 10
                    color: CachyPalette.textMuted
                }
            }
        }

        // ── 3. Right Zone: Volume Controls ─────────────────────────────────
        RowLayout {
            Layout.preferredWidth: 160
            Layout.alignment: Qt.AlignRight
            spacing: 8

            CachyToolbarButton {
                iconName: root.isMuted || root.volume === 0 ? "audio-volume-muted" : "audio-volume-high"
                tooltipText: root.isMuted ? CachyI18n.i18n("Desactivar silencio") : CachyI18n.i18n("Silenciar")
                onClicked: {
                    root.isMuted = !root.isMuted;
                }
            }

            CachySlider {
                Layout.fillWidth: true
                from: 0.0
                to: 1.0
                value: root.isMuted ? 0.0 : root.volume
                onMoved: {
                    root.isMuted = false;
                    root.volume = value;
                    root.volumeModified(value);
                }
            }
        }
    }
}
