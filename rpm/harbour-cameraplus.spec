%define __provides_exclude_from ^%{_datadir}/.*$
%define __requires_exclude ^libqtcamera.so.1|libFLAC.so.8|libavcodec.so.55|libavformat.so.55|libavutil.so.53|libbz2.so.1|libdbus-qeventloop-qt5.so.1|libffmpegthumbnailer.so.4|libgstapp-1.0.so.0|libgstaudio-1.0.so.0|libgstbase-1.0.so.0|libgstbasecamerabinsrc-1.0.so.0|libgstcodecparsers-1.0.so.0|libgstfft-1.0.so.0|libgstnemointerfaces-1.0.so.0|libgstnemometa-1.0.so.0|libgstnet-1.0.so.0|libgstpbutils-1.0.so.0|libgstphotography-1.0.so.0|libgstreamer-1.0.so.0|libgstriff-1.0.so.0|libgstrtp-1.0.so.0|libgstrtsp-1.0.so.0|libgstsdp-1.0.so.0|libgsttag-1.0.so.0|libgstvideo-1.0.so.0|libjpeg.so.62|libogg.so.0|libopus.so.0|liborc-0.4.so.0|liborc-test-0.4.so.0|libquill-qt5.so.1|libquillimagefilter-qt5.so.1|libquillmetadata-qt5.so.1|libresourceqt5.so.1|libsndfile.so.1|libspeex.so.1|libswscale.so.2|libtheoradec.so.1|libtheoraenc.so.1|libvo-aacenc.so.0|libvorbis.so.0|libvorbisenc.so.2|libresource.so.0|libgstdroidmemory-1.0.so.0|libgstgl-1.0.so.0|libgstbadbase-1.0.so.0|libgstbadvideo-1.0.so.0$

Name:           harbour-cameraplus
Summary:        Cameraplus is an advanced easy to use camera
Version:        0
Release:        1
Group:          Applications/Multimedia
License:        LGPL v2.1+
URL:            http://gitorious.org/cameraplus
Source0:        %{name}-%{version}.tar.gz
Source1:        harbour-cameraplus.desktop
Source2:        harbour-cameraplus.png
Source3:        qmake.conf
Source11:       binaries-droid.tgz
BuildRequires:  pkgconfig(gstreamer-1.0)
BuildRequires:  pkgconfig(gstreamer-plugins-base-1.0)
BuildRequires:  pkgconfig(gstreamer-video-1.0)
BuildRequires:  pkgconfig(gstreamer-plugins-bad-1.0)
BuildRequires:  pkgconfig(gstreamer-pbutils-1.0)
BuildRequires:  pkgconfig(nemo-gstreamer-interfaces-1.0)
BuildRequires:  pkgconfig(nemo-gstreamer-meta-1.0)
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(qdeclarative5-boostable)
BuildRequires:  pkgconfig(Qt5Gui)
BuildRequires:  pkgconfig(Qt5Network)
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  pkgconfig(Qt5DBus)
BuildRequires:  pkgconfig(Qt5Sparql)
BuildRequires:  pkgconfig(Qt5Sensors)
BuildRequires:  pkgconfig(Qt5Test)
BuildRequires:  pkgconfig(libresourceqt5)
BuildRequires:  pkgconfig(Qt5SystemInfo)
BuildRequires:  pkgconfig(quill-qt5)
BuildRequires:  pkgconfig(contextkit-statefs)
BuildRequires:  pkgconfig(sndfile)
BuildRequires:  pkgconfig(libpulse)
BuildRequires:  desktop-file-utils
Requires:       qt5-qtdeclarative-import-positioning
Requires:       qt5-qtdeclarative-import-sensors
# These are there so we can copy the binaries we need
BuildRequires:  gstreamer1.0-libav
BuildRequires:  gstreamer1.0
BuildRequires:  gstreamer1.0-plugins-base
BuildRequires:  gstreamer1.0-plugins-bad
BuildRequires:  gstreamer1.0-plugins-good
BuildRequires:  quill-qt5-utils
BuildRequires:  gstreamer1.0-tools
%description
Cameraplus is an advanced easy to use camera

%prep
%setup -q

%build
cp %SOURCE3 .qmake.conf
%qmake5

make %{?jobs:-j%jobs}

%install
%qmake5_install

# icon
mkdir -p $RPM_BUILD_ROOT/usr/share/icons/hicolor/86x86/apps/
cp %SOURCE2 $RPM_BUILD_ROOT/usr/share/icons/hicolor/86x86/apps/

# qtcamera configuration
mkdir -p $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/share/qtcamera/config/
cp data/sailfish/qtcamera.ini $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/share/qtcamera/config/
cp data/sailfish/resolutions.ini $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/share/qtcamera/config/
cp data/sailfish/video.gep $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/share/qtcamera/config/
cp data/sailfish/image.gep $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/share/qtcamera/config/
cp data/sailfish/properties.ini $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/share/qtcamera/config/

# cameraplus configuration
mkdir -p $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/share/cameraplus/config/
cp data/sailfish/cameraplus.ini $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/share/cameraplus/config/
cp data/sailfish/features.ini $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/share/cameraplus/config/

