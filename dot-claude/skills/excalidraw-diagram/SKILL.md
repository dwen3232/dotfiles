---
name: excalidraw-diagram
description: Create Excalidraw diagram JSON files that make visual arguments. Use when the user wants to visualize workflows, architectures, or concepts, or asks for a .excalidraw file.
---

# Excalidraw Diagram Creator

Generate `.excalidraw` JSON files that **argue visually**, not just display information.

All colors live in `references/color-palette.md`. Read it before generating any diagram and use it as the single source of truth for every color choice.

---

## Core Philosophy

**Diagrams should ARGUE, not DISPLAY.**

A diagram is not formatted text. It shows relationships, causality, and flow that words alone cannot express. The shape should BE the meaning.

- **Isomorphism test**: If you removed all text, would the structure alone communicate the concept? If not, redesign.
- **Education test**: Could someone learn something concrete from this diagram, or does it just label boxes? Show actual formats, real event names, concrete examples.

---

## Depth and Research

Decide first what the diagram needs:

- **Simple/conceptual** (mental models, philosophies): abstract shapes and labels are fine.
- **Comprehensive/technical** (real systems, protocols, architectures, anything meant to teach): use concrete examples and include evidence artifacts.

For technical diagrams, research the actual specifications before drawing: real JSON/data formats, event names, method names, API endpoints. Use real terminology, not placeholders.

Bad: "Protocol" -> "Frontend". Good: "Server streams events (RUN_STARTED, STATE_DELTA)" -> "Client renders via createRenderer()".

### Evidence Artifacts

Concrete examples that prove the diagram is accurate and help viewers learn.

| Artifact Type | When to Use | How to Render |
|---------------|-------------|---------------|
| Code snippets | APIs, integrations, implementation details | Light rectangle + syntax-colored text (see palette) |
| Data/JSON examples | Data formats, schemas, payloads | Light rectangle + colored text (see palette) |
| Event/step sequences | Protocols, workflows, lifecycles | Timeline pattern (line + dots + labels) |
| UI mockups | Showing actual output | Nested rectangles mimicking real UI |
| Real input content | What goes IN to a system | Rectangle with sample content visible |
| API/method names | Function calls, endpoints | Actual names from docs |

Show what things actually look like, not just what they are called.

### Multi-Zoom Structure

Comprehensive diagrams work at three levels at once:

1. **Summary flow**: the whole pipeline at a glance (e.g. `Input -> Processing -> Output`), usually at the top or bottom.
2. **Section boundaries**: labeled regions grouping related components (by responsibility, phase, or team).
3. **Detail inside sections**: evidence artifacts and concrete examples. This is where the educational value lives.

---

## Container vs. Free-Floating Text

Default to free-floating text. Add containers only when they serve a purpose.

| Use a Container When... | Use Free-Floating Text When... |
|------------------------|-------------------------------|
| It is the focal point of a section | It is a label or description |
| It needs visual grouping with other elements | It is supporting detail or metadata |
| Arrows need to connect to it | It describes something nearby |
| The shape itself carries meaning (decision diamond) | Typography alone creates sufficient hierarchy |
| It represents a distinct "thing" in the system | It is a section title, subtitle, or annotation |

Use font size and color for hierarchy instead of boxes. A 28px title does not need a rectangle. For each boxed element ask: would this work as free-floating text? If yes, remove the container. Aim for under 30% of text elements inside containers.

---

## Design Process (Before Generating JSON)

### Step 1: Understand Deeply
For each concept ask:
- What does it **do**, not what is it?
- What relationships exist between concepts?
- What is the core transformation or flow?
- What would someone need to **see** to understand it?

For comprehensive diagrams, research first (see above).

### Step 2: Map Concepts to Patterns

| If the concept... | Use this pattern |
|-------------------|------------------|
| Spawns multiple outputs | **Fan-out** (radial arrows from center) |
| Combines inputs into one | **Convergence** (funnel, arrows merging) |
| Has hierarchy/nesting | **Tree** (lines + free-floating text) |
| Is a sequence of steps | **Timeline** (line + dots + free-floating labels) |
| Loops or improves continuously | **Cycle** (arrow returning to start) |
| Is an abstract state or context | **Cloud** (overlapping ellipses) |
| Transforms input to output | **Assembly line** (before -> process -> after) |
| Compares two things | **Side-by-side** (parallel with contrast) |
| Separates into phases | **Gap/Break** (visual separation between sections) |

### Step 3: Ensure Variety
In multi-concept diagrams, each major concept uses a different visual pattern. No uniform cards or grids.

### Step 4: Sketch the Flow
Mentally trace how the eye moves through the diagram. There must be a clear visual story.

### Step 5: Generate JSON
See the large-diagram strategy below.

### Step 6: Render and Validate (mandatory)
See Render and Validate below.

---

## Large Diagram Strategy

For comprehensive diagrams, build the JSON one section at a time. Do not generate the whole file in one response: output limits truncate it into broken JSON, and quality is worse anyway.

1. **Create the base file** with the JSON wrapper (`type`, `version`, `appState`, `files`) and the first section's elements.
2. **Add one section per edit.** Think about layout, spacing, and how the section connects to what exists.
3. **Use descriptive string IDs** (`"trigger_rect"`, `"arrow_fan_left"`) so cross-section references are readable.
4. **Namespace seeds by section** (section 1 uses 100xxx, section 2 uses 200xxx) to avoid collisions.
5. **Update cross-section bindings as you go.** When a new element binds to an earlier one, edit the earlier element's `boundElements` at the same time.
6. **Review the whole** before rendering: cross-section arrows bound on both ends, balanced spacing, every ID and binding references an element that exists.

Split sections along natural groupings: entry point/trigger, first decision/routing, main content (often the largest), remaining phases and outputs. Each section should be understandable on its own.

