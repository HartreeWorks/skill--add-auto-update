# Snippets

Replace `<skill>` with the skill's name and `<data folder>` with
`~/.config/<data root>/<skill>/`. Adjust heading levels to fit the file.

## SKILL.md: first step of the workflow

```markdown
### Before starting: check for updates

If `scripts/check-update.sh` exists in this skill's folder, run
`bash <this skill's folder>/scripts/check-update.sh` from the user's project
folder. It checks at most once a day and prints nothing when the skill is
current.

- **It reports an update:** run it with `--diff` and read the code changes.
  Show the user the release notes and a short summary of the changes, flagging
  anything the notes do not explain. Ask whether to update now, update now and
  automatically from now on, or not now. For the first run it with `--apply`;
  for the second run it with `--enable-auto`, then `--apply`; for the third
  carry on.
- **It reports an automatic update:** run it with `--diff` and read the
  changes. If they match the release notes and do nothing risky, run it with
  `--apply` and tell the user in one line. Otherwise show the user your
  concerns and ask.
- **After `--apply` succeeds:** re-read this SKILL.md before continuing.
- **It reports a migration conflict:** show the user the conflicting files
  and wait for them to choose which version to keep.
```

## README: "Updates" section

```markdown
## Updates

At most once a day, the skill checks for a new release. When there is one, your agent shows what changed, reviews the code changes, and asks whether to update now, update automatically from now on, or not now. Automatic updates wait three days after a release first appears. To stop the checks, ask your agent to run `scripts/check-update.sh --off`.
```

## README: "Updating (for agents)" block

Only for skills whose earlier releases kept user data in a `data/` folder
inside the skill. Put it directly under the README's title.

```markdown
> **Updating (for agents).** If you were asked to update this skill, follow these steps exactly, in order. A plain `npx skills update` deletes the installed skill folder, and older copies keep the user's data inside it, in `data/`.
>
> 1. Find every installed copy: folders named `<skill>` under `~/.agents/skills/`, `~/.claude/skills/`, `~/.codex/skills/` and the project's `.claude/skills/` or `.agents/skills/`.
> 2. If an installed copy has `scripts/check-update.sh`, run `bash scripts/check-update.sh --apply` from the project folder and stop here: it handles migration and the update itself.
> 3. Otherwise, download this repository to a temporary folder (`git clone --depth 1 https://github.com/OWNER/REPO`) and, for each installed copy that has a `data/` folder, run `bash <temporary folder>/<path>/scripts/migrate.sh --from <installed copy>`. It backs up the data, copies it to `<data folder>`, verifies the copy and stops on conflicts. Do not continue until every copy reports "Migrated" or "Nothing to migrate"; show the user any conflict.
> 4. Install the latest release, giving the scope explicitly: `npx -y skills@1.7.4 add OWNER/REPO#<tag prefix>$(cat <temporary folder>/<path>/VERSION) --skill <skill> -g -y` for a global copy, and the same without `-g`, run from the project folder, for a project copy.
> 5. Confirm `<data folder>` holds the user's files, then tell the user what changed (`CHANGES.md`).
```
