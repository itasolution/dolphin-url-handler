#!/usr/bin/env bash
set -euo pipefail

BIN="$HOME/.local/bin/open-in-dolphin.sh"
DESKTOP="$HOME/.local/share/applications/dolphin-handler.desktop"

rm -f "$BIN" "$DESKTOP"

# Non proviamo a ripristinare automaticamente un default precedente:
# l'utente può impostarlo manualmente se necessario.
echo "Rimosso: $BIN"
echo "Rimosso: $DESKTOP"
echo "Nota: se vuoi cambiare handler, usa: xdg-mime default <qualcosa.desktop> x-scheme-handler/dolphin"