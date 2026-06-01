# Rawnaq Design System

This document describes the current visual and interaction style used in the Rawnaq desktop app.
It is written for the Flutter codebase in `desktop/lib` and should be treated as the source of truth
for new screens, dialogs, tables, forms, and project workspaces.

## Design Principles

- Dark, operational, and content-heavy
- Clear hierarchy before decoration
- Dense information, but with enough breathing room for scanning
- Data first, branding second
- Admin actions should be visible and direct
- Designer and execution workflows should feel related, but never identical

## Visual Direction

Rawnaq uses a dark dashboard style with soft borders, muted surfaces, and restrained accent colors.
The app should feel like a working internal system, not a marketing site.

Primary characteristics:

- Dark scaffold and card surfaces
- Subtle border lines instead of heavy shadows
- Soft rounded corners
- Compact labels and large readable page titles
- Status colors reserved for meaning, not decoration

## Color System

Use the values defined in [`app_colors.dart`](../lib/core/constants/app_colors.dart).

### Base Surfaces

- `scaffoldBackground`: `#161B22`
- `cardBackground`: `#1C2128`
- `surfaceColor`: `#21262D`
- `inputBackground`: `#0D1117`
- `border`: `#30363D`

### Brand And Accent

- `primary`: `#DFD8DE`
- `primaryLight`: `#EBE6EA`
- `primaryDark`: `#B8B0B7`
- `secondary`: `#3B82F6`
- `secondaryLight`: `#60A5FA`

### Text

- `textPrimary`: `#FFFFFF`
- `textSecondary`: `#8B949E`
- `textMuted`: `#6E7681`
- `textDisabled`: `#484F58`

### Status

- Success: `#22C55E`
- Warning: `#F59E0B`
- Error: `#EF4444`
- Info: `#3B82F6`

### Usage Rules

- Use `primary` for main controls and selected states.
- Use `secondary` for links, focus accents, and informative chips.
- Use status colors only when the state actually matters.
- Do not introduce bright gradients as a default.
- Do not use purple-heavy UI accents; the current product identity is cooler and more neutral.

## Typography

Use the values in [`app_text_styles.dart`](../lib/core/constants/app_text_styles.dart).

### Hierarchy

- Page title: `24px`, bold
- Section title: `18px`, semi-bold
- H1/H2 for high-level screens only
- Body text should stay quiet and readable
- Captions and labels must stay small and secondary

### Rules

- Prefer short labels and explicit field names.
- Keep Arabic UI text readable with enough line height.
- Use bold only for titles, values, and current state.
- Avoid making every label heavy.

## Layout And Spacing

The UI favors compact density with consistent whitespace.

### Spacing Scale

- `4`: micro spacing inside rows and chips
- `8`: standard spacing between inline elements
- `12`: card internals and metadata rows
- `16`: form groups and card padding
- `20` to `24`: between major sections
- `32+`: only for page-level separation

### Structure

- Sidebar on desktop
- Top bar above main content
- Cards used for grouped data
- Tables for dense records
- Tabs only when there are two or more strong views

## Shape And Elevation

The app uses soft geometry.

- Standard radius: `8`
- Card radius: `12`
- Dialog radius: `16`
- Pill chips are allowed for status and type labels

Elevation is intentionally low.

- Prefer borders over shadows
- Use shadows sparingly
- Keep surfaces distinct mainly through contrast

## Core Components

### Buttons

- Primary action: filled or filled tonal
- Secondary action: text button or tonal button
- Destructive action: clearly red and separated
- Avoid multiple competing primary buttons in one row

### Cards

- Cards should have a clear title, value, or purpose
- Use one strong visual anchor per card
- A card can hold metadata, status, or a compact action row

### Tables

- Tables are used for finance, projects, and pricing
- Keep headers readable and consistent
- Use row hover and alternating backgrounds only where useful
- Avoid overcrowding cells with nested controls

### Forms

- Labels above fields are preferred for clarity
- Inputs should have a dark fill and visible border
- Focus state must be obvious
- Validation errors should be short and direct
- Avoid checkbox-driven interaction patterns in the main application flow
- Prefer action buttons, status pills, toggles, or compact rows instead

