#!/bin/zsh
# Veillon — installation ou mise à jour, sans compte GitHub et sans outil à installer :
#   curl -fsSL https://raw.githubusercontent.com/LucasHRCHatReply/veillon-releases/main/installer.sh | zsh
# Le script télécharge la dernière version publiée, vérifie l'empreinte SHA-256, l'identifiant et l'équipe de signature
# (codesign --verify --deep --strict), puis lance install.sh du zip : Veillon.app va dans /Applications, la quarantaine est
# levée sur Veillon.app seulement, l'app est lancée. Une instance de Veillon qui tourne est quittée d'abord. L'historique et les réglages (~/Library/Application Support/Veillon) ne sont jamais touchés.
# Aucun mot de passe administrateur. Le script se lit en entier avant de le lancer.
set -uo pipefail
ZIP_URL="${VEILLON_ZIP_URL:-https://github.com/LucasHRCHatReply/veillon-releases/releases/latest/download/Veillon.zip}"
TEAM="JT9FY7PP7K"
BUNDLE_ID="fr.veillon.app"
fail() { echo "\nÉCHEC : $*" >&2; exit 1; }
step() { echo "\n[$1/3] $2"; }

step 1 "Ce Mac convient-il ?"
macos=$(sw_vers -productVersion)
(( ${macos%%.*} >= 26 )) || fail "Veillon demande macOS 26 ou plus (ce Mac : $macos)."
[[ "$(sysctl -n hw.optional.arm64 2>/dev/null)" == "1" ]] || fail "Veillon ne tourne que sur les Mac à puce Apple (M1 ou plus récent)."
echo "  macOS $macos : ok"

step 2 "Téléchargement et contrôle"
WORK=$(mktemp -d "${TMPDIR:-/tmp}/veillon-install.XXXXXX") || fail "dossier temporaire impossible"
trap 'rm -rf "$WORK"' EXIT
curl -fL --silent --show-error -o "$WORK/Veillon.zip" "$ZIP_URL" || fail "téléchargement impossible (réseau coupé, ou aucune version publiée) : $ZIP_URL"
if curl -fL --silent -o "$WORK/Veillon.zip.sha256" "$ZIP_URL.sha256" 2>/dev/null && [[ -s "$WORK/Veillon.zip.sha256" ]]; then
  want=$(awk '{print $1; exit}' "$WORK/Veillon.zip.sha256"); have=$(shasum -a 256 "$WORK/Veillon.zip" | awk '{print $1}')
  [[ "$want" == "$have" ]] || fail "l'empreinte SHA-256 du zip ne correspond pas à celle publiée : installation refusée."
  echo "  empreinte SHA-256 : conforme"
else
  fail "l'empreinte SHA-256 publiée est introuvable : installation refusée."
fi
ditto -x -k "$WORK/Veillon.zip" "$WORK/contenu" || fail "le zip est illisible"
DIR=$(ls -d "$WORK"/contenu/Veillon-* 2>/dev/null | head -1)
[[ -n "$DIR" && -d "$DIR/Veillon.app" && -f "$DIR/install.sh" ]] || fail "le zip n'a pas le contenu attendu (Veillon-X.Y.Z/Veillon.app et install.sh)."
[[ "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$DIR/Veillon.app/Contents/Info.plist" 2>/dev/null)" == "$BUNDLE_ID" ]] || fail "identifiant de l'app inattendu : installation refusée."
got=$(codesign -dv "$DIR/Veillon.app" 2>&1 | sed -n 's/^TeamIdentifier=//p')
[[ "$got" == "$TEAM" ]] || fail "l'app n'est pas signée par l'équipe attendue ($TEAM) mais par « ${got:-aucune} » : installation refusée."
codesign --verify --deep --strict "$DIR/Veillon.app" 2>/dev/null || fail "la signature de Veillon.app est invalide : installation refusée."
NEW=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$DIR/Veillon.app/Contents/Info.plist")
echo "  Veillon $NEW, signature valide, équipe $TEAM : ok  ($(du -h "$WORK/Veillon.zip" | cut -f1))"

step 3 "Installation"
zsh "$DIR/install.sh" "$DIR/Veillon.app" || fail "l'installation a échoué (voir le message ci-dessus)."
echo "\nTerminé."
