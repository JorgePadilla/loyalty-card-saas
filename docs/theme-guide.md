# Theme Guide — Off-White + Matte Black

Premium through restraint. Think Apple Card, Aesop, Cereal magazine.

## Color Palette

| Token | Hex | Usage |
|-------|-----|-------|
| `background` | `#FAF9F6` | Main background — warm cream, not harsh white |
| `surface` | `#FFFFFF` | Cards, modals, elevated surfaces |
| `surfaceVariant` | `#F0EFEC` | Input fields, secondary containers |
| `primary` | `#1A1A1A` | Primary text, CTA buttons, icons — matte black |
| `primaryVariant` | `#2C2C2C` | Pressed/active state for buttons |
| `secondary` | `#6B6B6B` | Secondary text, labels, timestamps |
| `tertiary` | `#9E9E9E` | Placeholder text, disabled states |
| `border` | `#E5E4E1` | Card borders, dividers — barely visible |
| `cardGold` | `#C9A84C` | **ONLY** on the loyalty card widget (gradient, edge, tier badge) |
| `cardGoldLight` | `#E8D48B` | Loyalty card shimmer / highlight |
| `success` | `#2D6A4F` | Check-in confirmed — deep green, not neon |
| `error` | `#C1292E` | Errors — muted red |

## Typography

| Role | Font | Weight | Notes |
|------|------|--------|-------|
| Headlines | Inter | w600 | Bold enough to anchor, not shouty |
| Body | Inter | w400 | Clean, legible, invisible |
| Numbers/Points | Space Grotesk | w500 | Tech-forward feel for point balances |
| Captions/Labels | Inter | w400, 12-13px | In `#6B6B6B` |
| Uppercase labels | Inter | w400 | Letter-spacing +0.3px for editorial feel |

## Tailwind Config

```js
// tailwind.config.js (Rails 8 web side)
module.exports = {
  theme: {
    extend: {
      colors: {
        cream:     '#FAF9F6',
        surface:   '#FFFFFF',
        matte:     '#1A1A1A',
        secondary: '#6B6B6B',
        border:    '#E5E4E1',
        gold:      '#C9A84C',
        'gold-lt': '#E8D48B',
        success:   '#2D6A4F',
        danger:    '#C1292E',
      },
      fontFamily: {
        sans:  ['Inter', 'system-ui', 'sans-serif'],
        mono:  ['Space Grotesk', 'monospace'],
      },
    },
  },
}
```

## Design Principles

1. **Extreme whitespace.** #1 signal of premium. Cards: 24px padding. Sections: 40-48px vertical spacing. The screen should feel half-empty.

2. **No gradients on UI chrome.** Buttons are flat matte black with white text. No shadows on cards — use 1px `#E5E4E1` borders. The only gradient is on the loyalty card itself.

3. **The loyalty card is the sole hero.** Full-width card with dark-to-gold gradient, embossed text. The one rich, indulgent element. Everything else is deliberately plain.

4. **Micro-animations, but tasteful.** Points counting animation. Subtle fades (200ms). Brief confetti on reward redemption. No bounces, no jiggles.

5. **Photography over illustration.** Real photos with slight desaturation. No clip art, no decorative icons.

6. **Black CTA buttons, always.** Matte black rectangles, white text, 12px corner radius. Every primary action.

## Key Screens (Flutter)

- **Home:** Cream bg, loyalty card centered, points in Space Grotesk, clean activity feed with hairline dividers.
- **QR scan (staff):** Full-screen camera, thin matte-black scan frame. Green checkmark fade on success.
- **Rewards:** Vertical list, large whitespace. Photo + name + black pill badge (points cost). Matte black "Redeem" button.
- **Login:** Nearly empty. Logo, email field, matte black "Continue" button. Nothing else.

## Key Screens (Hotwire Admin)

- **Dashboard:** White bg, black chart lines, gray grid. Key metrics in large Space Grotesk numbers. Turbo Frames for each widget.
- **Rewards CRUD:** Clean table with inline edit via Turbo Frames. Matte black action buttons.
- **Marketing pages:** Generous whitespace, Inter typography, product screenshots on cream bg.
