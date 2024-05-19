-- name: CreateAgent :one
INSERT INTO agents (
    title,
    description,
    logo_asset_path,
    url,
    email,
    phone,
    address
) VALUES ($1, $2, $3, $4, $5, $6, $7)

RETURNING *;