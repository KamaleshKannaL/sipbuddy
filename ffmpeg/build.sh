#!/usr/bin/env bash
# Builds the small ffmpeg that SipBuddy embeds (see ffmpeg.go) to split the
# character video into frames. Users' systems often can't decode H.264/HEVC
# themselves (Linux without gstreamer1.0-libav, Windows N editions), so the app
# carries its own decoder. LGPL build (no --enable-gpl): decoders, the scale/fps
# filters and a JPEG encoder only.
#
#   tools/ffmpeg/build.sh linux   <ffmpeg-source-dir>   -> tools/ffmpeg/ffmpeg-linux-amd64.gz
#   tools/ffmpeg/build.sh windows <ffmpeg-source-dir>   -> tools/ffmpeg/ffmpeg-windows-amd64.exe.gz
#
# Source: https://ffmpeg.org/releases/ffmpeg-7.1.1.tar.xz
# Windows needs a MinGW-w64 cross compiler (x86_64-w64-mingw32-gcc), or zig 0.13: ZIG=/path/to/zig.
set -euo pipefail

target=${1:?linux|windows}
src=$(cd "${2:?ffmpeg source dir}" && pwd)
here=$(cd "$(dirname "$0")" && pwd)
build=$(mktemp -d)
trap 'rm -rf "$build"' EXIT

common=(
    --disable-everything --disable-doc --disable-debug
    --disable-ffplay --disable-ffprobe --disable-network
    # no nasm needed; inline asm must go too: swscale's inline MMX without the
    # external asm scales into garbage stripes
    --disable-x86asm --disable-inline-asm
    --disable-avdevice --disable-swresample
    --enable-small --enable-static --disable-shared
    --enable-protocol=file
    --enable-demuxer=mov,matroska,avi
    --enable-parser=h264,hevc,vp8,vp9,mpeg4video,mjpeg
    --enable-bsf=vp9_superframe_split
    --enable-decoder=h264,hevc,vp8,vp9,mpeg4,prores,mjpeg,qtrle
    --enable-filter=fps,scale,format,null
    --enable-encoder=mjpeg
    --enable-muxer=image2
)

cd "$build"
case "$target" in
linux)
    "$src/configure" "${common[@]}" --disable-autodetect --extra-ldflags=-static --pkg-config-flags=--static
    out=ffmpeg-linux-amd64 bin=ffmpeg
    ;;
windows)
    if [ -n "${ZIG:-}" ]; then
        # no MinGW installed: wrap zig (ZIG=/path/to/zig) as the mingw toolchain
        mkdir -p "$build/bin"
        # zig's linker rejects GNU ld's --pic-executable, which configure adds
        cat >"$build/bin/x86_64-w64-mingw32-gcc" <<EOF
#!/bin/sh
for a; do shift; case \$a in -Wl,--pic-executable,*) set -- "\$@" "-Wl,\${a#-Wl,--pic-executable,}" ;; *) set -- "\$@" "\$a" ;; esac; done
exec "$ZIG" cc -target x86_64-windows-gnu "\$@"
EOF
        printf '#!/bin/sh\nexec "%s" ar "$@"\n' "$ZIG" >"$build/bin/x86_64-w64-mingw32-ar"
        printf '#!/bin/sh\nexec "%s" ranlib "$@"\n' "$ZIG" >"$build/bin/x86_64-w64-mingw32-ranlib"
        printf '#!/bin/sh\nexec nm "$@"\n' >"$build/bin/x86_64-w64-mingw32-nm"
        printf '#!/bin/sh\nexec strip "$@"\n' >"$build/bin/x86_64-w64-mingw32-strip"
        chmod +x "$build"/bin/*
        export PATH="$build/bin:$PATH"
    fi
    "$src/configure" "${common[@]}" --arch=x86_64 --target-os=mingw32 --cross-prefix=x86_64-w64-mingw32- \
        --extra-ldflags=-static
    out=ffmpeg-windows-amd64.exe bin=ffmpeg.exe
    ;;
*)
    echo "unknown target $target" >&2
    exit 1
    ;;
esac
make -j"$(nproc)" "$bin"
strip "$bin"
gzip -9c "$bin" >"$here/$out.gz"
ls -l "$bin" "$here/$out.gz"
