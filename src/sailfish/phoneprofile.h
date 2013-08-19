// -*- c++ -*-

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

#ifndef PHONE_PROFILE_H
#define PHONE_PROFILE_H

#include <QObject>

class PhoneProfile : public QObject {
  Q_OBJECT

  Q_PROPERTY(bool isSilent READ isSilent NOTIFY isSilentChanged);

public:
  PhoneProfile(QObject *parent = 0);
  ~PhoneProfile();

  bool isSilent();

signals:
  void isSilentChanged();

private:
  bool m_isSilent;
};

#endif /* PHONE_PROFILE_H */
