P=ghcr.io/bsncraft/replatform-scratch-promoted
Q=ghcr.io/bsncraft/replatform-scratch-quarantine
echo "== push new tag to promoted"
docker tag "${Q}:cand-${GITHUB_SHA}" "${P}:direct-${GITHUB_SHA}" && docker push "${P}:direct-${GITHUB_SHA}" 2>&1 | tail -3
echo "== overwrite existing promoted tag"
docker tag "${Q}:cand-${GITHUB_SHA}" "${P}:src-5ca0a5d3ef8edd3f9c44c4714839e651c8ff8a49" && docker push "${P}:src-5ca0a5d3ef8edd3f9c44c4714839e651c8ff8a49" 2>&1 | tail -3
echo "== delete promoted version via API"
curl -s -o /dev/null -w "%{http_code}\n" -X DELETE -H "Authorization: Bearer ${GITHUB_TOKEN:-none}" https://api.github.com/orgs/bsncraft/packages/container/replatform-scratch-promoted/versions/1594851591
