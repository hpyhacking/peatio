### In Peatio 2.4 introduced InfluxDB for storing trades and building k-lines. For import local historical trades you will need to process severall rake tasks

1. Import trades to the InfluxDB:

```bash
  bundle exec rake import:trade_to_influx
```

2. Build k-lines:

```bash
  bundle exec rake import:influx_build_candles
```
