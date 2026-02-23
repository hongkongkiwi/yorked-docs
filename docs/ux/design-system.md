# Design System

Owner: Product Design  
Status: Draft  
Last Updated: 2026-02-20  
Depends On: `docs/ux/flows/`

## Purpose

Define consistent visual language, components, and patterns for Yoked. Ensures brand consistency and development efficiency.

> **Note:** Values below are initial recommendations. Update when final design is approved.

## Brand Identity

### Brand Personality
- Warm and approachable
- Trustworthy and safe
- Intentional and thoughtful
- Modern but not trendy

### Voice & Tone
- Conversational but not casual
- Empowering, not prescriptive
- Clear and honest
- Inclusive language

## Color System

### Primary Palette

| Name | Hex | Usage |
|------|-----|-------|
| Primary | `#6366F1` (Indigo) | Buttons, links, accents, CTAs |
| Primary Dark | `#4F46E5` | Primary hover/pressed states |
| Secondary | `#EC4899` (Pink) | Secondary actions, highlights |
| Background | `#FAFAFA` (Light) / `#18181B` (Dark) | Screen backgrounds |
| Surface | `#FFFFFF` (Light) / `#27272A` (Dark) | Cards, elevated surfaces |
| Surface Elevated | `#F4F4F5` (Light) / `#3F3F46` (Dark) | Modals, overlays |

### Semantic Colors

| Name | Hex | Usage |
|------|-----|-------|
| Success | `#22C55E` (Green) | Confirmations, positive states |
| Warning | `#F59E0B` (Amber) | Cautions, alerts |
| Error | `#EF4444` (Red) | Errors, destructive actions |
| Info | `#3B82F6` (Blue) | Information, tips |

### Text Colors

| Name | Light Mode | Dark Mode | Usage |
|------|------------|-----------|-------|
| Primary | `#18181B` | `#FAFAFA` | Headlines, body text |
| Secondary | `#71717A` | `#A1A1AA` | Captions, descriptions |
| Disabled | `#D4D4D8` | `#52525B` | Disabled states |
| Inverse | `#FFFFFF` | `#18181B` | Text on primary backgrounds |

## Typography

### Font Stack
- Primary: Inter (Google Fonts)
- Fallback: system-ui, -apple-system, BlinkMacSystemFont, sans-serif

### Type Scale

| Name | Size | Weight | Line Height | Usage |
|------|------|--------|-------------|-------|
| Display | 32px | 700 | 1.2 | Hero headlines, celebration |
| H1 | 24px | 600 | 1.3 | Screen titles |
| H2 | 20px | 600 | 1.3 | Section headers |
| H3 | 18px | 600 | 1.4 | Subsections |
| Body | 16px | 400 | 1.5 | Body text |
| Body Bold | 16px | 600 | 1.5 | Emphasized body |
| Caption | 14px | 400 | 1.4 | Captions, hints |
| Small | 12px | 400 | 1.4 | Labels, timestamps |

## Spacing

### Base Unit
8px

### Spacing Scale

| Token | Value | Usage |
|-------|-------|-------|
| xs | 4px | Tight spacing, inline gaps |
| sm | 8px | Small gaps, icon spacing |
| md | 16px | Standard gaps, card padding |
| lg | 24px | Section gaps, list spacing |
| xl | 32px | Large gaps, screen margins |
| 2xl | 48px | Screen edge margins |

## Border Radius

| Token | Value | Usage |
|-------|-------|-------|
| sm | 4px | Tags, badges |
| md | 8px | Small cards, chips |
| lg | 12px | Buttons, inputs |
| xl | 16px | Cards, modals |
| full | 9999px | Pills, avatars |

## Components

### Buttons

#### Primary Button
- Height: 48px
- Min width: 120px
- Padding: 16px 24px
- Border radius: 12px
- Font: Body Bold (16px/600)
- Background: Primary
- Text: White

#### Secondary Button
- Height: 48px
- Padding: 16px 24px
- Border: 1px solid Primary
- Border radius: 12px
- Background: transparent
- Text: Primary

### Cards

- Background: Surface
- Border radius: 16px
- Padding: 16px
- Shadow (light): `0 1px 3px rgba(0,0,0,0.1)`
- Shadow (elevated): `0 4px 12px rgba(0,0,0,0.15)`

### Input Fields

- Height: 48px
- Padding: 12px 16px
- Border radius: 12px
- Border: 1px solid `#E4E4E7`
- Focus: 2px ring in Primary
- Placeholder: Secondary text color

### Avatars

| Size | Dimensions | Usage |
|------|------------|-------|
| sm | 32px | Inline mentions, compact lists |
| md | 48px | Chat list, comments |
| lg | 64px | Profile cards |
| xl | 96px | Profile header |
| 2xl | 128px | Profile edit |

## Icons

### Icon Set
Phosphor Icons (Regular weight default)

### Sizes
- Small: 16px
- Medium: 24px (default)
- Large: 32px

## Motion

### Timing
- Fast: 150ms (hover, tap, focus)
- Normal: 250ms (transitions, reveals)
- Slow: 400ms (page transitions, modals)

### Easing
- Default: `ease-out`
- Enter: `cubic-bezier(0.16, 1, 0.3, 1)` (springy)
- Exit: `ease-in`

## Elevation (Shadows)

| Level | Shadow | Usage |
|-------|--------|-------|
| 0 | none | Flat surfaces |
| 1 | `0 1px 2px rgba(0,0,0,0.05)` | Cards, list items |
| 2 | `0 4px 6px rgba(0,0,0,0.1)` | Dropdowns, popovers |
| 3 | `0 10px 15px rgba(0,0,0,0.1)` | Modals, sheets |
| 4 | `0 20px 25px rgba(0,0,0,0.15)` | Full-screen overlays |

## Design Tokens

All design tokens are defined in code:
- React Native: `packages/ui/src/tokens/`
- Figma: synced via Tokens Studio

## Resources

- Figma: TBD (create when design finalized)
- Icon library: https://phosphoricons.com

## Related Documents

- `docs/ux/accessibility.md`
- `docs/ux/flows/`
