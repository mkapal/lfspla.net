session := "lfs-planet"
export LOCAL_UID := `id -u`
export LOCAL_GID := `id -g`

# List available tasks.
default:
    @just --list

# Remove build outputs and frontend caches.
clean:
    cargo clean
    rm -rf frontend2/dist frontend2/.svelte-kit frontend2/node_modules/.vite

# Generate track SVGs from one or more .pth files.
[positional-arguments]
track-gen +paths:
    cargo run --locked -p lfsplanet_track_gen -- --output assets/tracks/ "$@"

# Start the full development stack in containers.
[arg('local', long='local', value='true', help='Run the API and frontend on the host; keep PostgreSQL in Docker')]
dev local='false':
    #!/usr/bin/env bash
    set -euo pipefail
    if [[ "{{local}}" != "true" ]]; then
        exec docker compose --profile containers up --build
    fi
    if [[ ! -f planet.yaml ]]; then
        echo "planet.yaml is missing; run 'just generate-config' first" >&2
        exit 1
    fi
    if ! tmux has-session -t {{session}} 2>/dev/null; then
        lock_hash="$(sha256sum frontend2/package-lock.json | cut -d ' ' -f 1)"
        if [[ ! -f frontend2/node_modules/.package-lock.sha256 ]] || [[ "$(cat frontend2/node_modules/.package-lock.sha256)" != "$lock_hash" ]]; then
            npm --prefix frontend2 ci
            printf '%s\n' "$lock_hash" > frontend2/node_modules/.package-lock.sha256
        fi
        docker compose up -d --wait postgres
        tmux new-session -d -s {{session}} -n "services"
        tmux send-keys -t {{session}} "docker compose logs -f postgres" C-m
        tmux split-window -h -t {{session}}
        tmux send-keys -t {{session}} "npm run dev --prefix=frontend2" C-m
        tmux split-window -v -t {{session}}
        tmux send-keys -t {{session}} "cargo run --locked -- -c planet.yaml web" C-m
    else
        docker compose up -d --wait postgres
    fi
    tmux attach-session -t {{session}}

# Generate a development config without overwriting an existing one.
generate-config:
    #!/usr/bin/env bash
    set -euo pipefail
    if [[ -e planet.yaml ]]; then
        echo "planet.yaml already exists; refusing to overwrite it" >&2
        exit 1
    fi
    docker compose --profile containers run --rm --no-deps api cargo run --locked -- generate-config --development > planet.yaml

# Run database migrations, sync the catalogue, and apply eras in containers.
seed:
    docker compose --profile containers run --rm api cargo run --locked -- -c planet.yaml migrate
    docker compose --profile containers run --rm api cargo run --locked -- -c planet.yaml maintenance catalogue-sync --standard-vehicle-images-dir assets/builtin-vehicles
    docker compose --profile containers run --rm api cargo run --locked -- -c planet.yaml era apply assets/eras/*.yaml --yes

# Build the backend and frontend, then deploy the site and eras with pyinfra.
deploy:
    cargo build --locked --release
    npm --prefix frontend2 ci
    npm --prefix frontend2 run build
    uv run --directory deploy --with-requirements requirements.txt pyinfra inventory.py deploy.py
    uv run --directory deploy --with-requirements requirements.txt pyinfra inventory.py eras.py

# Deploy updated eras.
deploy-eras:
    uv run --directory deploy --with-requirements requirements.txt pyinfra inventory.py eras.py

# Run migrations against the container development database.
migrate:
    docker compose --profile containers run --rm api cargo run --locked -- -c planet.yaml migrate
