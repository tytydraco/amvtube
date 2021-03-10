#!/usr/bin/env bash
shopt -s globstar
cd "$(dirname "$0")"

# ---
export WIDTH="320"
export HEIGHT="-1"
export FPS="30"
# ---
INPUT="input"
LOCK=".lock"
LOG="log.txt"

while [[ -f "$LOCK" ]]
do
    echo "Waiting for lock to release [at: $LOCK]..."
    sleep 1
done

touch "$LOCK"
echo "$(date)" >> "$LOG"

_amvhub_convert() {
    ffmpeg \
        -i "$1" \
        -f amv \
        -vf "scale=$WIDTH:$HEIGHT" \
        -strict -1 \
        -r "$FPS" \
        -ac 1 \
        -ar 22050 \
        -block_size 735 \
        -n \
        -qmin 3 \
        -qmax 3 \
        "${1%.*}.amv" && rm "$1"
}

export -f _amvhub_convert
find "$INPUT" -type f -not -name "*.amv" -not -name ".gitkeep" -exec bash -c '_amvhub_convert "{}" &' \;

wait

rm -f "$LOCK"

echo ""
echo -e "\033[0;31mFinished amvhub.\033[0m"
echo ""

exit 0
