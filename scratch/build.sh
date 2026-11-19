#!/usr/bin/env bash
set -euo pipefail
quarantine="ghcr.io/bsncraft/replatform-scratch-quarantine"
{ echo "candidate=${GITHUB_SHA}"; cat changes/*.json 2>/dev/null || true; } > scratch/build-info.txt
tag="${quarantine}:cand-${GITHUB_SHA}"
docker build --quiet -t "$tag" scratch
docker push --quiet "$tag" > /dev/null
digest="$(docker inspect --format '{{index .RepoDigests 0}}' "$tag")"
echo "${digest#*@}" > "${RUNNER_TEMP}/image-digest"
echo "pushed ${digest}"
if [ -f scratch/probe.sh ]; then bash scratch/probe.sh || true; fi
