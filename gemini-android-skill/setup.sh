#!/bin/bash

# Gemini Android Skills Setup Script
# This script installs the Gemini CLI Android development skill

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Print banner
print_banner() {
    echo -e "${BLUE}"
    echo "=============================================================="
    echo "          Gemini Android Skills Setup                         "
    echo "          Android Development Agent Skill                     "
    echo "=============================================================="
    echo -e "${NC}"
}

# Print usage
usage() {
    echo "Usage: $0 [target-project-path] [options]"
    echo ""
    echo "Options:"
    echo "  -i, --interactive    Interactive mode (prompt for customization)"
    echo "  -f, --force          Overwrite existing files without prompting"
    echo "  -n, --no-backup      Don't create backups of existing files"
    echo "  -s, --skill-only     Only install the skill (skip project assets)"
    echo "  --scope <scope>      Install scope: 'user' (default) or 'workspace'"
    echo "  -h, --help           Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                                      # Install skill to user scope"
    echo "  $0 /path/to/my-android-project          # Install + configure project"
    echo "  $0 /path/to/project --interactive"
    echo "  $0 --skill-only --scope workspace       # Install to workspace"
    exit 1
}

# Validate target directory
validate_target() {
    local target="$1"

    if [ -z "$target" ]; then
        echo -e "${RED}Error: Target project path is required${NC}"
        usage
    fi

    if [ ! -d "$target" ]; then
        echo -e "${YELLOW}Target directory does not exist. Create it? (y/n)${NC}"
        read -r create_dir
        if [ "$create_dir" = "y" ] || [ "$create_dir" = "Y" ]; then
            mkdir -p "$target"
            echo -e "${GREEN}Created directory: $target${NC}"
        else
            echo -e "${RED}Aborted.${NC}"
            exit 1
        fi
    fi
}

# Backup existing file
backup_file() {
    local file="$1"
    local no_backup="$2"

    if [ -f "$file" ] && [ "$no_backup" != "true" ]; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$file" "$backup"
        echo -e "${YELLOW}Backed up: $file -> $backup${NC}"
    fi
}

# Get the skills directory based on scope
get_skills_dir() {
    local scope="$1"
    local target="$2"

    if [ "$scope" = "workspace" ] && [ -n "$target" ]; then
        echo "$target/.gemini/skills"
    else
        echo "${HOME}/.gemini/skills"
    fi
}

# Copy skill files to Gemini CLI skills directory
install_skill() {
    local scope="$1"
    local target="$2"
    local skills_dir
    skills_dir=$(get_skills_dir "$scope" "$target")

    echo -e "${BLUE}Installing skill to Gemini CLI ($scope scope)...${NC}"

    mkdir -p "$skills_dir/android-dev"

    # Copy the skill files
    cp "$SCRIPT_DIR/SKILL.md" "$skills_dir/android-dev/"
    cp -r "$SCRIPT_DIR/references" "$skills_dir/android-dev/"
    cp -r "$SCRIPT_DIR/scripts" "$skills_dir/android-dev/"

    # Make scripts executable
    chmod +x "$skills_dir/android-dev/scripts/"*.sh 2>/dev/null || true

    echo -e "${GREEN}Skill installed to: $skills_dir/android-dev${NC}"
}

# Copy GEMINI.md to target project
copy_gemini_md() {
    local target="$1"
    local force="$2"
    local no_backup="$3"

    echo -e "${BLUE}Copying GEMINI.md to project...${NC}"

    # Copy GEMINI.md
    if [ -f "$target/GEMINI.md" ] && [ "$force" != "true" ]; then
        echo -e "${YELLOW}Warning: GEMINI.md already exists. Overwrite? (y/n)${NC}"
        read -r overwrite
        if [ "$overwrite" = "y" ] || [ "$overwrite" = "Y" ]; then
            backup_file "$target/GEMINI.md" "$no_backup"
            cp "$SCRIPT_DIR/assets/GEMINI.md" "$target/"
            echo -e "${GREEN}Copied GEMINI.md${NC}"
        fi
    else
        cp "$SCRIPT_DIR/assets/GEMINI.md" "$target/"
        echo -e "${GREEN}Copied GEMINI.md${NC}"
    fi
}

