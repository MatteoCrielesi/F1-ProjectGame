#!/bin/bash
# Script per incrementare automaticamente la versione in pubspec.yaml
# Incrementa il versionCode (+1) mantenendo la versionName uguale

set -e

# Percorso del file pubspec.yaml
PUBSPEC_PATH="$(dirname "$(dirname "$0")")/pubspec.yaml"

if [ ! -f "$PUBSPEC_PATH" ]; then
    echo "❌ File pubspec.yaml non trovato: $PUBSPEC_PATH"
    exit 1
fi

# Estrai la versione corrente
CURRENT_VERSION=$(grep "^version:" "$PUBSPEC_PATH" | sed 's/version: //')

if [ -z "$CURRENT_VERSION" ]; then
    echo "❌ Versione non trovata nel pubspec.yaml"
    echo "   Formato atteso: version: X.Y.Z+N"
    exit 1
fi

# Separa versionName e versionCode
VERSION_NAME=$(echo "$CURRENT_VERSION" | cut -d'+' -f1)
VERSION_CODE=$(echo "$CURRENT_VERSION" | cut -d'+' -f2)

if [ -z "$VERSION_CODE" ]; then
    echo "❌ Formato versione non valido: $CURRENT_VERSION"
    echo "   Formato atteso: X.Y.Z+N"
    exit 1
fi

# Incrementa il versionCode
NEW_VERSION_CODE=$((VERSION_CODE + 1))
NEW_VERSION="${VERSION_NAME}+${NEW_VERSION_CODE}"

# Aggiorna il file pubspec.yaml
sed -i.bak "s/^version: .*/version: $NEW_VERSION/" "$PUBSPEC_PATH"

echo "✅ Versione aggiornata: $CURRENT_VERSION → $NEW_VERSION"
echo "📁 File aggiornato: $PUBSPEC_PATH"
echo "🚀 Nuova versione: $NEW_VERSION"

# Rimuovi il file di backup
rm -f "${PUBSPEC_PATH}.bak"