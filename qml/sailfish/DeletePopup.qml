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
import Sailfish.Silica 1.0

RemorseItem {
    property string file
    property Item item
    property Item page

    property bool _triggered

    function doDelete() {
        _triggered = true
        item.deleteUrl()
    }

    Component.onDestruction: {
        if (_triggered) {
            item.deleteUrlNow()
        }
    }

    function open() {
        execute(item, qsTr("Deleting %1").arg(file), doDelete)
    }
}
