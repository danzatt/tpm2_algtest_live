The image is currently based on Fedora 31, so it is recommended to be built on Fedora 31 host. Current pre-built version is available at https://www.fi.muni.cz/~xzatovic/algtest-usb-disk-v2.img


# Dependencies

`dnf install lorax-lmc-novirt pykickstart fedora-kickstarts livecd-iso-to-mediums gdisk`

# Building

In `/usr/share/spin-kickstarts/fedora-repo.ks` uncomment `fedora-repo-not-rawhide.ks` and comment out `fedora-repo-rawhide.ks`.
Run `sudo make gnome_iso img`.

Other options are:   
`sudo make <gnome_iso or iso (for text mode ISO without graphical environment)>`, `img` target also converts the iso to partitioned disk image with a persistant partition for results.
