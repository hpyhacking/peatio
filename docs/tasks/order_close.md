## Cancel orders older than max_age

1. Set ORDER_MAX_AGE env in seconds (e.g. 28 days):

```bash
export ORDER_MAX_AGE=2_419_200
```

2. For process order cancel job:

```bash
bundle exec rake job job:order:close
```

New DB Job record:

| Column | Value |
|--------|-------|
| id | 9 |
| name | close_orders |
| pointer | 1607603942 |
| counter | 2000 |
| data | nil |
| error_code | 0 |
| error_message | nil |
| started_at | Thu 10 Dec 2020 13:39:02 CET +01:00 |
| finished_at | Thu 10 Dec 2020 13:39:28 CET +01:00 |