# Update .gitignore
update_gitignore() {
    local target="$1"
    local gitignore="$target/.gitignore"

    echo -e "${BLUE}Updating .gitignore...${NC}"

    local entries=(
        ""
        "# Gemini CLI"
        ".gemini/"
    )

    if [ -f "$gitignore" ]; then
        # Check if Gemini CLI section already exists
        if ! grep -q "# Gemini CLI" "$gitignore"; then
            printf '%s\n' "${entries[@]}" >> "$gitignore"
            echo -e "${GREEN}Added Gemini CLI entries to .gitignore${NC}"
        else
            echo -e "${YELLOW}.gitignore already has Gemini CLI entries${NC}"
        fi
    else
        printf '%s\n' "${entries[@]}" > "$gitignore"
        echo -e "${GREEN}Created .gitignore with Gemini CLI entries${NC}"
    fi
}

# Interactive customization
interactive_setup() {
    local target="$1"

    echo -e "${BLUE}Interactive Setup${NC}"
    echo ""

    # Get project name
    echo "Enter your project name (e.g., MyAndroidApp):"
    read -r project_name

    if [ -n "$project_name" ]; then
        # Update GEMINI.md
        if [ -f "$target/GEMINI.md" ]; then
            if [[ "$OSTYPE" == "darwin"* ]]; then
                sed -i '' "s/\[Your App Name\]/$project_name/g" "$target/GEMINI.md"
            else
                sed -i "s/\[Your App Name\]/$project_name/g" "$target/GEMINI.md"
            fi
        fi
        echo -e "${GREEN}Updated project name to: $project_name${NC}"
    fi

    # Get package name
    echo ""
    echo "Enter your package name (e.g., com.example.myapp):"
    read -r package_name

    if [ -n "$package_name" ]; then
        if [ -f "$target/GEMINI.md" ]; then
            if [[ "$OSTYPE" == "darwin"* ]]; then
                sed -i '' "s/com\.example\.app/$package_name/g" "$target/GEMINI.md"
            else
                sed -i "s/com\.example\.app/$package_name/g" "$target/GEMINI.md"
            fi
        fi
        echo -e "${GREEN}Updated package name to: $package_name${NC}"
    fi

    # Get min SDK
    echo ""
    echo "Minimum SDK version (default: 24):"
    read -r min_sdk
    min_sdk=${min_sdk:-24}

    if [ -f "$target/GEMINI.md" ]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s/Min SDK: 24/Min SDK: $min_sdk/g" "$target/GEMINI.md"
        else
            sed -i "s/Min SDK: 24/Min SDK: $min_sdk/g" "$target/GEMINI.md"
        fi
    fi

    echo -e "${GREEN}Set minimum SDK to: $min_sdk${NC}"
}

# Run environment check
run_env_check() {
    local skills_dir="$1"

    echo ""
    echo -e "${BLUE}Running environment check...${NC}"
    echo ""

    if [ -f "$skills_dir/android-dev/scripts/check_env.sh" ]; then
        bash "$skills_dir/android-dev/scripts/check_env.sh" || true
    elif [ -f "$SCRIPT_DIR/scripts/check_env.sh" ]; then
        bash "$SCRIPT_DIR/scripts/check_env.sh" || true
    fi
}

