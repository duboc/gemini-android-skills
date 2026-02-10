# Gemini CLI Android Skills

A collection of Agent Skills for [Gemini CLI](https://github.com/google-gemini/gemini-cli) focused on Android development.

## Available Skills

| Skill | Description |
|-------|-------------|
| [android-dev](./gemini-android-skill/) | Comprehensive Android development skill with ADB, Gradle, emulator management, and SDK toolchain integration |

## Installation

### Link all skills from this repo

```bash
# Clone the repository
git clone https://github.com/your-username/gemini-android-skills.git

# Link all skills to user scope (~/.gemini/skills/)
gemini skills link /path/to/gemini-android-skills

# Or link to workspace scope (.gemini/skills/)
gemini skills link /path/to/gemini-android-skills --scope workspace
```

### Install a specific skill

```bash
# Install from the repo subdirectory
gemini skills install https://github.com/your-username/gemini-android-skills.git --path gemini-android-skill

# Or from local clone
gemini skills install /path/to/gemini-android-skills/gemini-android-skill
```

## Managing Skills

```bash
# List all discovered skills
gemini skills list

# Enable/disable a skill
gemini skills enable android-dev
gemini skills disable android-dev

# In an interactive session
/skills list
/skills enable android-dev
```

## What Are Agent Skills?

Agent Skills extend Gemini CLI with specialized expertise, procedural workflows, and task-specific resources. Unlike general context files (`GEMINI.md`), skills represent on-demand expertise that activates only when relevant.

**Key benefits:**
- **Progressive disclosure**: Only skill metadata loads initially; full instructions load on activation
- **Resource bundling**: Scripts, templates, and references packaged together
- **Repeatable workflows**: Consistent execution of complex multi-step tasks

## Repository Structure

```
gemini-android-skills/
├── README.md                    # This file
├── LICENSE
└── gemini-android-skill/        # Android development skill
    ├── SKILL.md                 # Skill entry point
    ├── README.md                # Skill documentation
    ├── setup.sh                 # Optional setup script
    ├── assets/
    │   └── GEMINI.md           # Project template
    ├── references/              # Command references
    │   ├── adb-commands.md
    │   ├── gradle-commands.md
    │   ├── emulator-sdk.md
    │   ├── studio-cli.md
    │   └── testing.md
    └── scripts/                 # Helper scripts
        ├── check_env.sh
        └── scaffold_project.sh
```

## Requirements

- [Gemini CLI](https://github.com/google-gemini/gemini-cli)
- Android SDK
- Java 17+

## License

MIT
