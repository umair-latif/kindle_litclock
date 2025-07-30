#!/bin/sh

# Urdu Literary Clock with fbink + log + offset + rotated time text
lipc-set-prop com.lab126.powerd preventScreenSaver 1

EXTDIR=$(dirname "$0")
IMG_DIR="$EXTDIR/images"
FBINK="/mnt/us/extensions/bin/fbink"
LOG="$EXTDIR/clock.log"

# Read screen width and height via fbink; fall back to 800x600
get_screen_size() {
    local info size
    info=$("$FBINK" -i 2>/dev/null)
    size=$(echo "$info" | grep -m1 -o '[0-9]\+x[0-9]\+')
    WIDTH=$(echo "$size" | cut -d'x' -f1)
    HEIGHT=$(echo "$size" | cut -d'x' -f2)
    if [ -z "$WIDTH" ] || [ -z "$HEIGHT" ]; then
        WIDTH=800
        HEIGHT=600
    fi
}

# Determine screen size once at startup
get_screen_size

# Calculate placement of the time text
TIME_X=$((WIDTH - 40))
TIME_Y=$((HEIGHT / 2))
TIME_FONT=40

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
    $FBINK -q -m -y "$TIME_Y" -x "$TIME_X" -S -r cw -s "$TIME_FONT" "$TIME"

    sleep 60
done
