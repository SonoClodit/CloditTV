# CloditTV

Prima versione di un catalogo cinematografico personale per iPhone e iPad,
realizzato in Flutter e predisposto per una build IPA non firmata.

## Funzioni presenti

- home responsive per iPhone e iPad;
- catalogo popolare e ricerca tramite TMDB;
- catalogo dimostrativo quando manca la chiave TMDB;
- scheda film e ricerca esterna del trailer;
- preferiti salvati sul dispositivo;
- tema scuro CloditTV;
- logo vettoriale C + TV disegnato direttamente nell'app;
- animazioni fluide per banner, temi e card;
- palette Neon, Violet, Natale, Primavera ed Estate salvate sul dispositivo;
- icona ufficiale C + TV in nero e verde generata automaticamente per iOS;
- schermata di avvio animata con logo, bagliore e dissolvenza verso la Home;
- workflow Codemagic per generare `CloditTV-unsigned.ipa`.

## Ottenere una chiave TMDB

1. Crea un account su https://www.themoviedb.org/.
2. Apri Impostazioni > API e richiedi una API key personale.
3. In Codemagic aggiungi la variabile `TMDB_API_KEY`, preferibilmente come
   variabile protetta. Non inserirla direttamente nel repository.

TMDB è usato solo come catalogo di metadati. L'app non include sorgenti video.

## Compilazione dall'iPad con Codemagic

1. Carica questa cartella in un repository Git.
2. Da Safari apri Codemagic, collega il repository e scegli la configurazione
   `codemagic.yaml`.
3. Avvia il workflow **CloditTV unsigned IPA**.
4. A fine build scarica `CloditTV-unsigned.ipa` dagli artifacts.
5. Apri il file con Feather e firmalo usando il certificato già configurato.

Se Feather segnala un errore, controlla che il certificato e il provisioning
profile supportino il bundle identifier `com.clodit.tv`, oppure modifica la
variabile `BUNDLE_ID` nel workflow prima di ricompilare.

## Sviluppo locale futuro

```sh
flutter create --platforms=ios --org com.clodit --project-name clodit_tv .
flutter pub get
flutter run --dart-define=TMDB_API_KEY=LA_TUA_CHIAVE
```

## Nota sulle sorgenti

Il progetto può essere esteso tramite provider per API e cataloghi autorizzati.
Non contiene scraping di siti che distribuiscono opere senza licenza né sistemi
per estrarre o aggirare player video protetti.
