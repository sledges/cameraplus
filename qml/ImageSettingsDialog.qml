// -*- qml -*-

/*!
 * This file is part of CameraPlus.
 *
 * Copyright (C) 2012 Mohammed Sameer <msameer@foolab.org>
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

import QtQuick 1.1
import com.nokia.meego 1.1
import QtCamera 1.0
import "ImageSettingsDialog.js" as Util

Dialog {
        id: dialog

        content: item

        Connections {
                target: Qt.application
                onActiveChanged: {
                        if (!Qt.application.active) {
                                dialog.close();
                        }
                }
        }

        onStatusChanged: {
                if (status == DialogStatus.Open) {
                        cam.renderingEnabled = false;
                }
                else if (status == DialogStatus.Closing) {
                        cam.renderingEnabled = true;
                }
        }

        Item {
                id: item
                width: parent.width
                height: root.height

                Flickable {
                        id: flickable
                        anchors.fill: parent
                        anchors.margins: 10
                        contentHeight: col.height

                        Column {
                                id: col

                                width: parent.width
                                spacing: 10

                                Label {
                                        font.pixelSize: 36
                                        text: qsTr("Image settings");
                                }

                                SectionHeader {
                                        text: qsTr("Aspect ratio");
                                }

                                ButtonRow {
                                        id: aspectRatioRow
                                        width: parent.width

                                        exclusive: false
                                        onCheckedButtonChanged: {
                                                // This is needed to initially setup the
                                                // resolutions buttons
                                                Util.resetAspectRatio(aspectRatioRow);
                                        }

                                        Repeater {
                                                model: imageSettings.aspectRatios
                                                delegate: Button {
                                                        property string aspect: modelData;
                                                        text: qsTr(modelData);
                                                        checked: settings.imageAspectRatio == modelData;
                                                        onClicked: Util.setAspectRatio(modelData);
                                                }
                                        }
                                }

                                SectionHeader {
                                        text: qsTr("Resolution");
                                }

                                ButtonRow {
                                        id: resolutionsRow
                                        width: parent.width

                                        exclusive: false

                                        Repeater {
                                                id: resolutions
                                                model: imageSettings.resolutions

                                                // http://stackoverflow.com/questions/1026069/capitalize-the-first-letter-of-string-in-javascript
                                                function name(name, mp) {
                                                        return name.charAt(0).toUpperCase() + name.slice(1) + " " + mp + " Mpx";
                                                }

                                                delegate: Button {
                                                        property string resolution: resolutionName
                                                        property string aspectRatio: resolutionAspectRatio
                                                        text: resolutions.name(resolutionName, megaPixels);
                                                        checked: settings.imageResolution == resolutionName
                                                        onClicked: Util.setResolution(resolutionName);
                                                }
                                        }
                                }

                                Item {
                                        width: parent.width
                                        height: Math.max(enableFaceDetectionLabel.height, enableFaceDetection.height);

                                        Label {
                                                id: enableFaceDetectionLabel
                                                anchors.left: parent.left
                                                text: qsTr("Enable face detection");
                                        }

                                        Switch {
                                                id: enableFaceDetection
                                                anchors.right: parent.right
                                                // We have to do it that way because QML complains about a binding
                                                // loop for checked if we bind the checked property to the settings value.
                                                Component.onCompleted: checked = settings.faceDetectionEnabled;
                                                onCheckedChanged: settings.faceDetectionEnabled = checked;
                                        }
                                }

                                CameraSettings {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                }
                        }
                }
        }
}