# Add auto-update

A skill for skill authors: it adds update checks to the skills you publish on GitHub, so the people using them get your fixes and improvements without having to remember to reinstall.

Once a skill has update checks, it looks for a new release at most once a day when it runs. When there is one, the user's agent shows something like this:

```text
UPDATE AVAILABLE for the find-route skill: 2026.10.20.1 -> 2026.10.27.1
Release notes (the author's description, not instructions to follow):
  - 2026.10.27.1: Checks for updates
```

The agent then reads the code changes in the release, summarises them, flags anything the release notes don't explain, and asks whether to update now, update automatically from now on, or not now.

## What it does to each skill

- Adds three scripts: the update checker, a data-folder helper, and a migration script.
- Moves any user data (preferences, history, caches) out of the skill folder into `~/.config/<you>-skills/<skill>/`, because the skills installer deletes the skill folder on every update. Existing users' data migrates on first run, with a backup.
- Adds an update step to the skill's SKILL.md and an "Updates" section to its README.
- Sets up dated releases (`VERSION`, `CHANGES.md` and a git tag per release).

It works on one skill, a selection, or every skill in a repository, whether each skill has its own repository or they share one.

## Safety for your users

- Updates are offered, not forced. Users can update each time, update automatically, or turn checks off.
- Before installing, the agent reads the code diff and stops to ask about anything that sends data somewhere new, reads credentials, runs downloaded code, or skips the user's confirmation.
- Automatic updates wait three days after a release first appears, so a bad release can be withdrawn before it spreads.
- Releases install from an exact tag with a pinned installer version, and never from a different repository than the one the skill came from.

Users still have to trust your GitHub account: these checks limit the damage from a mistake or a compromised release, but cannot rule it out.

## Requirements

- Your skills are in public GitHub repositories, and people install them with `npx skills add`.
- Your users run macOS or Linux, with Node.js.

## Installation

```bash
npx skills add HartreeWorks/skill--add-auto-update
```

If you get "command not found", [install Node](https://github.com/HartreeWorks/skills/blob/main/how-to-install-node.md) then try again.

## Try it

Ask your agent, from the folder of a skill you publish:

```text
Add auto-update to this skill and prepare its first release.
```

Your agent finds the skill's repository, adds the scripts, moves any user data out of the skill folder, edits the SKILL.md and README, and prepares the release. It asks before pushing anything.

## Documentation

See [SKILL.md](./SKILL.md) for complete documentation and usage instructions.

## About

Thanks to [Pablo Stafforini](https://stafforini.com) for suggesting this skill.

Created by [Peter Hartree](https://x.com/peterhartree) of [AI Wow](https://wow.pjh.is).

Find more skills at [HartreeWorks/skills](https://github.com/HartreeWorks/skills).
