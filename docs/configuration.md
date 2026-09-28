# Configuration

The config file is `planet.yaml`. Use `--config PATH` (or `-c`) to change it.
For local development:

```sh
just setup
```

This uses database host `localhost`, public URL `http://localhost:5173`, HTTP
cookies, and enables Force validate. Existing files are never overwritten.
Replace the generated `REPLACE_ME` OAuth values with credentials from
[developer setup](development.md).

The task selects `--development`. The CLI requires `--production` or
`--no-production` (also called `--development`); they cannot be combined.
Production mode enables secure cookies and disables Force validate.
Set its public URL and database URL before use.

Deployment uses HTTPS and secure cookies.

`worker.hlvc.poll_interval_seconds` and `worker.hlvc.timeout_seconds` control
hotlap validation. `worker.webhooks.workers` sets concurrent deliveries per
worker process and defaults to 3. Deliveries to the same destination are
serialized. Keep the count within the worker's database connection limit. The
deployment inventory sets it with `webhook_workers` in
`deploy/group_data/all.py`.
