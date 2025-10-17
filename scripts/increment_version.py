#!/usr/bin/env python3
"""
Script per incrementare automaticamente la versione in pubspec.yaml
Incrementa il versionCode (+1) mantenendo la versionName uguale
"""

import re
import sys
import os

def increment_version():
    """Incrementa il versionCode nel file pubspec.yaml"""
    
    # Percorso del file pubspec.yaml
    pubspec_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'pubspec.yaml')
    
    if not os.path.exists(pubspec_path):
        print(f" File pubspec.yaml non trovato: {pubspec_path}")
        sys.exit(1)
    
    # Leggi il contenuto del file
    with open(pubspec_path, 'r', encoding='utf-8') as file:
        content = file.read()
    
    # Pattern per trovare la versione (es: version: 1.0.0+2)
    version_pattern = r'version:\s*(\d+\.\d+\.\d+)\+(\d+)'
    match = re.search(version_pattern, content)
    
    if not match:
        print(" Formato versione non trovato nel pubspec.yaml")
        print("   Formato atteso: version: X.Y.Z+N")
        sys.exit(1)
    
    version_name = match.group(1)  # es: 1.0.0
    version_code = int(match.group(2))  # es: 2
    
    # Incrementa il versionCode
    new_version_code = version_code + 1
    new_version = f"version: {version_name}+{new_version_code}"
    
    # Sostituisci la versione nel contenuto
    new_content = re.sub(version_pattern, new_version, content)
    
    # Scrivi il file aggiornato
    with open(pubspec_path, 'w', encoding='utf-8') as file:
        file.write(new_content)
    
    print(f" Versione aggiornata: {version_name}+{version_code} → {version_name}+{new_version_code}")
    print(f" File aggiornato: {pubspec_path}")
    
    return f"{version_name}+{new_version_code}"

if __name__ == "__main__":
    try:
        new_version = increment_version()
        print(f" Nuova versione: {new_version}")
    except Exception as e:
        print(f" Errore: {e}")
        sys.exit(1)