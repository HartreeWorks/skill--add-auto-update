---
name: add-auto-update
description: Add update checks to skills published on GitHub, so people who installed them with `npx skills` are offered each new release, see its code changes before installing, and keep their own data across updates. Use when asked to add auto-update or update checks to a skill, a selection of skills or every skill in a repository, or to release a new version of a skill that has them.
---

# Add auto-update

Adds a small update checker to skills you publish. Once a skill has it, the
skill checks GitHub at most once a day when it runs. When there is a new
release, the user's agent shows the release notes and the code changes, then
asks whether to update now, update automatically from now on, or not now.

Paths below starting `scripts/`, `templates/` or `references/` are in this
skill's folder.

## Before starting: check for updates

This skill checks for its own updates in the way it sets up for others. If
`scripts/check-update.sh` exists, run it and follow the "SKILL.md: first step
of the workflow" snippet in `references/snippets.md`.

## Requirements

- Each skill is in a public GitHub repository, at the root or in a subfolder,
  and people install it with `npx skills add OWNER/REPO`.
- The skill's users run macOS or Linux, with bash, curl and Node.js.

## Add update checks

Work out which skills to change. If the user named skills, use those. For
"all my skills", list the folders containing a `SKILL.md` in the repository
and confirm the list with the user before changing anything.

For each skill:

1. **Find its repository and path.** `git -C <skill> remote get-url origin`
   gives `OWNER/REPO`, and `git -C <skill> rev-parse --show-prefix` gives the
   skill's path in the repository (empty at the root). Confirm the repository
   is public: `curl -fsI https://raw.githubusercontent.com/OWNER/REPO/HEAD/<path>/SKILL.md`.
   Skip a skill that is not in a public GitHub repository, and tell the user why.
2. **Add the scripts.**
   `bash scripts/install.sh <skill> --repo OWNER/REPO [--path <path>]`. This
   writes `check-update.sh`, `migrate.sh` and `data-dir.sh` into the skill's
   `scripts/`. User data goes in `~/.config/<owner>-skills/<skill>/`; pass
   `--data-root` to choose another folder name. Never change the data root
   after the first release, or users lose track of their data.
3. **Move user data out of the skill folder.** The skills installer deletes
   and recreates the skill folder on every update, so anything the skill
   writes inside its own folder would be lost. Read the SKILL.md and scripts
   for files the skill creates or the user edits: preferences, history,
   caches, config. Change each to live in the folder printed by
   `bash scripts/data-dir.sh`. An existing `data/` folder in an installed copy
   is migrated there on first use. If earlier releases kept user files
   anywhere else in the skill folder, ask the user how to carry them over
   before going further. If the skill keeps no user data, skip this step.
4. **Edit the SKILL.md and README.** Add the sections in
   `references/snippets.md`: the update check as the first step of the
   skill's workflow, and the "Updates" section in the README. If earlier
   releases kept user data inside the skill folder, also open the README with
   the "Updating (for agents)" block.
5. **Release.** Follow "Release a new version" below with the note "Checks
   for updates".

## Release a new version

1. Run `bash scripts/release.sh <skill> "<what changed, for users>"`. It
   sets `VERSION` to today's date plus a counter and adds the note to
   `CHANGES.md`.
2. Commit the skill's changes with `VERSION` and `CHANGES.md`, then tag the
   commit with the tag the script printed: `v<VERSION>` for a skill at the
   repository root, `<skill>-v<VERSION>` for one in a subfolder.
3. Pushing publishes the release to every user, so confirm with the user
   first. Push the tag before the branch (`git push origin <tag> && git push`):
   installed copies read `VERSION` from the default branch and install the
   matching tag, which must already exist.

Release for changes users should know about. Commit wording fixes without a
release; they reach users with the next one.

To give users a newer version of the update checker itself, rerun
`scripts/install.sh` with the same arguments and release.

## What protects users

- Updates are offered, not forced. Users choose to update each time
  (the default), update automatically, or turn checks off
  (`check-update.sh --off`).
- Before any install, the agent reads the diff between the installed copy and
  the release (`check-update.sh --diff`) and stops to ask the user about
  anything the release notes do not explain: sending data somewhere new,
  reading credentials, running downloaded code, or skipping the user's
  confirmation.
- Automatic updates wait three days after a machine first sees a release,
  so a broken or malicious release can be withdrawn before it spreads.
- Release notes are shown with control characters stripped, length-capped and
  labelled as the author's description rather than instructions.
- The installer gets the exact release tag with a pinned version of the
  skills CLI, and refuses if the user's lock file says the skill came from a
  different repository.
- Migration backs user data up first, verifies every copy and never
  overwrites a file.

These measures limit damage; they do not remove the need to trust the
author's GitHub account. The diff review is an agent's reading, not an
audit, and each check tells GitHub the user's IP address.
