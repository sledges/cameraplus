// -*- qml -*-

/*!
 * This file is part of CameraPlus.
 *
 * Copyright (C) 2012-2014 Mohammed Sameer <msameer@foolab.org>
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

import QtQuick 2.0
import QtCamera 1.0
import CameraPlus 1.0

MouseArea {
    id: mouse
    x: renderArea.x
    y: renderArea.y
    width: renderArea.width
    height: renderArea.height

    property variant videoResolution
    onVideoResolutionChanged: resetReticle()

    property variant renderArea

    property int cafStatus
    property int status
    property Camera cam
    property bool touchMode

    property variant touchPoint: Qt.point(mouse.width / 2, mouse.height / 2)

    // A 100x100 central "rectangle"
    property variant centerRect: Qt.rect((mouse.width / 2 - 50), (mouse.height / 2) - 50, 100, 100)

    // ROI:
    property variant primaryRoiRect: Qt.rect(0, 0, 0, 0)
    property variant roiRects
    property variant allRoiRects
    property bool roiMode: allRoiRects != null && allRoiRects.length > 0 && !touchMode && !pressed && settings.faceDetectionEnabled

    onRoiModeChanged: {
        if (!roiMode) {
            resetReticle()
        }
    }

    enabled: deviceFeatures().isTouchFocusSupported

    property variant __initialPos
    onPressed: {
        if (mouse.x >= reticle.x &&
            mouse.y >= reticle.y &&
            mouse.x <= reticle.x + reticle.width &&
            mouse.y <= reticle.y + reticle.height) {
        }

        __initialPos = touchPoint
        calculateTouchPoint(mouse.x, mouse.y)
    }

    onCanceled: {
        calculateTouchPoint(__initialPos.x, __initialPos.y)
    }

    onDoubleClicked: {
        resetReticle()
    }

    function resetReticle() {
        calculateTouchPoint(centerRect.x, centerRect.y)
    }

    function setRegionOfInterest() {
        if (!cam) {
            // console.log("Cannot set ROI without camera object")
            return
        } else if (!touchMode && !roiMode) {
            // console.log("resetting ROI")
            if (cam.roi) {
                cam.roi.resetRegionOfInterest()
            }

            return
        }

//        console.log("Setting ROI to: " + reticle.x + "x" + reticle.y + " -> " + reticle.width + "x" + reticle.height)
        cam.roi.setRegionOfInterest(cameraPosition.toSensorCoordinates(Qt.rect(reticle.x, reticle.y, reticle.width, reticle.height), Qt.point(mouse.width / 2, mouse.height / 2)))
    }

    function calculateTouchPoint(x, y) {
        if (x >= centerRect.x && y >= centerRect.y &&
            x <= centerRect.x + centerRect.width &&
            y <= centerRect.y + centerRect.height) {
                touchMode = false
                touchPoint = Qt.point(mouse.width / 2, mouse.height / 2)
                return
        }

        touchMode = true
        touchPoint = Qt.point(x, y)
    }

    function predictColor(caf, status) {
        if (status == AutoFocus.Success) {
            return "steelblue"
        } else if (status == AutoFocus.Fail) {
            return "red"
        } else if (status == AutoFocus.Running) {
            return "white"
        } else if (caf == AutoFocus.Success) {
            return "steelblue"
        } else {
            return "white"
        }
    }

    Repeater {
        anchors.fill: parent
        model: roiMode ? roiRects : 0

        delegate: Rectangle {
            property variant roiRect: cameraPosition.fromSensorCoordinates(modelData, Qt.point(mouse.width / 2, mouse.height / 2))
            x: roiRect.x
            y: roiRect.y
            width: roiRect.width
            height: roiRect.height
            color: "transparent"
            border.color: "gray"
            border.width: 2
        }
    }

    FocusRectangle {
        id: reticle
        width: mouse.pressed ? 150 : mouse.touchMode ? 200 : roiMode ? primaryRoiRect.width : 250
        height: mouse.pressed ? 90 : mouse.touchMode ? 120 : roiMode ? primaryRoiRect.height : 150
        x: Math.min(Math.max(mouse.touchPoint.x - (width / 2), 0), mouse.width - reticle.width)
        y: Math.min(Math.max(mouse.touchPoint.y - (height / 2), 0), mouse.height - reticle.height)
        color: predictColor(cafStatus, status)

        onXChanged: setRegionOfInterest()
        onYChanged: setRegionOfInterest()

        Behavior on width {
            PropertyAnimation { duration: 100 }
        }

        Behavior on height {
            PropertyAnimation { duration: 100 }
        }

    }

    Connections {
        target: cam
        onRunningChanged: resetReticle()
    }

    Connections {
        target: root
        onActivePluginChanged: resetReticle()
    }

    Connections {
        target: cameraPosition
        onApplicationOrientationAngleChanged: resetReticle()
    }

    Connections {
        target: cam.roi
        onRegionsChanged: {
            allRoiRects = regions
            // Repeater delegate will take care of transforming the rest of the rectangles.
            primaryRoiRect = cameraPosition.fromSensorCoordinates(primary, Qt.point(mouse.width / 2, mouse.height / 2))
            roiRects = rest

            if (regions.length == 0) {
                resetReticle()
                return
            }

            touchPoint = Qt.point(primary.x + (reticle.width / 2),
                primary.y + (reticle.height / 2))
        }
    }

    /*
    // This is for debugging
    Rectangle {
        color: "blue"
        opacity: 0.2
        anchors.fill: parent
    }

    Rectangle {
        color: "red"
        opacity: 0.4
        x: centerRect.x
        y: centerRect.y
        width: centerRect.width
        height: centerRect.height
    }
    */
    Timer {
        interval: 500
        running: status == AutoFocus.Running
        triggeredOnStart: true
        repeat: true
        onTriggered: reticle.visible = !reticle.visible
        onRunningChanged: {
            if (!running) {
                reticle.visible = true
            }
        }
    }
}
