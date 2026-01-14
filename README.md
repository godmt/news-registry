# news-registry

This repo stores configuration for the news aggregation pipeline:
- sources (JSONL)
- prompts (Markdown)
- taxonomy (tags)
- rules/policies/templates

## Edit workflow
1. Add/modify sources in `sources/*.jsonl`
2. Update prompts in `prompts/*`
3. Run local validation:
   - `python scripts/validate_registry.py`
4. Push to main (or PR)

## Notes
- Keep extractor overrides minimal.
- Tags must be chosen from `taxonomy/tags.json`.