Do not delegate JSON generation to a subagent (it lacks this skill's rules). Do not write a Python generator script: hand-written JSON with descriptive IDs is easier to debug.

---

## Lines as Structure

Prefer `line` elements (not arrows) over boxes for structure:
- **Timelines**: a line with small dots (10-20px ellipses) at intervals and free-floating labels beside each dot.
- **Trees**: a vertical trunk plus horizontal branches, with free-floating text labels.
- **Dividers**: thin dashed lines separating sections.
- **Flow spines**: a central line that elements relate to, instead of connected boxes.

```
Timeline:           Tree:
  o--- Label 1        |
  |                   |-- item
  o--- Label 2        |   |-- sub
  |                   |   '-- sub
  o--- Label 3        '-- item
```

---

## Shape Meaning

| Concept Type | Shape | Why |
|--------------|-------|-----|
| Labels, descriptions, details | none (free-floating text) | Typography creates hierarchy |
| Section titles, annotations | none (free-floating text) | Font size/weight is enough |
| Markers on a timeline | small `ellipse` (10-20px) | Visual anchor, not container |
| Start, trigger, input | `ellipse` | Soft, origin-like |
| End, output, result | `ellipse` | Completion, destination |
| Decision, condition | `diamond` | Classic decision symbol |
| Process, action, step | `rectangle` | Contained action |
| Abstract state, context | overlapping `ellipse` | Fuzzy, cloud-like |
| Hierarchy node | lines + text (no boxes) | Structure through lines |

---

## Color

Colors encode meaning, not decoration. Take every color from `references/color-palette.md`: semantic shape pairs, text hierarchy, evidence artifacts, lines.

- Each semantic purpose (start, end, decision, AI, error) has a fill/stroke pair.
- Free-floating text uses color for hierarchy (title, subtitle, detail).
- Do not invent new colors. If a concept fits no category, use Primary/Neutral or Secondary.

---

## Aesthetics

- `roughness: 0` for clean, crisp edges (default). `roughness: 1` only for informal, hand-drawn diagrams.
- `strokeWidth`: 1 for lines and dividers, 2 for shapes and primary arrows, 3 sparingly for emphasis.
- `opacity: 100` on every element. Create hierarchy with color, size, and stroke width, not transparency.
- Use small dots (10-20px ellipses) as timeline markers, bullets, connection nodes, and anchors for free-floating text.

---

## Layout

- **Scale for hierarchy**: Hero 300x150, Primary 180x90, Secondary 120x60, Small 60x40.
- **Whitespace = importance**: the most important element gets the most empty space (200px+).
- **Flow direction**: left-to-right or top-to-bottom for sequences, radial for hub-and-spoke.
- **Connections required**: if A relates to B, draw an arrow. Position alone does not show relationships.

---

## Text Rules

The JSON `text` property contains only readable words.

```json
{
  "id": "myElement1",
  "text": "Start",
  "originalText": "Start"
}
```

Settings: `fontSize: 16`, `fontFamily: 3`, `textAlign: "center"`, `verticalAlign: "middle"`.

---

## JSON Structure

```json
{
  "type": "excalidraw",
  "version": 2,
  "source": "https://excalidraw.com",
  "elements": [...],
  "appState": {
    "viewBackgroundColor": "#ffffff",
    "gridSize": 20
  },
  "files": {}
}
```

Copy-paste templates for each element type (text, line, dot, rectangle, arrow) are in `references/element-templates.md`. Property reference is in `references/json-schema.md`.

---

## Render and Validate (mandatory)

JSON alone cannot show whether a diagram works. After generating or editing, render to PNG, view it, and fix what you see, in a loop.

### Render

```bash
~/.cache/excalidraw-render/bin/python ~/.claude/skills/excalidraw-diagram/references/render_excalidraw.py <path-to-file.excalidraw>
```

This writes a PNG next to the `.excalidraw` file. Use the Read tool on the PNG to view it. The renderer loads Excalidraw from `esm.sh`, so it needs network access.

### First-Time Setup

```bash
python3 -m venv ~/.cache/excalidraw-render
~/.cache/excalidraw-render/bin/pip install playwright
~/.cache/excalidraw-render/bin/playwright install chromium
```

### The Loop

1. **Render and view** the PNG.
2. **Audit against the design**: does the visual structure match the planned concept, does each section use its intended pattern, does the eye flow in the designed order, is hierarchy correct (hero dominant, supporting smaller), are evidence artifacts readable?
3. **Check for defects**:
   - text clipped by or overflowing its container
   - overlapping text or shapes
   - arrows crossing elements, landing on the wrong element, or pointing into empty space
   - labels not clearly anchored to what they describe
   - uneven spacing, cramped next to empty sections
   - text too small to read
   - lopsided composition
4. **Fix** the JSON: widen containers for clipped text, adjust `x`/`y`, add waypoints to arrow `points` to route around elements, move labels closer, resize to rebalance weight.
5. **Re-render and re-view.** Repeat until both the design audit and the defect check pass (typically 2-4 iterations). Improve composition even when no bug remains.

Stop when the render matches the design, nothing is clipped, overlapping, or unreadable, arrows route cleanly to the right elements, and spacing is balanced.

---

## Final Checklist

- Technical diagrams: research done, evidence artifacts present, summary + sections + detail levels.
- Each major concept uses a distinct visual pattern; no uniform card grids.
- Minimal containers; trees and timelines use lines, not boxes.
- Every relationship has an arrow or line; clear visual path for the eye.
- `text` holds only readable words; `fontFamily: 3`; `roughness: 0`; `opacity: 100`.
- Rendered to PNG and visually inspected with no overflow, overlap, or misrouted arrows.
