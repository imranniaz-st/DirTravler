#!/usr/bin/env bash

# Make sure you're inside a git repo
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "❌ Not inside a Git repository."
    exit 1
fi

branch=$(git rev-parse --abbrev-ref HEAD)
echo "✅ Auto pushing to branch: $branch every 1 minute..."

while true; do
    git add .

    # Only commit if there are staged changes
    if ! git diff --cached --quiet; then
        msg="Auto-commit on $(date '+%Y-%m-%d %H:%M:%S')"
        git commit -m "$msg"
        echo "✅ Committed at $(date '+%H:%M:%S')"
    else
        echo "ℹ️ No changes to commit at $(date '+%H:%M:%S')"
    fi

    git push origin "$branch"
    echo "🚀 Pushed to $branch"

    echo "⏳ Waiting for 60 seconds..."
    sleep 60
done
