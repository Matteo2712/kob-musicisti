# Passaggio a Cowork — KOB Musicisti v1.0

Questa cartella contiene l'app completa. Leggi prima `dev-notes/CLAUDE.md` (architettura, tabelle, regole).
Stack identico alle altre app di Matteo (CaliMat, PesoDigiuno, FocusMat, Abitudini): single-file HTML, Supabase condiviso, Cloudflare Pages, GitKraken per Git.

## Compiti per Claude (Cowork)
1. **Credenziali Supabase**: in `index.html` sostituire `INSERISCI_SUPABASE_URL` e `INSERISCI_SUPABASE_ANON_KEY` con URL e anon key del progetto Supabase condiviso (li trovi nell'`index.html` di un'altra app di Matteo, es. CaliMat/PesoDigiuno/Abitudini, se la cartella è accessibile; altrimenti chiederli a Matteo).
2. **Database**: eseguire `supabase/schema.sql` sul progetto condiviso (connettore Supabase: `apply_migration`, nome `kob_musicisti_init`). Verificare con `list_tables` che esistano le 5 tabelle `kob_*` con RLS attiva.
3. **Dati da Notion**: con il connettore Notion leggere i database sotto la pagina "KOB Musicisti" (uno per strumento: "Musicisti - Fagotto", "Musicisti - Oboe", …). Per ognuno:
   - creare `liste strumenti/<Strumento>.csv` con colonne `Nome,Orchestra / ruolo,Città,Telefono,Email,Canale,Suggerito da,Note,Priorità` (formato identico all'export Notion, così resta importabile anche dall'app);
   - escludere le righe con Priorità "4 - Sconsigliato".
4. **Import diretto in Supabase** (alternativa più comoda all'import dall'app): serve lo `user_id` di Matteo in `auth.users` (chiedere l'email di login a Matteo e cercarla). Inserire:
   - una riga in `kob_strumenti` per strumento (posizione 1, 2, 3…);
   - i musicisti in `kob_musicisti` con `posizione` 1..N.
   - Ordine Fagotto: prima i 25 nomi di `liste strumenti/fagotto-ordine-priorita.txt` nell'ordine del file, poi gli altri per Priorità Notion (1, 2, 3, vuoto). Per gli altri strumenti: per Priorità Notion.
   - Id: `gen_random_uuid()`. Campi vuoti = NULL.
5. **Controllo finale**: conteggio musicisti per strumento in Supabase = righe dei CSV.
6. **Commit**: preparare il testo del commit per GitKraken (Matteo fa commit e push).
7. Non cambiare `APP_VERSION` (v1.0) né la cache in `sw.js` senza richiesta esplicita di Matteo.

## Compiti per Matteo
1. GitHub: creare il repo `Matteo2712/kob-musicisti` e collegarlo a questa cartella in GitKraken; commit + push.
2. Cloudflare Pages: Create → Connect to Git → `kob-musicisti` → Framework "None", build command vuoto, output directory `/` → Deploy.
3. Aprire l'URL `*.pages.dev`, fare login con l'account Supabase di sempre, controllare le liste.
4. Installare la PWA: Android Chrome → Installa app; PC Chrome/Edge → icona installa nella barra indirizzi.
5. (Facoltativo) TWA con PWABuilder, poi SHA256 del keystore in `.well-known/assetlinks.json` e nuovo push.

## Decisioni già prese (non ridiscutere)
- Ordine di priorità = drag & drop nella lista master; Città/Nome e ricerca ordinano solo la vista, tornando su Priorità si ritrova l'ultimo ordine.
- I progetti mostrano sempre i musicisti nell'ordine della lista master.
- Stati richiesta: vuoto, Chiesto (giallo), Accettato (verde), Rifiutato (rosso).
- Ogni cancellazione chiede conferma; i progetti finiti si eliminano dal cestino nella lista Progetti.
- Etichetta "Priorità" di Notion non usata nell'app (serve solo per l'ordine iniziale d'import); gli sconsigliati si eliminano.
- In futuro Matteo aggiungerà altri strumenti (pianoforte, cembalo…) direttamente dall'app: non crearli ora.
