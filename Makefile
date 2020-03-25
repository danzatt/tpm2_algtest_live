VERSION=F31

%.ks.flat: %.ks
	ksflatten --config $< -o $@ --version $(VERSION)

iso: fedora-live-algtest.ks.flat
	livemedia-creator --ks fedora-live-algtest.ks.flat --no-virt --resultdir /var/lmc --project Fedora-algtest-Live --make-iso --volid Fedora-algtest-31 --iso-only --iso-name Fedora-algtest-31-x86_64.iso --releasever 31 --macboot --proxy=http://localhost:8080

img: fedora-live-algtest.ks.flat
	livemedia-creator --ks fedora-live-algtest.ks.flat --no-virt --resultdir /var/lmc --project Fedora-algtest-Live --make-disk --volid Fedora-algtest-31 --image-name Fedora-algtest-31-x86_64.img --releasever 31 --macboot --proxy=http://localhost:8080