### Chips And Badges

- Use chips for project type, status, and small state flags
- Status badges should communicate meaning quickly
- Do not use decorative chips without a reason

### Dialogs

- Dialogs should be focused and task-oriented
- Keep admin-only controls inside dialogs when they would otherwise clutter the main workspace
- Use dialogs for financial details, confirmations, and secondary workflows
- Dialog action buttons inside dark modals should be explicitly styled
- Avoid default pale Material filled buttons in Rawnaq dialogs
- Primary modal actions should use the dark brand accent with strong contrast

## Project Types

### Execution Projects

- Oriented around site work and implementation
- Can expose financial and task-heavy controls in the main workspace
- Used heavily with tables, installments, and transaction sections

### Design Projects

- Should feel lighter and more conversational
- Main page is a timeline/chat workspace
- Files and updates appear as messages or activity items
- Financial data should be hidden from non-admin users
- Default design tasks exist in the backlog, not inside the workspace view

## Design Workspace Pattern

For design projects, use this pattern:

1. Workspace header with project identity
2. Main chat/timeline area
3. Uploaded files appear as activity items
4. Admin-only financial dialog for totals and installment management
5. Default tasks stay in the task backlog

### Installment Management

- Administrators can add, edit, and remove installments after project creation
- Installment management should happen in a focused dialog, not inside the chat stream
- Each installment row may show payment state, amount, and due date
- The save action must use a dark, high-contrast button style
- Do not accept the default pale filled button look in finance dialogs

Do not place finance, task boards, or media galleries in the main design project page unless there is a strong reason.

## Task And Status Rules

- Draft tasks should remain unassigned until an admin assigns them
- The backlog should be the place where draft tasks are visible and draggable
- Assigned tasks should show the assignee clearly
- Completed and in-progress states should be obvious at a glance

## Control Rules

- Do not use checkbox controls as a primary interaction pattern in Rawnaq
- If a binary state must be shown, render it as a status pill, icon badge, toggle, or action row
- Keep active and inactive states consistent with the dark palette

## Media And Attachments

- Images should preview directly
- PDFs should open or preview when possible
- Videos should be playable or at least openable through a clear action
- Technical files like CAD should remain downloadable and clearly labeled
- Every attachment should feel like part of the activity stream

## Accessibility

- Preserve sufficient contrast on all dark surfaces
- Do not rely on color alone for meaning
- Keep clickable targets large enough
- Make dialogs, chips, and table actions keyboard accessible
- Use readable Arabic labels and avoid overly long sentences in controls

## Writing Style In The UI

- Use short Arabic labels
- Prefer project-oriented terms over technical jargon
- For admin screens, keep labels explicit
- For designer screens, keep the tone calm and operational

## Do

- Reuse `AppColors` and `AppTextStyles`
- Keep new UI consistent with existing cards and tables
- Put sensitive controls behind role checks
- Keep design workspaces focused on chat, activity, and files

## Do Not

- Do not invent a second visual language for one feature
- Do not expose admin-only financial details to all users
- Do not auto-generate payment splits when the user is explicitly entering values
- Do not turn the design workspace into a pricing or execution dashboard
- Do not add loud decorative styling without a reason

## Key Files

- [`app_colors.dart`](../lib/core/constants/app_colors.dart)
- [`app_text_styles.dart`](../lib/core/constants/app_text_styles.dart)
- [`app_theme.dart`](../lib/core/theme/app_theme.dart)
- [`main_layout.dart`](../lib/core/layout/main_layout.dart)
- [`project_card_widget.dart`](../lib/features/projects/presentation/widgets/project_card_widget.dart)
- [`create_project_dialog.dart`](../lib/features/projects/presentation/widgets/create_project_dialog.dart)
- [`design_project_workspace.dart`](../lib/features/design_projects/presentation/pages/design_project_workspace.dart)
- [`design_workspace_widgets.dart`](../lib/features/design_projects/presentation/widgets/design_workspace_widgets.dart)

## Short Summary

Rawnaq should stay a dark, structured, admin-grade dashboard.
The design language is compact, calm, and data-driven, with clear role separation between execution, pricing, and design work.
