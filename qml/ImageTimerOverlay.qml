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

Item {
    id: overlay

    property Camera cam
    property bool animationRunning: false
    property int policyMode: CameraResources.Image
    property bool pressed: capture.pressed || zoomSlider.pressed || modeButton.pressed || captureTimer.running
    property bool controlsVisible: imageMode.canCapture && cam.running && !animationRunning
        && !modeController.busy && !captureTimer.running
    property bool inhibitDim: captureTimer.running

    signal previewAvailable(string uri)

    anchors.fill: parent

    ImageMode {
        id: imageMode
        camera: cam

        onCaptureEnded: stopAutoFocus()

        enablePreview: settings.enablePreview

        onPreviewAvailable: overlay.previewAvailable(preview)

        onSaved: mountProtector.unlock(platformSettings.imagePath)
    }

    ZoomSlider {
        id: zoomSlider
        camera: cam
        visible: controlsVisible && !captureControl.capturing
    }

    CameraLabel {
        id: countDown
        property int value

        anchors.centerIn: parent
        visible: captureTimer.running
        text: value
        color: "white"
        styleColor: "black"
        style: Text.Outline
        font.pixelSize: 36

        onVisibleChanged: {
            if (visible) {
                countDown.value = delay.value
            }
        }

        Timer {
            interval: 1000
            running: captureTimer.running
            onTriggered: countDown.value--
            repeat: true
        }
    }

    ModeButton {
        id: modeButton
        anchors.horizontalCenter: capture.horizontalCenter
        anchors.top: capture.bottom
        anchors.topMargin: 20
        visible: controlsVisible && !captureControl.capturing
    }

    CaptureButton {
        id: capture
        iconSource: cameraTheme.selfTimerIconId
        visible: controlsVisible

        onExited: {
            if (mouseX <= 0 || mouseY <= 0 || mouseX > width || mouseY > height) {
                // Release outside the button:
                captureControl.canceled = true
            }
        }
    }

    Timer {
        id: autoFocusTimer
        interval: 200
        running: captureControl.state == "capturing"
        repeat: false
        onTriggered: {
            if (cam.autoFocus.cafStatus != AutoFocus.Success) {
                startAutoFocus()
            } else {
                cam.sounds.playAutoFocusAcquiredSound()
            }
        }
    }

    Timer {
        id: captureTimer
        interval: delay.value * 1000
        onTriggered: {
            metaData.setMetaData()

            var fileName = fileNaming.imageFileName()
            if (!imageMode.capture(fileName)) {
                showError(qsTr("Failed to capture image. Please restart the camera."))
                mountProtector.unlock(platformSettings.imagePath)
                stopAutoFocus()
            } else {
                trackerStore.storeImage(fileName)
            }
        }
    }

    ZoomCaptureButton {
        id: zoomCapture
    }

    CaptureControl {
        id: captureControl
        capturePressed: capture.pressed
        zoomPressed: zoomCapture.zoomPressed
        proximityClosed: proximitySensor.sensorClosed
        onStartCapture: captureImage()
        onCancelCapture: stopAutoFocus()
        enable: inCaptureView
    }

    CaptureCancel {
        anchors.fill: parent
        enabled: captureControl.showCancelBanner
        onPressed: captureControl.canceled = true
    }

    CameraSlider {
        id: delay
        anchors.bottom: toolBar.top
        anchors.horizontalCenter: parent.horizontalCenter
        visible: controlsVisible && !captureControl.capturing && !selectedLabel.visible
        width: 500
        opacity: 0.8
        minimumValue: 1
        maximumValue: 20
        stepSize: 1
        value: settings.captureTimerDelay
        onValueChanged: {
            if (pressed) {
                settings.captureTimerDelay = value
            }
        }
        valueIndicatorVisible: true
        valueIndicatorText: formatValue(value)
        function formatValue(value) {
            return qsTr("%1 seconds").arg(value)
        }
    }

    CameraToolBarLabel {
        id: selectedLabel
        anchors.bottom: toolBar.top
        anchors.bottomMargin: 20
        visible: controlsVisible && !captureControl.capturing && text != ""
    }

    ImageModeToolBar {
        id: toolBar
        selectedLabel: selectedLabel
        visible: controlsVisible && !captureControl.capturing
    }

    ImageModeIndicators {
        id: indicators
        visible: controlsVisible && !captureControl.capturing
    }

    Connections {
        target: rootWindow
        onActiveChanged: {
            if (!rootWindow.active && captureTimer.running) {
                overlay.policyLost()
            }
        }
    }

    CaptureCancel {
            anchors.fill: parent
            enabled: captureTimer.running
            onClicked: policyLost()
    }

    function cameraError() {
        policyLost()
    }

    function policyLost() {
        captureTimer.stop()
        stopAutoFocus()
        mountProtector.unlock(platformSettings.imagePath)
    }

    function captureImage() {
        if (!imageMode.canCapture) {
            showError(qsTr("Camera is already capturing an image."))
            stopAutoFocus()
        } else if (!batteryMonitor.good) {
            showError(qsTr("Not enough battery to capture images."))
            stopAutoFocus()
        } else if (!fileSystem.available) {
            showError(qsTr("Camera cannot capture images in mass storage mode."))
            stopAutoFocus()
        } else if (!fileSystem.hasFreeSpace(platformSettings.imagePath)) {
            showError(qsTr("Not enough space to capture images."))
            stopAutoFocus()
        } else if (!mountProtector.lock(platformSettings.imagePath)) {
            showError(qsTr("Failed to lock images directory."))
            stopAutoFocus()
        } else {
            captureTimer.start()
        }
    }

    function startAutoFocus() {
        if (deviceFeatures().isAutoFocusSupported) {
            cam.autoFocus.startAutoFocus()
        }
    }

    function stopAutoFocus() {
        if (deviceFeatures().isAutoFocusSupported) {
            if (!autoFocusTimer.running) {
                cam.autoFocus.stopAutoFocus()
            }
        }
    }

    function resetToolBar() {
        if (toolBar.depth() > 1) {
            toolBar.pop()
        }
    }

    function cameraDeviceChanged() {
        resetToolBar()
    }

    function applySettings() {
        var s = deviceSettings()

        camera.scene.value = s.imageSceneMode
        camera.flash.value = s.imageFlashMode
        camera.evComp.value = s.imageEvComp
        camera.whiteBalance.value = s.imageWhiteBalance
        camera.colorTone.value = s.imageColorFilter
        camera.iso.value = s.imageIso
        camera.focus.value = Focus.ContinuousNormal

        imageSettings.setImageResolution()
    }
}
