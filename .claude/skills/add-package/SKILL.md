---
name: add-package
description: Add a package to chezmoi packages.yaml. Asks which package, install method, and profile tier before making the change.
user-invocable: true
allowed-tools: Read, Edit, AskUserQuestion
argument-hint: [package-name]
---

# Add Package to packages.yaml

You are adding a package to the chezmoi package manifest at `.chezmoidata/packages.yaml`.

## Process

1. If `$ARGUMENTS` is provided, use it as the package name. Otherwise, ask the user what package they want to add.

2. Read `.chezmoidata/packages.yaml` to understand the current structure and existing packages.

3. Use AskUserQuestion to gather the following (combine into a single call where possible):

   **Question 1 - Tier**: Which tier should this package go in?
   - `shared` — installed on all machines regardless of profile
   - `personal` — only on personal machines
   - `work` — only on work machines

   **Question 2 - Install method**: How should the package be installed?
   - `brew formula` — Homebrew formula (CLI tool)
   - `brew cask` — Homebrew cask (GUI app or large binary)
   - `brew tap + formula` — Needs a custom tap first (ask for tap name as follow-up)
   - `npm` — npm global package

   If the user picks "brew tap + formula", ask a follow-up for the tap name (e.g. `redis/redis`).

4. Edit `.chezmoidata/packages.yaml` to add the package in the correct location:
   - **shared + brew formula** → under `packages.shared.brews.formulae`
   - **shared + brew cask** → under `packages.shared.brews.casks`
   - **shared + npm** → under `packages.shared.npm`
   - **profile + brew formula** → under `packages.profiles.<profile>.brews.formulae`
   - **profile + brew cask** → under `packages.profiles.<profile>.brews.casks`
   - **profile + brew tap** → add tap under `packages.profiles.<profile>.brews.taps` AND formula under `packages.profiles.<profile>.brews.formulae`
   - **profile + npm** → under `packages.profiles.<profile>.npm`

5. Add the package in alphabetical order within its list. Do not reorder existing entries.

6. After editing, show the user the diff of what changed.
