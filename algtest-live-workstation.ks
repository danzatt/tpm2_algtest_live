# remove similar part command from /usr/share/spin-kickstarts/fedora-workstation-common.ks
part / --size 6656 --fstype ext4
# Maintained by the Fedora Workstation WG:
# http://fedoraproject.org/wiki/Workstation
# mailto:desktop@lists.fedoraproject.org

%include algtest-live-base.ks
%include /usr/share/spin-kickstarts/fedora-workstation-common.ks
#
# Disable this for now as packagekit is causing compose failures
# by leaving a gpg-agent around holding /dev/null open.
#
#include snippets/packagekit-cached-metadata.ks


%packages
-@multimedia
-@printing

-gnome-software
-fedora-workstation-backgrounds
-gnome-user-docs
-speech-dispatcher
-google-noto-sans-cjk-ttc-fonts
-sane-backends-drivers-scanners
-sane-backends-drivers-cameras
-gcc
-gnome-font-viewer
-gnome-disk-utility
-gnome-themes-extra
-gnome-video-effects
-gnome-remote-desktop
-gnome-initial-setup
-gnome-system-monitor
-gnome-tour
-gnome-user-share
-cpp
-cheese
-orca

-@libreoffice
-libreoffice-filters
-libreoffice-draw
-libreoffice-opensymbol-fonts
-libreoffice-pdfimport
-libreoffice-ure-common
-libreoffice-x11
-libreoffice-pyuno
-libreoffice-graphicfilter
-libreoffice-math
-libreoffice-gtk3
-libreoffice-impress
-libreoffice-xsltfilter
-libreoffice-data
-libreoffice-ure
-libreoffice-writer
-libreoffice-help-en
-libreoffice-calc
-libreoffice-core
-unoconv

-gnome-boxes
-gnome-weather
-gnome-maps
-gnome-contacts
-gnome-calendar
-gnome-getting-started-docs
-gnome-calculator
-gnome-photos
-openblas-serial

-rhythmbox
-geolite2-city

%end

%post

cat >> /etc/rc.d/init.d/livesys << EOF

systemctl disable bluetooth.service
systemctl disable bluetooth.service

# disable gnome-software automatically downloading updates
cat >> /usr/share/glib-2.0/schemas/org.gnome.software.gschema.override << FOE
[org.gnome.software]
download-updates=false


[org/gnome/settings-daemon/plugins/power]
# Do not autosuspend
sleep-inactive-ac-type='nothing'
sleep-inactive-battery-type='nothing'

FOE

# don't autostart gnome-software session service
rm -f /etc/xdg/autostart/gnome-software-service.desktop

# disable the gnome-software shell search provider
cat >> /usr/share/gnome-shell/search-providers/org.gnome.Software-search-provider.ini << FOE
DefaultDisabled=true
FOE

# don't run gnome-initial-setup
mkdir ~liveuser/.config
echo "yes" >> ~liveuser/.config/gnome-initial-setup-done

# suppress anaconda spokes redundant with gnome-initial-setup
cat >> /etc/sysconfig/anaconda << FOE
[NetworkSpoke]
visited=1

[PasswordSpoke]
visited=1

[UserSpoke]
visited=1
FOE

cat >> /usr/share/applications/tpm2-algtest-ui.desktop << FOE
[Desktop Entry]
Name=TPM 2.0 AlgTest
Comment=Benchamrk TPM 2.0 and collect its properties
TryExec=tpm2-algtest-ui
Exec=tpm2-algtest-ui
Type=Application
Categories=GNOME;GTK;Utility;System;
StartupNotify=true
Keywords=benchmark;tpm;algtest;
Icon=/usr/share/icons/hicolor/scalable/apps/tpm2-algtest.svg
FOE

mkdir -p ~liveuser/.config/autostart
cp /usr/share/applications/tpm2-algtest-ui.desktop ~liveuser/.config/autostart/

cat > ~liveuser/.config/autostart/disable-screensaver.desktop << FOE
[Desktop Entry]
Type=Application
Name=DisableScreensaver
Comment=Disable screensaver
Exec=gsettings set org.gnome.desktop.session idle-delay 0
Terminal=false
NoDisplay=true
X-GNOME-Autostart-enabled=true
FOE

cat > ~liveuser/.config/autostart/disable-battery-suspend.desktop << FOE
[Desktop Entry]
Type=Application
Name=DisableBatterySuspend
Comment=DisableBatterySuspend
Exec=gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing'
Terminal=false
NoDisplay=true
X-GNOME-Autostart-enabled=true
FOE

cat > ~liveuser/.config/autostart/disable-ac-suspend.desktop << FOE
[Desktop Entry]
Type=Application
Name=DisableACSuspend
Comment=DisableACSuspend
Exec=gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
Terminal=false
NoDisplay=true
X-GNOME-Autostart-enabled=true
FOE

cat >> /usr/share/glib-2.0/schemas/org.gnome.shell.gschema.override << FOE
[org.gnome.shell]
favorite-apps=['firefox.desktop', 'tpm2-algtest-ui.desktop', 'org.gnome.Terminal.desktop', 'org.gnome.Nautilus.desktop']
welcome-dialog-last-shown-version='4294967295'
FOE

cat >> /usr/share/glib-2.0/schemas/org.gnome.settings-daemon.plugins.power.gschema.override << FOE
[org.gnome.settings-daemon.plugins.power]
sleep-inactive-battery-type 'nothing'
FOE

cat >> /usr/share/glib-2.0/schemas/org.gnome.desktop.peripherals.gschema.override << FOE
[org.gnome.desktop.peripherals.touchpad]
tap-to-click=true
FOE

# rebuild schema cache with any overrides we installed
glib-compile-schemas /usr/share/glib-2.0/schemas

# set up auto-login
cat > /etc/gdm/custom.conf << FOE
[daemon]
AutomaticLoginEnable=True
AutomaticLogin=liveuser
FOE

# Turn off PackageKit-command-not-found while uninstalled
if [ -f /etc/PackageKit/CommandNotFound.conf ]; then
  sed -i -e 's/^SoftwareSourceSearch=true/SoftwareSourceSearch=false/' /etc/PackageKit/CommandNotFound.conf
fi

# make sure to set the right permissions and selinux contexts
chown -R liveuser:liveuser /home/liveuser/
restorecon -R /home/liveuser/
chown liveuser:liveuser /dev/tpm0

EOF

%end
