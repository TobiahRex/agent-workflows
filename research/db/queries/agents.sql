-- name: CreateAgent :one
INSERT INTO agents (
    rank,
    boss_agent_id,
    agent_type,
    process_id,
    title,
    job_desc,
    background_desc,
    reactivity_bias,
    perspective_bias,
    collaboration_bias,
    poignancy_score,
    reward_score,
    status
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
RETURNING *;

-- name: RemoveAgentById :one
DELETE FROM agents
WHERE id = $1
RETURNING *;

-- name: GetAgentById :one
SELECT *
FROM agents
WHERE id = $1;

-- name: GetAgents :many
SELECT * FROM agents
ORDER BY created_at DESC;

-- name: UpdateAgentStatus :one
UPDATE agents
SET status = $2
WHERE id = $1
RETURNING *;

-- name: UpdateAgentScores :one
UPDATE agents
SET
    poignancy_score = $2,
    reward_score = $3
WHERE id = $1
RETURNING *;

