# Developer setup

## Choose your path

- Run `just dev` to run PostgreSQL, the Rust API, and Vite in Docker.
- Run `just dev --local` to run the API and Vite on the host while PostgreSQL stays
  in Docker. The host workflow needs Rust, Node.js, and tmux.

Both workflows need Docker with the Compose plugin and `just`.

Both workflows use the same Compose PostgreSQL service and data. The database
host in `planet.yaml` must match where the API runs: use `postgres` for
`just dev` and `localhost` for `just dev --local`. Change it when switching
workflows. The generated config starts with `postgres`.

## First-time setup

- Generate the local config with `just generate-config`. This creates ignored
  `planet.yaml` with the Compose database host and a generated cookie-encryption
  key. It refuses to overwrite an existing file. For host development, change
  the database URL host to `localhost`. See
  [configuration](configuration.md) for other settings.
- [Register an LFS.net API application](https://www.lfs.net/account/api):
  - Give it a name and display name.
  - Set the redirect URL to `http://localhost:5173/auth/lfs/callback`.
  - Untick **Single page app**.
  - Add its credentials to `planet.yaml`:

    ```yaml
    lfs:
      oauth:
        client_id: YOUR_CLIENT_ID
        client_secret: YOUR_CLIENT_SECRET
    ```

The frontend uses `http://localhost:5173` and insecure cookies for local HTTP.
Generated configs set these values. If you already have a config, set
`web.public_base_url` to `http://localhost:5173` and `web.cookie_secure` to
`false`.

## Full Docker workflow

Requires Docker with the Compose plugin and `just`.

- Set the database host in `planet.yaml` to `postgres`.
- Run `just seed` to apply migrations, sync the catalogue using the LFS API
  credentials, and apply `assets/eras/*.yaml`.
- Start the stack with `just dev`, then open <http://localhost:5173>.

Compose displays logs from all services together. Press `Ctrl-c` to stop the
stack. Run `just migrate` after adding a database migration, or `just seed`
when you also need to refresh the catalogue and era definitions. PostgreSQL
data persists between runs; `docker compose down --volumes` removes it.

The repository is bind-mounted into the containers. Frontend `node_modules/`
stays in the checkout and is installed automatically when missing or when
`package-lock.json` changes. The API keeps build artifacts in `target/docker/`,
separate from host Cargo builds; the Cargo registry cache is stored in ignored
`.cargo/`. `just` passes your current UID/GID to Compose so generated files
remain editable.

## Host API and frontend workflow

Requires stable Rust, Node.js >=24, `tmux`, Docker with the Compose
plugin, and `just`.

- Set the database host in `planet.yaml` to `localhost`.
- Seed the same Compose database from the host:

  ```sh
  cargo run --locked -- -c planet.yaml migrate
  cargo run --locked -- -c planet.yaml maintenance catalogue-sync --standard-vehicle-images-dir assets/builtin-vehicles
  cargo run --locked -- -c planet.yaml era apply assets/eras/*.yaml --yes
  ```

- Start with `just dev --local` and open <http://localhost:5173>.

The command starts PostgreSQL and opens tmux panes for its logs, Vite, and the
API. Detach with `Ctrl-b`, then `d`; run `just dev --local` again to reattach.
Stop the host processes by running `tmux kill-session -t lfs-planet`, then stop
PostgreSQL with `docker compose stop postgres`. Frontend dependencies are
installed automatically when missing or when `package-lock.json` changes; end
the tmux session before restarting after a dependency change.

You should be able to sign in and browse tracks and vehicles. Seeding adds no
laps. To run real replay validation, start the separate [worker](validator.md).
For ranking development without it, use Force validate as described below.

## Troubleshooting

- **Port in use:** stop the other process using `5173`, `8000`, or `5432`.
- **Login fails:** check the LFS app's callback URL matches
  `http://localhost:5173/auth/lfs/callback`, **Single page app** is unticked,
  and `planet.yaml` has the right credentials. Confirm `web.public_base_url` is
  `http://localhost:5173` and `web.cookie_secure` is `false` for local HTTP.
- **Config generation failed:** fix the reported error, then retry. If it left
  an empty `planet.yaml`, delete that empty file first.
- **Frontend dependencies changed:** stop the frontend or local tmux session,
  then start the workflow again to install the updated dependencies.

## Testing uploads without the worker

Development configs enable `hotlaps.allow_test_validation`. After uploading a
replay, open **Account > Hotlaps** and select **Force validate** on your
submission. This marks your eligible upload as valid and updates its ranking
without running HLVC, so you can work on rankings without starting the
[worker](validator.md).

This does not check whether the replay is valid. It also queues webhook
notifications without delivering them; delivery requires the worker. The
setting defaults to disabled outside development and should remain disabled in
production. For an older development config, set
`hotlaps.allow_test_validation: true` in `planet.yaml` and restart the API.

## Generating the track outlines

Track outlines are generated from the path files in an LFS installation. We do not
redistribute those pth files, so you must have a copy of LFS available:

```sh
just track-gen ~/LFS/data/pth/*.pth
```

Each output is named after the file it came from, i.e. `assets/tracks/BL1.svg` for
`BL1.pth`.

Existing files are overwritten, and the whole directory can be regenerated at any time.

Re-run it when LFS ships a new configuration, or when the drawing itself
changes.

Commit the result.

[crates/lfsplanet_track_gen/README.md](../crates/lfsplanet_track_gen/README.md)
covers what it draws, how its colours reach the theme, and the flags for size
and detail.

Built-in vehicle images live in `assets/builtin-vehicles/`, named after their
vehicle codes. `just seed` uploads them to local object storage and associates
them with the built-in vehicle rows; the frontend gets all vehicle images from
the API.

## Tests and checks

The repository uses [prek](https://prek.j178.dev/) for Git hooks that format
files and run Rust checks. Install the hooks or run them manually with:

```sh
prek install --prepare-hooks
prek run --all-files
```

PostgreSQL regression tests are ignored by the ordinary test command. Run them
against a disposable PostgreSQL server using a role with permission to create
databases:

```sh
DATABASE_URL=postgres://user:password@localhost/test cargo test --locked -p lfsplanet database_tests -- --ignored
```

SQLx creates and migrates a separate database for each test. CI runs these tests
against its own PostgreSQL service; no LFS installation or OAuth credentials are
needed.

## Logging and validator work

Follow the API logs with `docker compose logs -f api`.
For SQL query logs when running the API on the host:

```sh
RUST_LOG='warn,lfsplanet=info,sqlx::query=info' cargo run --locked -- web
```

`worker` requires an LFS installation, Wine, and Bubblewrap. It is separate
from the ordinary web-development loop; see [replay validation](validator.md).
