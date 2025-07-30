#!/bin/sh

# Urdu Literary Clock with fbink + log + offset + rotated time text
lipc-set-prop com.lab126.powerd preventScreenSaver 1

EXTDIR=$(dirname "$0")
IMG_DIR="$EXTDIR/images"
FBINK="/mnt/us/extensions/bin/fbink"
LOG="$EXTDIR/clock.log"

echo "$(date '+%F %T') [INFO] Clock started" >> "$LOG"

get_image_for_time() {
    local h=$1
    local m=$2

    if [ "$m" -lt 15 ]; then
        QUARTER=0
    elif [ "$m" -lt 30 ]; then
        QUARTER=1
    elif [ "$m" -lt 45 ]; then
        QUARTER=2
    else
        QUARTER=3
    fi

    IMG="$IMG_DIR/quote_${h}_${QUARTER}.png"
    if [ -f "$IMG" ]; then
        echo "$IMG"
        return
    fi

    while [ $QUARTER -gt 0 ]; do
        QUARTER=$((QUARTER - 1))
        IMG="$IMG_DIR/quote_${h}_${QUARTER}.png"
        if [ -f "$IMG" ]; then
            echo "$IMG"
            return
        fi
    done

    echo ""
}

while true; do
    lipc-set-prop com.lab126.powerd preventScreenSaver 1
    RAW_HOUR=$(date +%H)
    MIN=$(date +%M)

    OFFSET=$(cat "$EXTDIR/offset.conf" 2>/dev/null)
    [ -z "$OFFSET" ] && OFFSET=0

    HOUR=$(( (RAW_HOUR + OFFSET + 24) % 24 ))

    IMG=$(get_image_for_time "$HOUR" "$MIN")

    if [ -n "$IMG" ]; then
        echo "$(date '+%F %T') [INFO] Displaying $IMG" >> "$LOG"
        $FBINK -g file="$IMG"
    else
        echo "$(date '+%F %T') [WARN] No image found for $HOUR:$MIN" >> "$LOG"
        $FBINK -q "No image for this time"
    fi

    # Draw rotated time text over image
    TIME=$(printf "%02d:%02d" "$HOUR" "$MIN")
    echo "$(date '+%F %T') [INFO] Displaying time text: $TIME" >> "$LOG"
    $FBINK -q -m -y 20 -x 400 -S -r cw -s 28 "$TIME"

    sleep 60
done
