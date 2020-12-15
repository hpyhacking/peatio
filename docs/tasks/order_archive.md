## Archive and delete cancelled orders without any trade older than one week

This job archives orders that were cancelled more than a week ago and didn't produce any trade.
Those orders are stored in the archive database and cleaned up from the main database.

### Prerequisites

* Deploy archive database
* Configure database.yml (archive_db section) 

For process order archive job:

```bash
bundle exec rake job job:order:archive
```

New DB Job record:

| Column | Value |
|--------|-------|
| id | 10 |
| name | archive_orders |
| pointer | 1607603942 |
| counter | 6674 |
| data | nil |
| error_code | 0 |
| error_message | nil |
| started_at | Thu 10 Dec 2020 13:39:02 CET +01:00 |
| finished_at | Thu 10 Dec 2020 13:39:28 CET +01:00 |
