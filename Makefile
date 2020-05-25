VERSION=31
BASE_KS=algtest-live-base.ks
GNOME_KS=algtest-live-workstation.ks
OUT_DIR=build

COMMON_FLAGS=--no-virt --resultdir $(OUT_DIR) --project Fedora-algtest-Live --volid Fedora-algtest-$(VERSION) --releasever $(VERSION) --macboot --lorax-templates templates --make-iso

%.ks.flat: %.ks
	ksflatten --config $< -o $@ --version F$(VERSION)

iso: clean $(BASE_KS).flat
	livemedia-creator $(COMMON_FLAGS) --ks $(BASE_KS).flat --iso-name Fedora-algtest-$(VERSION)-x86_64.iso

gnome_iso: clean $(BASE_KS) $(GNOME_KS).flat
	livemedia-creator $(COMMON_FLAGS) --ks $(GNOME_KS).flat --iso-name Fedora-algtest-$(VERSION)-x86_64.iso 

img: build/images/boot.iso
	./build_img.sh build/images/boot.iso $(VERSION)

clean:
	rm -rf $(OUT_DIR) /var/run/anaconda.pid anaconda/ *.flat
