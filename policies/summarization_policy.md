# Summarization Policy

- Summarize per STORY (merged topic), not per RAW item.
- Prefer tier A/B sources as backbone.
- If tag=rumor is present, keep rumors in an isolated section.

## When to run LLM
Run when:
- A/B source added, always.
- Otherwise, when story_digest_hash changes AND (new sources >= 2 OR new D-tier source count >= 1).

## Delta update
If prev summary exists:
- Update minimally using previous summary + newly added selected sources.
