# Color Palette

**Single source of truth for all colors.** Light pastel fills with muted, darker strokes. Edit this file to restyle every diagram.

---

## Shape Colors (Semantic)

Colors encode meaning, not decoration. Each semantic purpose has a fill/stroke pair.

| Semantic Purpose | Fill | Stroke |
|------------------|------|--------|
| Primary/Neutral | `#dbeafe` | `#6b93c4` |
| Secondary | `#e0e7ff` | `#8591c9` |
| Tertiary | `#e0f2fe` | `#7ab3d1` |
| Start/Trigger | `#ffe5d0` | `#d99a6c` |
| End/Success | `#d5f5e3` | `#6fb58a` |
| Warning/Reset | `#fde8e8` | `#d98a8a` |
| Decision | `#fff6d6` | `#d1b45f` |
| AI/LLM | `#ece4fb` | `#9b86d1` |
| Inactive/Disabled | `#f1f5f9` | `#94a3b8` (use dashed stroke) |
| Error | `#fbd5d5` | `#cf6b6b` |

**Rule**: Always pair a darker stroke with a lighter fill for contrast.

---

## Text Colors (Hierarchy)

Use color on free-floating text to create visual hierarchy without containers.

| Level | Color | Use For |
|-------|-------|---------|
| Title | `#3f5f8f` | Section headings, major labels |
| Subtitle | `#6b93c4` | Subheadings, secondary labels |
| Body/Detail | `#64748b` | Descriptions, annotations, metadata |
| Inside shapes | `#374151` | Text inside any pastel-filled shape |

---

## Evidence Artifact Colors

Used for code snippets, data examples, and other concrete evidence inside technical diagrams.

| Artifact | Background | Stroke | Text Color |
|----------|-----------|--------|------------|
| Code snippet | `#f8fafc` | `#cbd5e1` | `#334155`, with muted syntax accents (`#6b93c4` keywords, `#6fb58a` strings, `#9b86d1` types) |
| JSON/data example | `#f8fafc` | `#cbd5e1` | `#334155`, with `#6fb58a` for values |

---

## Default Stroke & Line Colors

| Element | Color |
|---------|-------|
| Arrows | Stroke color of the source element's semantic purpose |
| Structural lines (dividers, trees, timelines) | Slate `#94a3b8` |
| Marker dots (fill + stroke) | `#8fb0dc` |

---

## Background

| Property | Value |
|----------|-------|
| Canvas background | `#ffffff` |
