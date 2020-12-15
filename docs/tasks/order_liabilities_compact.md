## Compact order liabilities using Stored Procedure

Submit and cancel order processes create 4 records in the liabilities table (classic bots behaviour).
Because of those processes liabilities table can grow to significant sizes.

Compaction job will process liabilities for the previous week (by default) group them by code, currency_id, and date:

```sql
GROUP BY code, currency_id, member_id, DATE(`created_at`)
```

Due to the size of the liabilities table, it is recommended to run this job every day.

For process order liabilities compaction job:

```bash
bundle exec rake job job:liabilities:compact_orders
```

It will compact liabilities for orders from previous week. Also you can specify timerange (e.g.):

```bash
bundle exec rake job job:liabilities:compact_orders['2020-12-09 00:00:00','2020-12-10 00:00:00']
```

New DB Job record:

| Column | Value |
|--------|-------|
| id | 8 |
| name | compact_orders |
| pointer | 1607603942 |
| counter | 6675 |
| data | nil |
| error_code | 0 |
| error_message | nil |
| started_at | Thu 10 Dec 2020 13:39:02 CET +01:00 |
| finished_at | Thu 10 Dec 2020 13:39:28 CET +01:00 |
