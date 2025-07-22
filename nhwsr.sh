#!/bin/bash
INSTALL_DIR="$HOME/neuralnexuslab/nethacker/module/nhwsr"
BIN_PATH="$INSTALL_DIR/nhwsr"
PY_PATH="$INSTALL_DIR/nhwsr.py"
echo "[*] Installing NhWsr to $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR"
cat > "$PY_PATH" << 'EOF'
#!/usr/bin/env python3
import sys
import requests
from bs4 import BeautifulSoup
echo "[*] NhWsr version preparing..."
VERSION = "nhwsr version 1.0.1"
echo "[+] NhWsr version write successful..."
def fetch_tags(url):
    try:
        html = requests.get(url).text
        soup = BeautifulSoup(html, 'html.parser')
        tags = [tag.name for tag in soup.find_all()]
        unique_tags = sorted(set(tags))
        print('\n'.join(unique_tags))
    except Exception as e:
        print(f"[ERR] {e}")

def fetch_raw(url):
    try:
        html = requests.get(url).text
        print(html)
    except Exception as e:
        print(f"[ERR] {e}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: nhwsr [-t|--tag|-r|--raw|-v] URL")
        sys.exit(1)

    arg = sys.argv[1]
    if arg in ("-v", "--version"):
        print(VERSION)
    elif arg in ("-t", "--tag") and len(sys.argv) > 2:
        fetch_tags(sys.argv[2])
    elif arg in ("-r", "--raw") and len(sys.argv) > 2:
        fetch_raw(sys.argv[2])
    else:
        print("Invalid usage. Try nhwsr -t <url> or -r <url>")
EOF
echo "[+] NhWsr python file prepare successful..."
chmod +x "$PY_PATH"
echo "[*] NhWsr python file writing..."
cat > "$BIN_PATH" << EOF
#!/bin/bash
python3 "$PY_PATH" "\$@"
EOF
echo "[+] NhWsr python file write successful..."
chmod +x "$BIN_PATH"
echo "[*] Writing path..."
export PATH="$INSTALL_DIR:$PATH"
SHELL_RC=""
if [ -n "$BASH_VERSION" ]; then
  SHELL_RC="$HOME/.bashrc"
elif [ -n "$ZSH_VERSION" ]; then
  SHELL_RC="$HOME/.zshrc"
else
  SHELL_RC="$HOME/.profile"
fi
if ! grep -q "$INSTALL_DIR" "$SHELL_RC"; then
  echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$SHELL_RC"
  echo "[*] Added $INSTALL_DIR to PATH in $SHELL_RC"
fi
echo "[+] NhWsr install successful"
echo "[*] Command 'nhwsr' is working"
