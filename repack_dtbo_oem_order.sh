#!/bin/bash
set -euo pipefail

MERGED="$1"
OUT="$2"
MKDTBOIMG="$3"
FDTGET="$4"

find_one()
{
    project="$1"
    hw="$2"

    found=""

    for f in "$MERGED"/*.dtbo; do
        p="$("$FDTGET" -t x "$f" / oplus,project-id 2>/dev/null || true)"
        h="$("$FDTGET" -t x "$f" / oplus,hw-id 2>/dev/null || true)"

        if [ "$p" = "$project" ] && [ "$h" = "$hw" ]; then
            if [ -n "$found" ]; then
                echo "ERROR: duplicate DTBO for project=$project hw=$hw" >&2
                exit 1
            fi
            found="$f"
        fi
    done

    if [ -z "$found" ]; then
        echo "ERROR: no DTBO for project=$project hw=$hw" >&2
        exit 1
    fi

    printf '%s\n' "$found"
}

files=(
    "$(find_one 60ff '10')"
    "$(find_one 611f '10')"
    "$(find_one 611f '1')"
    "$(find_one 60ff '1')"
    "$(find_one 611f '8 9 a')"
    "$(find_one 60ff '28 18 21 19 20')"
    "$(find_one 611f '28 18 21 19 20')"
    "$(find_one 60ff '8 9 a')"
)

echo "DTBO OEM order:"
for f in "${files[@]}"; do
    echo "  $(basename "$f")"
done

"$MKDTBOIMG" create \
    "$OUT" \
    --page_size=4096 \
    "${files[@]}"