# desktop file
mkdir -p $RPM_BUILD_ROOT/usr/share/applications/
cp %SOURCE1 $RPM_BUILD_ROOT/usr/share/applications/

desktop-file-install --delete-original                   \
  --dir %{buildroot}%{_datadir}/applications             \
   %{buildroot}%{_datadir}/applications/*.desktop

mv $RPM_BUILD_ROOT/usr/bin/cameraplus $RPM_BUILD_ROOT/usr/bin/harbour-cameraplus

mkdir -p $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/lib/
mv $RPM_BUILD_ROOT/usr/lib/libqtcamera.so.1.0.0 $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/lib/libqtcamera.so.1
rm $RPM_BUILD_ROOT/usr/lib/libqtcamera.so.1.0
rm $RPM_BUILD_ROOT/usr/lib/libqtcamera.so.1
rm $RPM_BUILD_ROOT/usr/lib/libqtcamera.so

mkdir -p $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/lib/qt5/qml
mv $RPM_BUILD_ROOT/usr/lib/qt5/imports/QtCamera $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/lib/qt5/qml/
rm -rf $RPM_BUILD_ROOT/usr/lib/qt5/imports

mkdir -p $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/share/sounds/
cp sounds/*.wav $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/share/sounds/

mkdir -p $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/share/modes/
cp modes/*.ini $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/share/modes/

tar -zpxvf %SOURCE11 -C $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/

# for now we remove libgstvideoparsersbad.so
rm -rf $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/lib/gstreamer-1.0/libgstvideoparsersbad.so

cp /usr/lib/libsndfile.so.1 $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/lib/
cp /usr/lib/libjpeg.so.62 $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/lib/
cp /usr/lib/libbz2.so.1 $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/lib/
cp /usr/lib/libtheoraenc.so.1 $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/lib/
cp /usr/lib/libtheoradec.so.1 $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/lib/
cp /usr/lib/libogg.so.0 $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/lib/
cp /usr/lib/libvorbisenc.so.2 $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/lib/
cp /usr/lib/libvorbis.so.0 $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/lib/
#cp /usr/lib/libsoup-2.4.so.1 $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/lib/
cp /usr/lib/libspeex.so.1 $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/lib/
cp /usr/lib/libFLAC.so.8 $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/lib/
cp /usr/lib/libquillmetadata-qt5.so.1 $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/lib/
cp /usr/lib/libquillimagefilter-qt5.so.1 $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/lib/
cp /usr/lib/libresourceqt5.so.1 $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/lib/
cp /usr/lib/libdbus-qeventloop-qt5.so.1 $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/lib/
cp /usr/lib/libresource.so.0 $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/lib/
cp -a /usr/lib/gstreamer-1.0/ $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/lib/
cp -a /usr/lib/libgst*.so.* $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/lib/
mkdir -p $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/libexec/
cp -a /usr/libexec/gstreamer-1.0/ $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/libexec/
cp -a /usr/lib/quill-utils/ $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/lib/
mkdir -p $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/share/
cp -a /usr/share/avconv/ $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/share/
cp -a /usr/share/gstreamer-1.0/ $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/share/
cp /usr/lib/libswscale.so.* $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/lib/
cp /usr/lib/libavresample.so.* $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/lib/
cp /usr/lib/libavutil.so.* $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/lib/
cp /usr/lib/libavformat.so.* $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/lib/
cp /usr/lib/libavdevice.so.* $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/lib/
cp /usr/lib/libavfilter.so.* $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/lib/
cp /usr/lib/libavcodec.so.* $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/lib/
cp /usr/lib/libopus.so.* $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/lib/
cp /usr/lib/libvo-aacenc.so.* $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/lib/
cp /usr/lib/liborc-0.4.so.* $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/lib/
cp /usr/lib/libffmpegthumbnailer.so.* $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/lib/
cp /usr/lib/libquill-qt5.so.* $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/lib/
mkdir -p $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/bin/
cp /usr/bin/gst-inspect-1.0 $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/bin/
cp /usr/bin/gst-launch-1.0 $RPM_BUILD_ROOT/usr/share/harbour-cameraplus/bin/

%files
%defattr(-,root,root,-)
%{_bindir}/harbour-cameraplus
%{_datadir}/harbour-cameraplus/lib/libqtcamera.so.1
%{_datadir}/harbour-cameraplus/share/cameraplus/*
%{_datadir}/harbour-cameraplus/share/qtcamera/*
%{_datadir}/harbour-cameraplus/share/sounds/*
%{_datadir}/harbour-cameraplus/share/modes/*
%{_datadir}/harbour-cameraplus/lib/qt5/qml/QtCamera/*
%{_datadir}/applications/harbour-cameraplus.desktop
%{_datadir}/icons/hicolor/86x86/apps/harbour-cameraplus.png
# dependencies
%{_datadir}/harbour-cameraplus/bin/*
%{_datadir}/harbour-cameraplus/share/*
%{_datadir}/harbour-cameraplus/lib/*
%{_datadir}/harbour-cameraplus/libexec/*
%{_datadir}/harbour-cameraplus/etc/*
