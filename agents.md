# UI / UX Design Rules for Codex

Before editing any Flutter UI, always read:

- docs/DESIGN_SYSTEM.md
- docs/UI_EXAMPLES.md
- lib/core/theme/
- existing widgets under lib/presentation/widgets/

## Hard UI Rules

- Do not invent new colors, gradients, shadows, font sizes, spacing, or border radius.
- Use AppColors, AppTextStyles, AppSpacing, AppRadius, and AppTheme only.
- Reuse existing shared widgets before creating new ones.
- Match the visual style of existing screens.
- Keep layouts clean, modern, mobile-first, and responsive.
- Prefer simple hierarchy: title, subtitle, content card, primary action.
- Avoid random decorative UI unless the design system already uses it.
- Avoid oversized padding, weird shadows, excessive rounded corners, and inconsistent colors.
- Do not use private widget helper methods for UI sections.
- Extract reusable UI into dedicated StatelessWidget files under presentation/widgets/.

## Before Implementing UI

1. Inspect 2–3 existing screens with similar layout.
2. Identify the design pattern already used.
3. Propose the UI structure briefly.
4. Then implement using existing components and theme tokens.

## Done Means

- No hardcoded Color values in feature screens.
- No random TextStyle values in feature screens.
- No new visual style unless explicitly requested.
- Flutter analyzer passes.