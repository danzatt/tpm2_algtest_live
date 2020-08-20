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

part / --size 6656

%packages
-@multimedia
-@printing

-@libreoffice
-libreoffice-filters
-libreoffice-draw
-libreoffice-langpack-en
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


# disable gnome-software automatically downloading updates
cat >> /usr/share/glib-2.0/schemas/org.gnome.software.gschema.override << FOE
[org.gnome.software]
download-updates=false
FOE

# don't autostart gnome-software session service
rm -f /etc/xdg/autostart/gnome-software-service.desktop

# disable the gnome-software shell search provider
cat >> /usr/share/gnome-shell/search-providers/org.gnome.Software-search-provider.ini << FOE
DefaultDisabled=true
FOE

# don't run gnome-initial-setup
mkdir ~liveuser/.config
touch ~liveuser/.config/gnome-initial-setup-done

# suppress anaconda spokes redundant with gnome-initial-setup
cat >> /etc/sysconfig/anaconda << FOE
[NetworkSpoke]
visited=1

[PasswordSpoke]
visited=1

[UserSpoke]
visited=1
FOE

if [ ! -f /usr/share/applications/tpm2-algtest-ui.desktop ]; then
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
FOE
fi

mkdir -p ~liveuser/.config/autostart
cp /usr/share/applications/tpm2-algtest-ui.desktop ~liveuser/.config/autostart/

cat >> /usr/share/glib-2.0/schemas/org.gnome.shell.gschema.override << FOE
[org.gnome.shell]
favorite-apps=['firefox.desktop', 'tpm2-algtest-ui.desktop', 'org.gnome.Terminal.desktop', 'org.gnome.Nautilus.desktop']
FOE

# rebuild schema cache with any overrides we installed
glib-compile-schemas /usr/share/glib-2.0/schemas

# set up auto-login
cat > /etc/gdm/custom.conf << FOE
[daemon]
AutomaticLoginEnable=True
AutomaticLogin=liveuser
FOE

su liveuser -c "gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true"

# Turn off PackageKit-command-not-found while uninstalled
if [ -f /etc/PackageKit/CommandNotFound.conf ]; then
  sed -i -e 's/^SoftwareSourceSearch=true/SoftwareSourceSearch=false/' /etc/PackageKit/CommandNotFound.conf
fi

# make sure to set the right permissions and selinux contexts
chown -R liveuser:liveuser /home/liveuser/
restorecon -R /home/liveuser/
chown liveuser /dev/tpm0

EOF

%end
