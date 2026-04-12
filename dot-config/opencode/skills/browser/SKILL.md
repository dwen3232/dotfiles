---
name: browser
description: >
  Load this skill whenever the task involves controlling a browser, automating UI interactions, or verifying frontend behavior against a running app.

  Examples of when to load this skill:
  - "click the login button and verify the dashboard loads"
  - "fill out the signup form and check the confirmation email appears"
  - "verify the dropdown shows the correct options after selecting a country"
  - "check that the modal closes when clicking outside of it"
  - "make sure the pagination works correctly on the search results page"
  - "test that the file upload shows a preview before submitting"
  - "verify the app redirects to login when the session expires"
  - "automate logging in and navigating to the settings page"
  - "check what network requests are fired when the user submits the form"
---

# playwright-cli

A CLI tool for browser automation and e2e testing. Run `playwright-cli --help [command]` for full details on any command.

## Core workflow

Browser interaction is ref-based:
1. Run `snapshot` to capture the current page state and get element refs
2. Use the ref with interaction commands: `click <ref>`, `fill <ref> <text>`, `hover <ref>`, etc.
3. Re-snapshot after interactions to get updated refs

## Commands

### Navigation & interaction
- `open [url]` / `goto <url>` — open browser or navigate
- `click <ref>` / `dblclick <ref>` — click an element
- `fill <ref> <text>` / `type <text>` — enter text
- `select <ref> <val>` / `check <ref>` / `uncheck <ref>` — form controls
- `drag <startRef> <endRef>` / `hover <ref>` — pointer actions
- `press <key>` — keyboard (e.g. `Enter`, `ArrowLeft`)
- `eval <func> [ref]` — run arbitrary JS on the page or element
- `dialog-accept [prompt]` / `dialog-dismiss` — handle dialogs

### Page state
- `snapshot` — capture page structure and element refs
- `screenshot [ref]` — screenshot page or element
- `go-back` / `go-forward` / `reload` — navigation history
- `resize <w> <h>` — resize the browser window

### Storage & auth
- `state-save [filename]` / `state-load <filename>` — persist/restore full browser auth state between runs
- `cookie-list` / `cookie-set` / `cookie-delete` / `cookie-clear` — cookie management
- `localstorage-list` / `localstorage-set` / `localstorage-get` — localStorage
- `sessionstorage-list` / `sessionstorage-set` / `sessionstorage-get` — sessionStorage

### Network
- `route <pattern>` — mock requests matching a URL pattern
- `route-list` / `unroute [pattern]` — inspect or remove mocks
- `network` — list all requests since page load

### Debugging
- `console [min-level]` — list console messages
- `tracing-start` / `tracing-stop` — record a trace
- `video-start` / `video-stop` — record video
- `show` / `devtools-start` — open DevTools

### Tabs & sessions
- `tab-new [url]` / `tab-close [index]` / `tab-select <index>` / `tab-list`
- `list` / `close-all` / `kill-all` — manage browser sessions

## Session flag

Use `-s=<name>` to target a named browser session:
```
playwright-cli -s=myapp snapshot
```

## Key patterns

**Persist auth across runs:**
```
playwright-cli state-save auth.json
playwright-cli state-load auth.json
```

**Mock an API endpoint:**
```
playwright-cli route "*/api/users"
```

**Capture and interact:**
```
playwright-cli goto http://localhost:3000
playwright-cli snapshot
playwright-cli fill <ref> "test@example.com"
playwright-cli click <ref>
playwright-cli screenshot
```
