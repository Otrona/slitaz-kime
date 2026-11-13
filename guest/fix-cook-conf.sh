#!/bin/sh
# Fix /etc/slitaz/cook.conf on SliTaz 5.1 x86_64: it ships with i486 values,
# so every package that compiles C code fails with
#   "CPU you selected does not support x86-64 instruction set".
# Run as root after installing cookutils and after every `cook setup`.
C=/etc/slitaz/cook.conf
[ -f $C.bak ] || cp $C $C.bak
sed -i \
	-e 's/^ARCH="i486"/ARCH="x86_64"/' \
	-e 's/i486-slitaz-linux/x86_64-slitaz-linux/g' \
	-e 's/-march=i486/-march=x86-64 -mtune=generic/g' \
	$C
n=$(grep -c i486 $C)
[ "$n" = 0 ] && echo "cook.conf: OK (x86_64)" || { echo "cook.conf: $n i486 line(s) left:" >&2; grep -n i486 $C >&2; exit 1; }
