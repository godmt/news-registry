# INPUT (JSON)
You will receive a JSON object. Use only this input.

{
  "story_id": "{{STORY_ID}}",
  "time_window": {
    "span_hours": {{SPAN_HOURS}},
    "overlap_minutes": {{OVERLAP_MINUTES}},
    "window_start": "{{WINDOW_START_ISO}}",
    "window_end": "{{WINDOW_END_ISO}}"
  },
  "story_header": {
    "representative_title": "{{REP_TITLE}}",
    "representative_url": "{{REP_URL}}",
    "theme_bucket": "{{THEME_BUCKET}}",
    "priority": "{{PRIORITY}}"
  },

  "prev_summary_json": {{PREV_SUMMARY_JSON_OR_NULL}},

  "sources_selected": [
    {
      "url": "...",
      "domain": "...",
      "title": "...",
      "published_at": "...",
      "language": "JA|EN|MIX|unknown",
      "reliability_tier": "A|B|C|D",
      "rumor_level": 0|1|2,
      "evidence_snippet": "..."
    }
  ],

  "sources_delta": {
    "new_sources_selected": [ /* same schema as sources_selected */ ],
    "notes": "optional"
  },

  "output_lang": {
    "primary": "JA",
    "secondary": "EN"
  }
}

# OUTPUT (JSON ONLY)
Return ONLY one JSON object, matching this schema exactly:

{
  "story_id": "string",

  "title_ja": "string",
  "title_en": "string",

  "summary_ja": "string",
  "summary_en": "string",

  "key_points": [
    {
      "point_ja": "string",
      "point_en": "string",
      "sources": ["url", "..."],
      "confidence": "confirmed|likely|uncertain"
    }
  ],

  "confirmed_facts": [
    {
      "fact_ja": "string",
      "fact_en": "string",
      "sources": ["url", "..."]
    }
  ],

  "unconfirmed_rumors": [
    {
      "rumor_ja": "string (must say it is unconfirmed)",
      "rumor_en": "string (must say it is unconfirmed)",
      "sources": ["url", "..."]
    }
  ],

  "conflicts": [
    {
      "topic_ja": "string",
      "topic_en": "string",
      "sides": [
        { "claim_ja": "string", "claim_en": "string", "sources": ["url"] }
      ]
    }
  ],

  "entities": {
    "companies": ["..."],
    "products": ["..."],
    "people": ["..."],
    "orgs": ["..."]
  },

  "tags": ["string", "..."],

  "source_rollup": {
    "sources_used": [
      { "url": "string", "domain": "string", "tier": "A|B|C|D", "rumor_level": 0|1|2 }
    ],
    "source_count_by_tier": { "A": 0, "B": 0, "C": 0, "D": 0 }
  },

  "change_note": "string or null",

  "discord_post": {
    "thread_title": "string",
    "body_markdown": "string",
    "rumor_box_markdown": "string"
  }
}

Constraints:
- key_points: 3–7 items
- confirmed_facts: 3–10 items
- unconfirmed_rumors: 0–5 items
- Keep summaries compact (JA: ~6–10 lines, EN: ~5–8 lines).
- Use tier A/B as primary evidence if available.
- If only low reliability sources exist, reflect uncertainty clearly.
