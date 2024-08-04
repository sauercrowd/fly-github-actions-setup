# fly-github-actions-setup

A script that automatically create's a github action to deploy the current repo to fly.io

1. Create's a deploy token from fly.io
2. Create's a github secret containing it (if gh cli available, otherwise will print it)
3. create a .github/workflows/fly.yml file containing the workflow, triggering based on the current branch

## Usage

```
curl https://raw.githubusercontent.com/sauercrowd/fly-github-actions-setup/main/setup.sh | bash -
```
