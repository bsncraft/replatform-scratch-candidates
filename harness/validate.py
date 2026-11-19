import hashlib
import json
import os
import pathlib
import re
import subprocess
import sys

candidate_dir = pathlib.Path(sys.argv[1])
candidate = os.environ["CANDIDATE_SHA"]
image_digest = os.environ["IMAGE_DIGEST"]
quarantine = "ghcr.io/bsncraft/replatform-scratch-quarantine"
SAFE = ["-c", "core.hooksPath=/dev/null", "-c", "protocol.ext.allow=never"]


def git(*args):
    return subprocess.run(["git", *SAFE, "-C", str(candidate_dir), *args], capture_output=True, text=True, check=True).stdout.strip()


errors = []
if not re.fullmatch(r"sha256:[0-9a-f]{64}", image_digest):
    errors.append("the build reported a malformed image digest")
else:
    probe = subprocess.run(["docker", "buildx", "imagetools", "inspect", f"{quarantine}@{image_digest}"], capture_output=True, text=True)
    if probe.returncode != 0:
        errors.append("the reported image does not exist in quarantine")
for path in sorted((candidate_dir / "changes").glob("*.json")):
    try:
        change = json.loads(path.read_text())
    except json.JSONDecodeError as error:
        errors.append(f"{path.name}: not valid JSON ({error})")
        continue
    if isinstance(change, dict) and change.get("fails"):
        errors.append(f"{path.name}: seeded failure")
if git("rev-parse", "HEAD") != candidate:
    errors.append("the checked-out commit is not the candidate")
base = git("merge-base", candidate, "refs/remotes/origin/main")
listing = subprocess.run(["git", *SAFE, "-C", str(candidate_dir), "ls-tree", "-r", "--full-tree", candidate], capture_output=True, check=True).stdout
result = {
    "candidate_sha": candidate,
    "base_sha": base,
    "result": "fail" if errors else "pass",
    "digest": "sha256:" + hashlib.sha256(listing).hexdigest(),
    "image_digest": image_digest,
}
pathlib.Path("predicate.json").write_text(json.dumps(result, indent=2) + "\n")
print(json.dumps({**result, "errors": errors}))
with open(os.environ["GITHUB_OUTPUT"], "a") as handle:
    handle.write(f"result={result['result']}\n")
