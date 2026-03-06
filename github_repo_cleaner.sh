#!/usr/bin/env bash

STATE_FILE="$HOME/.github_repo_cleaner_state"
API="https://api.github.com"

if [ -z "$GITHUB_TOKEN" ]; then
    echo "Error: GITHUB_TOKEN is not set."
    echo "Run:"
    echo "export GITHUB_TOKEN=\"your_token_here\""
    exit 1
fi

touch "$STATE_FILE"

api() {
    curl -s \
        -H "Authorization: Bearer $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github+json" \
        "$@"
}

update_last_review() {
    grep -v "^$1|" "$STATE_FILE" > "$STATE_FILE.tmp"
    echo "$1|$(date '+%Y-%m-%d %H:%M:%S')" >> "$STATE_FILE.tmp"
    mv "$STATE_FILE.tmp" "$STATE_FILE"
}

get_last_review() {
    grep "^$1|" "$STATE_FILE" | cut -d'|' -f2
}

detect_type() {
    case "$1" in    
        JavaScript|TypeScript) echo "Node / JS" ;;
        Python) echo "Python" ;;
        Go) echo "Go" ;;
        Rust) echo "Rust" ;;
        Java) echo "Java" ;;
        C) echo "C" ;;
        C++) echo "C++" ;;
        Shell) echo "Shell Script" ;;
        *) echo "Unknown" ;;
    esac
}

while true; do

    REPOS=$(api "$API/user/repos?per_page=100")

    SELECTED=$(echo "$REPOS" | jq -r '.[] |
        "\(.full_name) | \(.language // "Unknown") | ★ \(.stargazers_count)"' \
        | fzf --prompt="Select repo > ")

    [ -z "$SELECTED" ] && exit 0

    FULL_NAME=$(echo "$SELECTED" | cut -d'|' -f1 | xargs)
    LANGUAGE=$(echo "$SELECTED" | cut -d'|' -f2 | xargs)

    clear

    INFO=$(api "$API/repos/$FULL_NAME")

    DESC=$(echo "$INFO" | jq -r '.description // "None"')
    PUSHED=$(echo "$INFO" | jq -r '.pushed_at')
    SIZE=$(echo "$INFO" | jq -r '.size')
    STARS=$(echo "$INFO" | jq -r '.stargazers_count')
    TYPE=$(detect_type "$LANGUAGE")
    LAST_REVIEW=$(get_last_review "$FULL_NAME")

    echo "======================================"
    echo "Repo: $FULL_NAME"
    echo "Type: $TYPE"
    echo "Language: $LANGUAGE"
    echo "Stars: $STARS"
    echo "Description: $DESC"
    echo "Last Push: $PUSHED"
    echo "Size: ${SIZE} KB"
    echo "Last Reviewed: ${LAST_REVIEW:-Never}"
    echo "======================================"
    echo

    README=$(api "$API/repos/$FULL_NAME/readme")
    CONTENT=$(echo "$README" | jq -r '.content // empty')

    if [ -n "$CONTENT" ]; then
        echo "README:"
        echo "------"
        echo "$CONTENT" | base64 -d | batcat --style=plain --color=always
        echo "------"
        echo
    fi

    echo "[k] Keep"
    echo "[d] Delete (NO confirmation)"
    echo "[a] Archive"
    echo "[r] View README"
    echo "[q] Quit"
    echo

    read -n1 -p "Action: " ACTION
    echo

    case "$ACTION" in
        k|K)
            update_last_review "$FULL_NAME"
            ;;
        d|D)
            curl -s -X DELETE \
                -H "Authorization: Bearer $GITHUB_TOKEN" \
                -H "Accept: application/vnd.github+json" \
                "$API/repos/$FULL_NAME"

            echo "Repository deleted."
            sleep 1
            ;;
        a|A)
            curl -s -X PATCH \
                -H "Authorization: Bearer $GITHUB_TOKEN" \
                -H "Accept: application/vnd.github+json" \
                "$API/repos/$FULL_NAME" \
                -d '{"archived": true}'

            echo "Repository archived."
            sleep 1
            ;;
        r|R)

            README=$(api "$API/repos/$FULL_NAME/readme")

            CONTENT=$(echo "$README" | jq -r '.content // empty')

            if [ -z "$CONTENT" ]; then
                echo "No README found."
            else
                echo "$CONTENT" | base64 -d | bat --style=plain --color=always
            fi

            read -p "Press Enter to continue..."
            ;;
        q|Q)
            exit 0
            ;;
    esac

done