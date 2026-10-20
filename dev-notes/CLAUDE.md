# KOB Musicisti — note di progetto (v1.0)

## Scopo
Liste di musicisti per strumento in ordine di priorità (drag & drop) e stato delle richieste per progetto. Uso personale di Matteo, non condivisa.

## Stack
- Single-file `index.html` (vanilla JS, CSS custom properties, UI dark), PWA con `sw.js` + `manifest.webmanifest`.
- Supabase: progetto condiviso con le altre app "CaliMat" (`edlvmkjctzhqoswpppds`, eu-central-1), anon key legacy in `index.html`, auth email/password, RLS `user_id = auth.uid()`. Migrazione applicata: `kob_musicisti_init`.
- Hosting Cloudflare Pages (nessun build, output = root). `_headers`: no-cache su `sw.js` e `index.html`.
- Librerie CDN: supabase-js 2.45.4 (UMD), SortableJS 1.15.2, PapaParse 5.4.1, Tabler Icons webfont 3.19.0 (outline), font Figtree.
- Versione: non incrementare `APP_VERSION` né `CACHE` in `sw.js` senza richiesta esplicita.

## Tabelle (prefisso kob_) — schema in `supabase/schema.sql`
- `kob_strumenti` (nome, posizione)
- `kob_musicisti` (strumento_id → cascade, nome, orchestra_ruolo, citta, telefono, email, canale, suggerito_da, note, posizione)
- `kob_progetti` (nome, posizione)
- `kob_progetti_strumenti` (progetto_id, strumento_id → cascade, posizione; unique progetto+strumento)
- `kob_richieste` (progetto_id, musicista_id → cascade, stato ∈ chiesto/accettato/rifiutato; unique progetto+musicista). Stato vuoto = riga cancellata.
- Tutte con id uuid generato dal client (`crypto.randomUUID`), user_id, created_at, updated_at.

## Ordine di priorità
- Campo `posizione` double precision. Drag → nuova posizione = media tra i vicini; se lo spazio < 1e-6 rinumera tutta la lista 1..N.
- L'ordine vive solo nella lista master dello strumento: i progetti leggono `musOf(strumento)` ordinato per posizione, quindi seguono sempre la priorità corrente.
- Ordinamento per Città / Nome e ricerca sono solo visualizzazione: il drag è attivo solo in modalità Priorità senza ricerca. Tornando su Priorità si ritrova l'ultimo ordine trascinato.

## Offline / sync
- Cache completa dei dati in localStorage `kob_cache_<user_id>`.
- Coda modifiche `kob_pending_queue` (upsert/delete per id, coalescenza degli upsert sulla stessa riga). Flush sequenziale; errore di rete → stop e riprova (evento online, visibilità, ogni 30 s).
- `pull()` ricarica tutto da Supabase solo a coda vuota.
- Cancellazioni a cascata: il DB cancella i figli (ON DELETE CASCADE); in locale `dropLocal()` li rimuove e toglie dalla coda le loro operazioni. Togliere uno strumento da un progetto cancella esplicitamente le richieste relative.
- Status dot: verde sincronizzato, arancione modifiche in coda, rosso offline.
- SW: network-first per l'HTML, cache-first per icone/CDN/font, esclude `*.supabase.co`.

## UI
- Tab: Liste / Progetti. Liste → strumento → musicisti (drag, ordina Priorità/Città/Nome, ricerca, tap = scheda modifica con tel/mail).
- Progetti (drag, cestino su ogni riga per eliminare i progetti finiti) → progetto: strumenti cercati (drag, + da strumenti disponibili, x per togliere) → strumento: musicisti in ordine di priorità con 4 stati: – (vuoto), Chiesto (giallo), Accettato (verde), Rifiutato (rosso).
- Ogni cancellazione chiede conferma (modale).
- Import CSV da export Notion (Impostazioni o menu lista): colonne Nome, Orchestra / ruolo, Città, Telefono, Email, Canale, Suggerito da, Note, Priorità. Opzioni: escludi "4 - Sconsigliato", elenco nomi per ordine iniziale; salta nomi già presenti.
- Export backup JSON dalle impostazioni.

## Dati iniziali
- Importati direttamente in Supabase per l'utente di Matteo.
- Strumenti (posizione, musicisti all'import): Fagotto 1 (87), Oboe 2 (81), Timpani 3 (55), Flauto 4 (62), Clarinetto 5 (3), Arpa 6 (28), Percussioni 7 (74).
- Fonte Notion "KOB Musicisti" (CSV in `liste strumenti/<Strumento>.csv`): Fagotto = ordine manuale della vista Notion; Oboe, Timpani, Clarinetto = Priorità Notion. Notion resta solo come archivio.
- Fonte export gestionale KOB (xlsx TOP/TOT) per Flauto, Arpa, Percussioni: prima la lista TOP, poi i restanti della TOT, poi i musicisti già presenti da Notion (Anne Neugebauer, già presente, spostata nella sua posizione TOP). Campi importati: nome, città (Paese), telefoni (Mobile / Phone), email, altri strumenti in Note; esclusi dati personali (AHV, IBAN, nascita, indirizzo, Notiz).

## TWA (facoltativo)
- `.well-known/assetlinks.json` con package `io.github.matteo2712.kobmusicisti`: inserire lo SHA256 del keystore generato da PWABuilder.
