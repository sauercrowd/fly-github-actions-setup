#!/bin/bash

# Function to display error messages
error() {
    echo "Error: $1"
    exit 1
}

# 1. Check if the script is in a git repository or a subpath
git_root=$(git rev-parse --show-toplevel 2>/dev/null) || error "Not in a git repository"
cd "$git_root" || error "Failed to change to the root of the git repository"

# 2. Generate if not exists the path `.github/workflows`
mkdir -p .github/workflows || error "Failed to create .github/workflows directory"

# 3. get fly token
FLY_TOKEN=$(fly tokens create deploy -x 999999h) || error "Failed to create fly token"

# 4. Create a GitHub action secret
if command -v gh &>/dev/null; then
  gh secret set FLY_API_TOKEN -b"$FLY_TOKEN" || error "Failed to create GitHub action secret"
else
    # Print the secret to stdout
    echo "Please set the actions secret FLY_API_TOKEN to the following"
    echo "$FLY_TOKEN"
fi

# 5. Create the file .github/workflows/fly.yml
workflow_file=".github/workflows/fly.yml"

if [ -e "$workflow_file" ]; then
    error "$workflow_file already exists"
else

cat > $workflow_file <<- EOF
name: Fly Deploy
on:
  push:
    branches:
      - $(git branch --show-current)
jobs:
  deploy:
    name: Deploy app
    runs-on: ubuntu-latest
    concurrency: deploy-group    # optional: ensure only one action runs at a time
    steps:
      - uses: actions/checkout@v4
      - uses: superfly/flyctl-actions/setup-flyctl@master
      - run: flyctl deploy --remote-only
        env:
          FLY_API_TOKEN: \${{ secrets.FLY_API_TOKEN }}
EOF

fi

echo "github actions setup successfully"

