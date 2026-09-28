# Development quick start

You need stable Rust, Node.js 24+, Docker Compose, `just`, and `tmux`.

1. Run `just setup`. It checks for dependencies, starts PostgreSQL, and
   migrates the database. It creates `planet.yaml` if missing and never
   overwrites it.
2. [Register an LFS API app](https://www.lfs.net/account/api)

- Set its callback URL to `http://localhost:5173/auth/lfs/callback`
- Turn off **Single page app**
- Replace both `REPLACE_ME` values in `planet.yaml` with the client ID and secret from
  LFS.net.

3. Run `just seed` to seed the database with vehicles, tracks and mods.
4. Run `just dev` (or `just serve`)
5. Open <http://localhost:5173>

`just dev` opens tmux panes for PostgreSQL, Vite, and the API. To restart the
API automatically after Rust changes, install Bacon with
`cargo install --locked bacon` and run `just dev --watch` (or `just dev -w`).
Stop the tmux session before switching between watched and regular mode.
Detach with `Ctrl-b`, then `d`; reattach with `just dev`.
Stop the app with `tmux kill-session -t lfs-planet`; stop PostgreSQL with
`docker compose stop postgres`.

Run `just migrate` after a schema change. Run `just seed` to refresh the
catalogue and eras. PostgreSQL data persists between runs; remove it with
`docker compose down --volumes`.

Having a local copy of LFS for validation is not required.
For ranking work without the replay validator, use **Force validate** under
**Account > Hotlaps**. It accepts the upload without checking the replay.
See [replay validation](validator.md) to run the real validator.

Generate track outlines with `just track-gen ~/LFS/data/pth/*.pth`. See the
[track generator guide](../crates/lfsplanet_track_gen/README.md).

See [configuration](configuration.md) for config details and
[contributing](../CONTRIBUTING.md) for checks.

## Troubleshooting

- **Port in use:** free port `5173`, `8000`, or `5432`.
- **Login fails:** check the OAuth credentials and callback URL in `planet.yaml`.
- **Frontend dependencies changed:** run `tmux kill-session -t lfs-planet`, then
  `just dev`.
