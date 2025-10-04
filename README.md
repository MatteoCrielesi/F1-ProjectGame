# F1 Project Game

F1 Project Game è un gioco sviluppato in Flutter ispirato al mondo della Formula 1. Il progetto è multipiattaforma (Web, Android, Windows) e punta a offrire un’esperienza arcade accessibile e immediata.

Questo repository pubblico ospita:
- Codice sorgente del gioco
- Workflow GitHub per il deploy su GitHub Pages (versione Web)
- Workflow GitHub per la generazione degli artefatti Android (APK) e Windows (EXE) e pubblicazione su Release

## Modalità Challenge (approfondimento)

La Challenge Mode è l’esperienza principale attualmente approfondita:
- Selezioni una pista dal roster disponibile
- Scegli la scuderia
- Completi 3 giri contro il tempo, con gestione di accelerazione/freno e fisica semplificata
- Alla fine, viene mostrato il tempo del miglior giro e puoi "Riprova" o "Riscendi in pista" per ricominciare subito

Obiettivi della Challenge:
- Migliorare la precisione di guida e la consistenza giro dopo giro
- Fornire feedback immediato sul best lap
- Permettere retry rapidi senza tornare ai menu

Nota: Al momento il README approfondisce esclusivamente la Challenge Mode; ulteriori modalità verranno documentate successivamente.

## Requisiti di sviluppo

- Flutter stable
- Dart SDK
- Per build Android: Android SDK/NDK e JDK
- Per build Windows: Visual Studio con componenti Desktop C++

## Download (APK / EXE)

Ogni volta che si crea un tag `vX.Y.Z` su `main`, i workflow generano:
- APK Android (non firmato, adatto a test): pubblicato come asset nella pagina Release
- EXE/ZIP Windows: pubblicato come asset nella pagina Release

I file sono scaricabili dalla sezione "Releases" del repository.

## Versione Web (GitHub Pages)

Ad ogni push su `main` viene generata la build Web (`build/web`) e pubblicata su GitHub Pages. L’URL del sito è visibile nei log del job "Deploy to GitHub Pages" e nella sezione "Pages" del repository.

## Come pubblicare

1. Imposta il remote verso GitHub e fai push del codice:
   ```
   git init
   git add .
   git commit -m "Import F1 Project Game"
   git branch -M main
   git remote add origin https://github.com/<TUO-USERNAME>/F1-ProjectGame.git
   git push -u origin main
   ```
2. Attiva un deploy Web manuale (opzionale): vai su Actions → "Deploy Web to GitHub Pages" → Run workflow.
3. Pubblica una Release automatica:
   ```
   git tag v0.1.0
   git push origin v0.1.0
   ```
   I workflow creeranno e allegheranno automaticamente gli asset (APK/ZIP Windows) alla Release.

## Struttura del codice

- `lib/`: schermate di gioco, logica, asset SVG/PNG integrati
- `assets/`: piste, loghi, immagini
- `web/`: index.html, favicon e manifest PWA
- `.github/workflows/`: automazioni CI/CD (Pages, APK, Windows)

## Licenza

Senza licenza esplicita: tutti i diritti riservati all’autore del repository. Inserire una licenza se necessario (MIT/Apache-2.0, etc.).
