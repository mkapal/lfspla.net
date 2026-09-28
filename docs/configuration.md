# Configuration

The config file is `planet.yaml`. Use `--config PATH` (or `-c`) to change it.
For local development:

```sh
just generate-config
```

This uses database host `postgres`, public URL `http://localhost:5173`, and
HTTP cookies, and enables Force validate. Existing files are never overwritten. Add the LFS credentials
from [developer setup](development.md).

The task selects `--development`. The CLI requires `--production` or
`--no-production` (also called `--development`); they cannot be combined.
Production mode enables secure cookies and disables Force validate.
Set its public URL and database URL before use.

For host tools, change the database host to `localhost`.
Deployment uses HTTPS and secure cookies.

`worker.hlvc.poll_interval_seconds` and `worker.hlvc.timeout_seconds` control
hotlap validation. `worker.webhooks.workers` sets concurrent deliveries per
worker process and defaults to 3. Deliveries to the same destination are
serialized. Keep the count within the worker's database connection limit. The
deployment inventory sets it with `webhook_workers` in
`deploy/group_data/all.py`.
