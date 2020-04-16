# Dependencies

`dnf install lorax-lmc-novirt pykickstart fedora-kickstarts livecd-iso-to-mediums gdisk`
# Building
In `/usr/share/spin-kickstarts/fedora-repo.ks` uncomment `fedora-repo-not-rawhide.ks` and comment out `fedora-repo-rawhide.ks`.
Run `sudo make gnome iso img`.

Other options are:   
`sudo make <gnome_iso or iso (for text-only mode)>`, `img` target also converts the iso to partitioned disk image with a persistant partition for results.
