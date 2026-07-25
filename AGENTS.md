# AGENTS.md

Guidance for AI coding agents working in this repository.

## What this repo is

A single-route Flask demo app (`api/app.py`, ~10 lines) wrapped in a production-shaped container build and release pipeline. The application code is a placeholder; the substance of the repo is `.github/workflows/` and the image-tagging convention that drives FluxCD deployments. Changes here are almost always CI/CD or packaging changes.

There is no test suite, no linter config, and no dependency lockfile beyond the pinned `requirements.txt`. Don't invent commands for them.

## Commands

```bash
# Run locally (Flask dev server, debug reloader on, port 5000)
pip install -r requirements.txt
python api/app.py

# Build and run the container as CI does
docker build -t app1 .
docker run --rm -p 5000:5000 app1
```

## Release architecture

Images go to `ghcr.io/6j0-org/app1`. Nothing in this repo talks to a cluster — FluxCD watches the registry and deploys based on tag names, so **promotion and rollback are retag operations, never rebuilds**.

Tag format: `{env}-{7-char-git-sha}-{unix-commit-timestamp}`, e.g. `dev-8867672-1770761352`. FluxCD deploys the tag with the highest timestamp for a given env prefix (`dev-`, `prod-`).

The flow across workflows:

- **`docker-build-push.yml`** — on push/PR to `main`. Builds multi-arch (amd64/arm64) with provenance, SBOM, reproducible `SOURCE_DATE_EPOCH`, and a registry buildcache. Emits the `dev-{sha}-{ts}` tag alongside the docker/metadata-action tags. PRs build but do not push (`push: ${{ github.event_name != 'pull_request' }}`).
- **`promote-to-prod.yml`** — `workflow_dispatch`. Queries the GHCR packages API, finds the newest `dev-` tag by timestamp, and re-tags it `prod-` via `docker buildx imagetools create`.
- **`deploy-image.yml`** — `workflow_dispatch`. Re-tags a specific image to `test-` or `prod-` by pulling and pushing.
- **`add-tag.yml`** — `workflow_dispatch`. The rollback lever: adds an arbitrary new tag to an existing image. To roll back, tag the known-good SHA with a timestamp *greater* than the bad release's, so Flux sees it as newer.

Consequence: the timestamp component is deployment-ordering data, not decoration. Anything that constructs or rewrites a tag must preserve the `{env}-{sha}-{ts}` shape — the retag workflows all parse it with `sed -E 's/.*-([^-]+)-([^-]+)/.../'`.

## Conventions to preserve

- **All GitHub Actions are pinned to full commit SHAs** with the version in a trailing comment (`# v3.7.0`). Keep this when adding or bumping actions.
- **The base image is pinned by digest**, not tag. Line 1 of the `Dockerfile` records how to refresh it: `docker manifest inspect python:3.14.3 | grep -A 10 '"digest"'`.
- **`docker-build-push.yml` has explicit `paths:` filters** on both `push` and `pull_request`. Adding a new source directory means adding it to both lists, or the image silently stops rebuilding.
- **The Dockerfile flattens `api/app.py` into `/app/app.py`**, and `CMD` is `python app.py`. Adding a second module under `api/` requires changing the `COPY` lines — the current one copies a single file, not the directory.
- Commented-out blocks (Poetry/GitLab build secrets, Trivy scanning, attestation, Docker Hub login) are intentional scaffolding kept for reference. Leave them unless asked.

## Claude workflows

`claude.yml` (tag `@claude` in issues/PRs) and `claude-code-review.yml` (automatic on every PR) are configured with security reasoning written into the comments — read them before editing permissions.

Two constraints that are load-bearing and easy to break:

- In `claude-code-review.yml`, `--allowed-tools` is **required**, not optional. Passing a `prompt` puts the action in agent mode, where the inline-comment MCP server is only registered if the allowlist contains an `mcp__github_inline_comment__` entry. Removing it makes the job run, find issues, and post nothing.
- The `/code-review` plugin is deliberately not used there — it reports via `ReportFindings`, which `claude-code-action` does not consume.

`claude.yml` has `contents: write` (Claude pushes a work branch) but no Bash allowlist, so a human still opens the PR. Raising it to `pull-requests: write` plus a `gh` allowlist would remove that human step.
