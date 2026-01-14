PRAGMA foreign_keys = ON;

-- メタ
CREATE TABLE IF NOT EXISTS meta (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
);
INSERT OR IGNORE INTO meta(key, value) VALUES ('schema_version', '1');

-- 取得した記事（raw）
CREATE TABLE IF NOT EXISTS raw_items (
  raw_id TEXT PRIMARY KEY,                 -- UUIDなど
  source_key TEXT NOT NULL,                -- sources.jsonlの識別子（例: domain+pathのslug）
  input_url TEXT NOT NULL,
  canonical_url TEXT NOT NULL,

  title TEXT,
  published_at TEXT,                       -- ISO8601
  fetched_at TEXT NOT NULL,                -- ISO8601

  language TEXT,                           -- JA/EN/MIX/unknown
  content_text TEXT,                       -- 抽出本文（最初はここだけでOK）
  content_hash TEXT,                       -- sha256
  simhash INTEGER,                         -- 64-bit相当をINTEGERで保持

  reliability_tier TEXT,                   -- A/B/C/D（ソース由来の初期値でもOK）
  rumor_level INTEGER,                     -- 0/1/2（ソース由来の初期値でもOK）

  http_status INTEGER,
  etag TEXT,
  last_modified TEXT,

  notes TEXT
);

CREATE INDEX IF NOT EXISTS idx_raw_content_hash ON raw_items(content_hash);
CREATE INDEX IF NOT EXISTS idx_raw_simhash ON raw_items(simhash);
CREATE INDEX IF NOT EXISTS idx_raw_source_key ON raw_items(source_key);
CREATE INDEX IF NOT EXISTS idx_raw_fetched_at ON raw_items(fetched_at);

-- 統合後の話題（story）
CREATE TABLE IF NOT EXISTS stories (
  story_id TEXT PRIMARY KEY,               -- UUIDなど
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,

  representative_title TEXT,
  representative_url TEXT,
  language TEXT,

  simhash INTEGER,                         -- 代表simhash（目安）
  reliability_tier TEXT,                   -- 統合後に更新可
  rumor_level INTEGER,                     -- 統合後に更新可

  summary_ja TEXT,
  summary_en TEXT,
  tags_json TEXT,                          -- JSON文字列
  entities_json TEXT,                      -- JSON文字列

  last_llm_at TEXT,
  last_published_at TEXT
);

CREATE INDEX IF NOT EXISTS idx_stories_updated_at ON stories(updated_at);
CREATE INDEX IF NOT EXISTS idx_stories_simhash ON stories(simhash);

-- story と raw の紐付け（ソース複数記録）
CREATE TABLE IF NOT EXISTS story_raw_map (
  story_id TEXT NOT NULL,
  raw_id TEXT NOT NULL,
  added_at TEXT NOT NULL,

  is_primary INTEGER DEFAULT 0,            -- 代表ソース扱い
  PRIMARY KEY (story_id, raw_id),
  FOREIGN KEY (story_id) REFERENCES stories(story_id) ON DELETE CASCADE,
  FOREIGN KEY (raw_id) REFERENCES raw_items(raw_id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_map_raw_id ON story_raw_map(raw_id);

-- キュー（バッファ）
CREATE TABLE IF NOT EXISTS work_queue (
  q_id INTEGER PRIMARY KEY AUTOINCREMENT,
  kind TEXT NOT NULL,                      -- 'llm' | 'publish'
  story_id TEXT NOT NULL,
  priority INTEGER NOT NULL DEFAULT 100,   -- 小さいほど優先
  status TEXT NOT NULL DEFAULT 'pending',  -- pending|in_progress|done|error
  attempts INTEGER NOT NULL DEFAULT 0,
  not_before TEXT,                         -- ISO8601: この時刻以降に処理（リトライ間隔）
  last_error TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,

  UNIQUE(kind, story_id),                  -- 同じstoryを二重投入しない
  FOREIGN KEY (story_id) REFERENCES stories(story_id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_queue_pick
  ON work_queue(status, kind, priority, not_before, updated_at);

-- Discord投稿の記録（フォーラムスレッド）
CREATE TABLE IF NOT EXISTS discord_threads (
  story_id TEXT PRIMARY KEY,
  forum_channel_id TEXT NOT NULL,
  thread_id TEXT NOT NULL,
  first_message_id TEXT,
  posted_at TEXT NOT NULL,
  last_posted_at TEXT NOT NULL,
  FOREIGN KEY (story_id) REFERENCES stories(story_id) ON DELETE CASCADE
);
