#!/usr/bin/env bash

# make sure the submodules are cloned recursively
git submodule update --init --recursive

FLAVORS=(
	"mocha"
	"macchiato"
	"frappe"
	"latte"
)

self_dir=$(pwd)
patch_dir=$(pwd)/patches

cd gtk || exit
for FLAVOR in "${FLAVORS[@]}"; do
	python3 ./install.py "$FLAVOR" --dest "${self_dir}/dist/gtk"
done

cd "$self_dir" || exit

echo "==> Applying my awful patches"
for dir in dist/gtk/*; do
	# skip anything that's not Dark/Light (they just contain xfwm resources)
	if ! [[ $dir =~ (Dark|Light)$ ]]; then
		continue
	fi

	cd "$dir" || exit
	echo "==> Patching $dir"
	# "-F 5" is just here for this example, because I'm lazy (it fuzzy matches more stuff)
	patch -p0 -l -r - -F 5 <"$patch_dir/zero_radius.patch"
	cd "$self_dir" || exit
done
