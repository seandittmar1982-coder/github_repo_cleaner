# github_repo_cleaner

A bash script that helps you review and manage your GitHub repositories one by one. For each repo, you can keep it, delete it, archive it, or view its README before deciding.

## Features

- 📋 Browse all your GitHub repositories with fuzzy search
- 📖 View repository metadata (language, stars, last push, size, etc.)
- 📄 Automatically display each repo's README during review
- ⚡ Quick actions: Keep, Delete, Archive, or View README
- 💾 Track when you last reviewed each repository

## Prerequisites

Before running this script, ensure you have:

1. **GitHub Token** - Set the `GITHUB_TOKEN` environment variable:
   ```bash
   export GITHUB_TOKEN="your_github_token_here"
   ```
   
   Generate a token at: https://github.com/settings/tokens
   - Requires `repo` scope for full access
   - Requires `delete_repo` scope if you plan to delete repositories

2. **Required Commands**:
   - `curl` - For API requests
   - `bat` - For syntax-highlighted README display
   - `jq` - For JSON parsing
   - `fzf` - For fuzzy search selection

   Install on macOS:
   ```bash
   brew install curl bat jq fzf
   ```

   Install on Ubuntu/Debian:
   ```bash
   sudo apt-get install curl bat jq fzf
   ```

   Install on Fedora:
   ```bash
   sudo dnf install curl bat jq fzf
   ```

## Usage

1. Set your GitHub token:
   ```bash
   export GITHUB_TOKEN="ghp_your_token_here"
   ```

2. Run the script:
   ```bash
   ./github_repo_cleaner.sh
   ```

3. Use fuzzy search to select a repository
4. Review the repository information and README
5. Choose an action:
   - `k` - Keep (marks as reviewed)
   - `d` - Delete (⚠️ no confirmation)
   - `a` - Archive
   - `r` - View README
   - `q` - Quit

## State File

The script tracks review history in `~/.github_repo_cleaner_state`. This allows you to see when you last reviewed each repository.

## Safety Notes

⚠️ **Warning**: The delete action (`d`) has no confirmation step. Double-check before confirming the action.

## License

MIT
