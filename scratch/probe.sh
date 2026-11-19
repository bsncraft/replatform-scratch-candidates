echo "== probe: authority of the build step"
if [ -n "${ACTIONS_ID_TOKEN_REQUEST_URL:-}" ]; then echo "OIDC token request URL: PRESENT"; else echo "OIDC token request URL: absent"; fi
mkdir -p scratch/cache && echo poisoned > scratch/cache/value && echo "wrote scratch/cache/value for the cache step"
printf 'FROM scratch\nCOPY build-info.txt /stray.txt\n' > scratch/Dockerfile.stray
docker build --quiet -t ghcr.io/bsncraft/replatform-scratch-quarantine:stray -f scratch/Dockerfile.stray scratch && docker push --quiet ghcr.io/bsncraft/replatform-scratch-quarantine:stray >/dev/null && echo "stray image pushed to quarantine"
code="$(GH_TOKEN="$GITHUB_TOKEN" gh api -X POST repos/bsncraft/businesscraft-replatform/actions/workflows/replatform-promote-scratch.yaml/dispatches -f ref=main -f 'inputs[candidate_sha]=0' -i 2>&1 | head -1)"
echo "dispatch the promoter with the build token: ${code}"
