---
name: fix-issue
description: Vollständiger Workflow zum Bearbeiten eines GitHub Issues — von der Analyse bis zum fertigen PR.
user-invocable: true
allowed-tools:
  - Bash(gh *)
  - Bash(git *)
  - Bash(bundle *)
  - Read
  - Edit
  - Write
  - Glob
  - Grep
---

# Fix Issue

Argumente: $ARGUMENTS
(Format: `<issue-nummer>` oder `pr`)

## Aufruf-Varianten

- `/fix-issue 153` — Issue analysieren und implementieren
- `/fix-issue pr` — PR für den aktuellen Branch erstellen (nach Commit)

---

## Workflow: Issue bearbeiten

### Schritt 1 — Issue lesen und Branch anlegen

Repo aus `git remote get-url origin` ableiten (Format: `owner/repo`).

```bash
gh api repos/<owner>/<repo>/issues/<nummer>
```

Issue-Titel und Body ausgeben.

Danach einen dedizierten Branch für dieses Issue anlegen (von `origin/master`):

```bash
git fetch origin
git checkout -b fix/<nummer>-<kurze-beschreibung> origin/master
```

Der Branch-Name leitet sich aus der Issue-Nummer und einem kurzen Slug des Titels ab (Kleinbuchstaben, Bindestriche statt Leerzeichen).

### Schritt 2 — Analyse und Annahmen

Codebase soweit nötig lesen. Dann **explizit auflisten**:

1. Wo die Änderung stattfinden muss (Datei/Zeile)
2. Welche Schicht/welches Tool betroffen ist
3. Etwaige Voraussetzungen

**Warten auf Bestätigung** bevor implementiert wird.

### Schritt 3 — Implementierung

Änderungen vornehmen. Danach Tests ausführen:

```bash
bundle exec rake test
```

Bei Fehlern: Ursache analysieren und beheben.

### Schritt 4 — Commit-Message ins Clipboard

Format:
```
<typ>: <kurze Beschreibung>

- Stichpunkt 1
- Stichpunkt 2 (nur bei mehreren Aspekten)

Closes #<nummer>
```

Typen: `feat`, `fix`, `doc`, `refactor`, `chore`

```bash
printf '%s\n' "COMMIT_MESSAGE" > "$TMPDIR/claude/commit-msg.txt"
```

Hinweis ausgeben: „Bitte in Magit committen, dann `/fix-issue pr` aufrufen."

---

## Workflow: PR erstellen

Wird mit Argument `pr` aufgerufen.

```bash
git log --oneline master..HEAD
```

Offen gemeldete Issues aus den Commit-Messages ableiten (`Closes #NNN`).

Branch pushen (falls noch nicht geschehen):

```bash
git push -u origin HEAD
```

```bash
gh pr create --title "<typ>: <kurze Beschreibung>" --body "$(cat <<'EOF'
## Summary

- Bullet 1
- Bullet 2

Closes #<nummer>

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

PR-URL ausgeben.
