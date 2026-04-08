# ha-component-kit

> Future React component library for House Dodson Home Assistant dashboards.

## Vision

A custom React project using [`@hakit/core`](https://github.com/shannonhochkins/ha-component-kit) to build a fully
type-safe, component-driven dashboard that replaces the YAML Lovelace configuration.

## Planned Stack

- **@hakit/core** — HA WebSocket connection, entity hooks, type-safe services
- **@hakit/components** — Pre-built HA-aware React components
- **React** + **TypeScript**
- **Vite** for local dev and build
- **Serve via** Nginx or HA Panel Custom (via HACS)

## Why ha-component-kit?

| Feature | YAML Lovelace | ha-component-kit |
|---------|--------------|-----------------|
| Type safety | None | Full TypeScript |
| Reusable components | Limited | Full React ecosystem |
| Complex logic | Template hacks | Native JS/TS |
| Testing | Manual | Unit + integration tests |
| Design system | card-mod CSS | Styled components |

## Planned Features

- **Room panels** — Per-room React components with real-time entity state
- **Weather widget** — Rich forecast display with sunrise/sunset arc visualization
- **Presence map** — Person location cards with zone awareness
- **Security overview** — Camera grid, lock status, sensor states in one view
- **Battery dashboard** — Sortable table with low-battery alerts

## Getting Started (Future)

```bash
# Initialize (when ready)
npm create @hakit/app@latest house-dodson-ui
cd house-dodson-ui
npm install
npm run dev
```

## Status

**Placeholder only** — Implementation deferred to a future session.

Current dashboards use Bubble Card (YAML) as the primary UI layer.
See `ui-lovelace.yaml` for the current Bubble Card single-view design.

---

*House Dodson Command — Phase 5 scaffold created 2026-02-21*
