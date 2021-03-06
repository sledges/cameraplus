// -*- c++ -*-

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

#ifndef PLATFORM_SETTINGS_H
#define PLATFORM_SETTINGS_H

#include <QObject>
#include <QColor>
#include <QSize>

class QSettings;

class PlatformSettings : public QObject {
  Q_OBJECT

  Q_PROPERTY(QString imageCaptureStartedSound READ imageCaptureStartedSound CONSTANT);
  Q_PROPERTY(QString imageCaptureEndedSound READ imageCaptureEndedSound CONSTANT);
  Q_PROPERTY(QString videoRecordingStartedSound READ videoRecordingStartedSound CONSTANT);
  Q_PROPERTY(QString videoRecordingEndedSound READ videoRecordingEndedSound CONSTANT);
  Q_PROPERTY(QString autoFocusAcquiredSound READ autoFocusAcquiredSound CONSTANT);
  Q_PROPERTY(QString autoFocusFailedSound READ autoFocusFailedSound CONSTANT);
  Q_PROPERTY(QString imagePath READ imagePath CONSTANT);
  Q_PROPERTY(QString videoPath READ videoPath CONSTANT);
  Q_PROPERTY(QString temporaryVideoPath READ temporaryVideoPath CONSTANT);
  Q_PROPERTY(int maximumVideoDuration READ maximumVideoDuration CONSTANT);
  Q_PROPERTY(bool naturalOrientationIsLandscape READ naturalOrientationIsLandscape CONSTANT);
  Q_PROPERTY(int primarySensorOrientationAngle READ primarySensorOrientationAngle CONSTANT);
  Q_PROPERTY(int secondarySensorOrientationAngle READ secondarySensorOrientationAngle CONSTANT);

public:
  PlatformSettings(QObject *parent = 0);
  ~PlatformSettings();

  class Service {
  public:
    bool m_enabled;
    QString m_type;
    QString m_path;
    QString m_interface;
    QString m_dest;
    QString m_method;
  };

  QSize previewSize();
  QString previewFlavorName();

  QSize gridSize();
  QString gridFlavorName();

  QString thumbnailExtension();
  QColor backgroundRenderingColor();
  bool isDBusThumbnailingEnabled();
  bool isThumbnailCreationEnabled();
  QString temporaryFilePath();

  Service service(const QString& id);

  QString imageCaptureStartedSound() const;
  QString imageCaptureEndedSound() const;
  QString videoRecordingStartedSound() const;
  QString videoRecordingEndedSound() const;
  QString autoFocusAcquiredSound() const;
  QString autoFocusFailedSound() const;

  QString imagePath();
  QString videoPath();
  QString temporaryVideoPath();

  int maximumVideoDuration() const;

  int naturalOrientationIsLandscape() const;

  int primarySensorOrientationAngle() const;
  int secondarySensorOrientationAngle() const;

public slots:
  void init();

private:
  QString canonicalPath(const QString& path) const;

  QSettings *m_settings;

  QString m_image;
  QString m_video;
  QString m_temp;
};

#endif /* PLATFORM_SETTINGS_H */