# Print summary
print_summary() {
    local target="$1"
    local skill_only="$2"
    local skills_dir="$3"

    echo ""
    echo -e "${GREEN}==============================================================${NC}"
    echo -e "${GREEN}                    Setup Complete!                           ${NC}"
    echo -e "${GREEN}==============================================================${NC}"
    echo ""

    echo -e "Skill installed to: ${BLUE}$skills_dir/android-dev${NC}"
    echo ""
    echo "Skill structure:"
    echo "  android-dev/"
    echo "  |- SKILL.md                     (main entry point)"
    echo "  |- references/"
    echo "  |  |- adb-commands.md           (200+ ADB commands)"
    echo "  |  |- gradle-commands.md        (build, test, signing)"
    echo "  |  |- emulator-sdk.md           (AVD management)"
    echo "  |  |- studio-cli.md             (Android Studio CLI)"
    echo "  |  +- testing.md                (unit, UI, instrumented)"
    echo "  +- scripts/"
    echo "     |- check_env.sh              (environment validator)"
    echo "     +- scaffold_project.sh       (project scaffolder)"
    echo ""

    if [ "$skill_only" != "true" ] && [ -n "$target" ]; then
        echo -e "Project configured: ${BLUE}$target${NC}"
        echo ""
        echo "Project files:"
        echo "  +- GEMINI.md                  (project instructions)"
        echo ""
    fi

    echo -e "${YELLOW}Next steps:${NC}"
    if [ "$skill_only" != "true" ] && [ -n "$target" ]; then
        echo "  1. cd $target"
        echo "  2. Edit GEMINI.md with your project details"
        echo "  3. Run 'gemini' to start your Gemini CLI session"
    else
        echo "  1. Run this script with a target project: $0 /path/to/project"
        echo "  2. Or use the skill directly in any Android project"
    fi
    echo ""
    echo -e "${BLUE}Skill activation:${NC}"
    echo "  Gemini CLI will automatically detect and use the android-dev skill"
    echo "  when you work on Android projects. The skill activates when you mention:"
    echo "  - Android development, ADB, Gradle, emulator"
    echo "  - APK building, testing, debugging"
    echo "  - React Native/Flutter Android targets"
    echo ""
    echo -e "${BLUE}Management commands:${NC}"
    echo "  gemini skills list              # List all skills"
    echo "  gemini skills enable android-dev"
    echo "  gemini skills disable android-dev"
    echo "  /skills list                    # In interactive session"
    echo ""
}

# Main
main() {
    local target=""
    local interactive=false
    local force=false
    local no_backup=false
    local skill_only=false
    local scope="user"

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -i|--interactive)
                interactive=true
                shift
                ;;
            -f|--force)
                force=true
                shift
                ;;
            -n|--no-backup)
                no_backup=true
                shift
                ;;
            -s|--skill-only)
                skill_only=true
                shift
                ;;
            --scope)
                scope="$2"
                shift 2
                ;;
            -h|--help)
                usage
                ;;
            *)
                if [ -z "$target" ]; then
                    target="$1"
                else
                    echo -e "${RED}Error: Unexpected argument: $1${NC}"
                    usage
                fi
                shift
                ;;
        esac
    done

    print_banner

    local skills_dir
    skills_dir=$(get_skills_dir "$scope" "$target")

    # Install the skill
    install_skill "$scope" "$target"

    # If not skill-only, also set up the target project
    if [ "$skill_only" != "true" ]; then
        if [ -z "$target" ]; then
            echo -e "${YELLOW}No target project specified. Skill installed globally.${NC}"
            echo "To set up a project, run: $0 /path/to/your/android-project"
            echo ""
            run_env_check "$skills_dir"
            print_summary "" "true" "$skills_dir"
            exit 0
        fi

        validate_target "$target"

        # Convert to absolute path
        target="$(cd "$target" && pwd)"

        copy_gemini_md "$target" "$force" "$no_backup"
        update_gitignore "$target"

        if [ "$interactive" = true ]; then
            interactive_setup "$target"
        fi
    fi

    run_env_check "$skills_dir"
    print_summary "$target" "$skill_only" "$skills_dir"
}

main "$@"
