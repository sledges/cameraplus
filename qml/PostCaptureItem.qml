// -*- qml -*-

/*!
 * This file is part of CameraPlus.
 *
 * Copyright (C) 2012-2013 Mohammed Sameer <msameer@foolab.org>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */

@IMPORT_QT_QUICK@
import com.nokia.meego 1.1
import CameraPlus 1.0

Item {
    id: postCaptureItem
    property bool isVideo: itemData.type.search("nmm#Video") > 0
    property alias error: image.error
    property variant itemData: item
    property bool playing: loader.source != ""
    signal clicked

    function startPlayback() {
        loader.source = Qt.resolvedUrl("VideoPlayerPage.qml")
        loader.item.source = itemData.url
        if (!loader.item.play()) {
            showError(qsTr("Error playing video. Please try again."))
            loader.source = ""
        }
    }

    function stopPlayback() {
        if (loader.item) {
            loader.item.stop()
        }
    }

    Loader {
        id: loader
        anchors.fill: parent
    }

    Connections {
        target: loader.item
        onFinished: loader.source = ""
    }

    QuillItem {
        id: image
        width: parent.width - 10
        height: parent.height
        anchors.centerIn: parent
        Component.onCompleted: initialize(itemData.url, itemData.mimetype)
        visible: loader.source == ""

        Label {
            anchors.fill: parent
            visible: image.error
            text: qsTr("Failed to load preview")
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 32
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            enabled: true
            onClicked: postCaptureItem.clicked()
        }

        ToolIcon {
            // TODO: this is overlapping with error.
            id: playIcon
            anchors.centerIn: parent
            iconSource: "image://theme/icon-s-music-video-play"
            visible: isVideo
            onClicked: startPlayback()
        }
    }
}
