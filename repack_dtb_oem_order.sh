#!/bin/bash
set -euo pipefail

MERGED="$1"
OUT="$2"
PREBUILT="$3"
FDTGET="$4"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

python3 - "$PREBUILT" "$tmp" <<'PYINNER'
from pathlib import Path
import struct
import sys

src = Path(sys.argv[1])
out = Path(sys.argv[2])

data = src.read_bytes()
off = 0
idx = 0

while off < len(data):
    if data[off:off + 4] != b"\xd0\x0d\xfe\xed":
        raise SystemExit(f"invalid FDT magic at offset 0x{off:x}")

    if off + 8 > len(data):
        raise SystemExit("truncated FDT header")

    size = struct.unpack(">I", data[off + 4:off + 8])[0]

    if size <= 0 or off + size > len(data):
        raise SystemExit(f"invalid FDT size {size} at offset 0x{off:x}")

    (out / f"{idx:02d}.dtb").write_bytes(data[off:off + size])

    off += size
    idx += 1

if idx != 14:
    raise SystemExit(f"expected 14 DTBs in prebuilt, found {idx}")
PYINNER

check_compat()
{
    file="$1"
    expected="$2"

    compat="$("$FDTGET" "$file" / compatible 2>/dev/null || true)"

    if [ "$compat" != "$expected" ]; then
        echo "ERROR: $(basename "$file") compatible='$compat', expected='$expected'" >&2
        exit 1
    fi
}

# Stock infiniti.dtb contains six Alor-family DTBs followed by eight
# Canoe-family DTBs. Published Canoe sources reproduce only the latter.
check_compat "$tmp/00.dtb" "qcom,alor"
check_compat "$tmp/01.dtb" "qcom,alor"
check_compat "$tmp/02.dtb" "qcom,alor"
check_compat "$tmp/03.dtb" "qcom,alor"
check_compat "$tmp/04.dtb" "qcom,alor"
check_compat "$tmp/05.dtb" "qcom,alorp"

canoe=(
    "$MERGED/canoe-tp-v2.dtb"
    "$MERGED/canoe-tp.dtb"
    "$MERGED/canoe-v2.dtb"
    "$MERGED/canoe.dtb"
    "$MERGED/canoep-tp-v2.dtb"
    "$MERGED/canoep-tp.dtb"
    "$MERGED/canoep-v2.dtb"
    "$MERGED/canoep.dtb"
)

for f in "${canoe[@]}"; do
    if [ ! -f "$f" ]; then
        echo "ERROR: missing merged DTB: $f" >&2
        exit 1
    fi
done

echo "DTB OEM order:"

for i in 00 01 02 03 04 05; do
    model="$("$FDTGET" "$tmp/$i.dtb" / model 2>/dev/null || true)"
    echo "  stock[$i]: $model"
done

for f in "${canoe[@]}"; do
    model="$("$FDTGET" "$f" / model 2>/dev/null || true)"
    echo "  source: $(basename "$f"): $model"
done

rm -f "$OUT"

cat \
    "$tmp/00.dtb" \
    "$tmp/01.dtb" \
    "$tmp/02.dtb" \
    "$tmp/03.dtb" \
    "$tmp/04.dtb" \
    "$tmp/05.dtb" \
    "${canoe[@]}" \
    > "$OUT"

echo "Created $OUT ($(stat -c '%s' "$OUT") bytes)"
