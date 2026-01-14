SELECT q_id, kind, story_id
FROM work_queue
WHERE status='pending'
  AND (not_before IS NULL OR not_before <= ?)
  AND kind = 'llm'
ORDER BY priority ASC, updated_at ASC
LIMIT 20;
