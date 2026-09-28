#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  start_vnc.sh  —  Compile and launch the Java Swing app on Replit VNC
#
#  The project entry point is the root-level Main.java.  The launcher must
#  compile that file and run from the project directory so bg.jpg, signin.jpg,
#  and code_hills.db are resolved exactly as the application expects.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CP="$SCRIPT_DIR/sqlite-jdbc.jar:$SCRIPT_DIR/slf4j-api.jar:$SCRIPT_DIR/slf4j-simple.jar"
FONT_DIR="/usr/share/fonts/truetype/dejavu"
JAVA_HOME="/nix/store/k95pqfzyvrna93hc9a4cg5csl7l4fh0d-openjdk-21.0.7+6"
JAVA_BIN="$JAVA_HOME/bin/java"
JAVAC_BIN="$JAVA_HOME/bin/javac"
SRC="$SCRIPT_DIR/Main.java"

echo "[vnc] DISPLAY=${DISPLAY:-not set}"
echo "[vnc] Source: $SRC"
echo "[vnc] Java: $JAVA_BIN"

# ── 1. Build font cache for the DejaVu directory only ────────────────────────
echo "[fonts] Running fc-cache on $FONT_DIR …"
fc-cache -f "$FONT_DIR" && echo "[fonts] fc-cache OK" || echo "[fonts] fc-cache warning (continuing)"

# ── 2. Set fontconfig environment ────────────────────────────────────────────
export FONTCONFIG_FILE=/etc/fonts/fonts.conf
export FONTCONFIG_PATH=/etc/fonts

# ── 3. Compile the actual application entry point ─────────────────────────────
cd "$SCRIPT_DIR"
if [[ ! -f "$SCRIPT_DIR/Main.class" ]] || \
   [[ "$SRC" -nt "$SCRIPT_DIR/Main.class" ]]; then
    echo "[java] Compiling Main.java …"
    "$JAVAC_BIN" -cp "$CP" "$SRC"
    echo "[java] Compile OK"
fi

# ── 4. Launch with font + rendering flags ─────────────────────────────────────
echo "[java] Launching Swing GUI …"
exec "$JAVA_BIN" \
    -Djava.awt.headless=false \
    -Dsun.java2d.xrender=false \
    -Dsun.java2d.pmoffscreen=false \
    -Dsun.java2d.fontpath="$FONT_DIR" \
    -cp "$SCRIPT_DIR:$CP" \
    Main
