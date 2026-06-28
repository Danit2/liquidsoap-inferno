#!/bin/sh
set -eu

: "${STREAM_URL:?STREAM_URL fehlt}"
: "${DANTE_NAME:?DANTE_NAME fehlt}"
: "${BIND_IP:?BIND_IP fehlt}"
: "${PROCESS_ID:?PROCESS_ID fehlt}"
: "${ALT_PORT:?ALT_PORT fehlt}"

CLOCK_PATH="${CLOCK_PATH:-/shared/usrvclock}"
TMPDIR="${TMPDIR:-/shared/tmp_${PROCESS_ID}}"
TX_CHANNELS="${TX_CHANNELS:-2}"
RX_CHANNELS="${RX_CHANNELS:-0}"
SAMPLE_RATE="${SAMPLE_RATE:-48000}"

mkdir -p "$TMPDIR"
rm -f "$TMPDIR"/usrvclock-client.*

cat > /etc/asound.conf <<EOF
pcm.inferno_raw {
    type inferno
    rate $SAMPLE_RATE
    NAME "$DANTE_NAME"
    SAMPLE_RATE "$SAMPLE_RATE"
    TX_CHANNELS "$TX_CHANNELS"
    RX_CHANNELS "$RX_CHANNELS"
    BIND_IP "$BIND_IP"
    PROCESS_ID "$PROCESS_ID"
    ALT_PORT "$ALT_PORT"
    CLOCK_PATH "$CLOCK_PATH"
    hint {
        show on
        description "Inferno Dante RAW"
    }
}

pcm.inferno {
    type plug
    slave.pcm "inferno_raw"
    hint {
        show on
        description "Inferno Dante Plug"
    }
}
EOF

until [ -S "$CLOCK_PATH" ]; do
    echo "warte auf $CLOCK_PATH..."
    sleep 1
done

echo "Clock gefunden, warte auf PTP-Sync..."
sleep 20

echo "ALSA-Geräte:"
aplay -L | grep -A2 -i inferno || true

echo "Starte Liquidsoap: $STREAM_URL -> $DANTE_NAME"
exec liquidsoap /stream.liq
