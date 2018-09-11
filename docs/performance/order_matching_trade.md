# Performance of order creation, matching & trade execution

**Creating orders**

Creating orders is done using:

1. <https://github.com/rubykube/peatio/blob/1-8-stable/app/api/api_v2/orders.rb#L52>
2. <https://github.com/rubykube/peatio/blob/1-8-stable/app/services/ordering.rb#L12>

When we create order the system locks account and subtracts `Account#balance` and increases `Account#locked` (e.g. locks money). The parallel requests must wait until lock will be released.

**Executing trades**

Daemon `Worker::TradeExecutor` receives IDs of two orders which are matched. Then it attempts to modify balances on each account. See https://github.com/rubykube/peatio/blob/1-8-stable/app/trading/matching/executor.rb#L53

The whole code it wrapped into transaction.

Orders are locked at:

- <https://github.com/rubykube/peatio/blob/1-8-stable/app/trading/matching/executor.rb#L57>

Accounts are locked at:

- <https://github.com/rubykube/peatio/blob/1-8-stable/app/trading/matching/executor.rb#L81>

- <https://github.com/rubykube/peatio/blob/1-8-stable/app/trading/matching/executor.rb#L82>

Full text available from: [Performance of order creation, matching & trade execution](https://github.com/rubykube/peatio/issues/1145)

**Benchmark of trading**

Intel i3-8100 four physical cores, 16GB memory, SSD RAID0.
Single instance of each component.
Highly optimized MySQL.

Was used simple Docker deployment, a little modified <https://github.com/rubykube/toolbox#stress-testing-peatio-trading-engine> utility so it creates orders with predictable results and fresh database. 

The benchmark must be run in production (Kubernetes deployment) with 5 instances of Rails applications and 5 instances of trade_executor daemons. Other daemons must have 1 instance per each.

For Peatio 1.8.9 + [#1110](https://github.com/rubykube/peatio/pull/1110) on top of it.

**Trading engine benchmark (10000 orders, 10 simultaneous requests, 10 traders)**
Order creation API: 57.51 orders per second (173.88 seconds for 10000 orders).
Order execution: 28.05 deals per second (178.19 seconds in total for 5000 deals).

**Trading engine benchmark (10000 orders, 100 simultaneous requests, 100 traders)**
Order creation API: 62.07 orders per second (161.10 seconds for 10000 orders).
Order execution: 30.83 deals per second (162.15 seconds in total for 5000 deals).

For Peatio 1.8.9 + [#1110](https://github.com/rubykube/peatio/pull/1110), [#1215](https://github.com/rubykube/peatio/pull/1215), [#1193](https://github.com/rubykube/peatio/pull/1193) and on top of patches [#1214](https://github.com/rubykube/peatio/pull/1214). 

*5 Rails instances each with 2 threads.*
*One instance per each daemon.*
*Fresh database (no records at all)*

**Average orders per second (creation): (123.08 + 115.54 + 130.98 + 128.71 + 128.91) / 5 = 125.444**

```
Root URL:                        http://peatio.trade:4000
Currencies:                      BTC, USD
Markets:                         BTCUSD
Number of simultaneous traders:  10
Number of orders to create:      1000
Number of simultaneous requests: 10
Minimum order volume:            1.0
Maximum order volume:            100.0
Order volume step:               1.0
Minimum order price:             0.5
Maximum order price:             1.5
Order price step:                0.1

Creating 10 traders... OK
Making each trader billionaire... OK
10 of 1000 orders created (0.11 seconds passed).
20 of 1000 orders created (0.2 seconds passed).
30 of 1000 orders created (0.27 seconds passed).
40 of 1000 orders created (0.35 seconds passed).
50 of 1000 orders created (0.43 seconds passed).
60 of 1000 orders created (0.5 seconds passed).
70 of 1000 orders created (0.57 seconds passed).
80 of 1000 orders created (0.65 seconds passed).
90 of 1000 orders created (0.72 seconds passed).
100 of 1000 orders created (0.8 seconds passed).
110 of 1000 orders created (0.86 seconds passed).
120 of 1000 orders created (0.93 seconds passed).
130 of 1000 orders created (1.02 seconds passed).
140 of 1000 orders created (1.1 seconds passed).
150 of 1000 orders created (1.17 seconds passed).
160 of 1000 orders created (1.26 seconds passed).
170 of 1000 orders created (1.33 seconds passed).
180 of 1000 orders created (1.4 seconds passed).
190 of 1000 orders created (1.47 seconds passed).
200 of 1000 orders created (1.55 seconds passed).
210 of 1000 orders created (1.63 seconds passed).
220 of 1000 orders created (1.71 seconds passed).
230 of 1000 orders created (1.79 seconds passed).
240 of 1000 orders created (1.87 seconds passed).
250 of 1000 orders created (1.94 seconds passed).
260 of 1000 orders created (2.01 seconds passed).
270 of 1000 orders created (2.09 seconds passed).
280 of 1000 orders created (2.17 seconds passed).
290 of 1000 orders created (2.24 seconds passed).
300 of 1000 orders created (2.32 seconds passed).
310 of 1000 orders created (2.39 seconds passed).
320 of 1000 orders created (2.47 seconds passed).
330 of 1000 orders created (2.56 seconds passed).
340 of 1000 orders created (2.65 seconds passed).
350 of 1000 orders created (2.71 seconds passed).
360 of 1000 orders created (2.79 seconds passed).
370 of 1000 orders created (2.87 seconds passed).
380 of 1000 orders created (2.94 seconds passed).
390 of 1000 orders created (3.02 seconds passed).
400 of 1000 orders created (3.1 seconds passed).
410 of 1000 orders created (3.17 seconds passed).
420 of 1000 orders created (3.65 seconds passed).
430 of 1000 orders created (3.74 seconds passed).
440 of 1000 orders created (3.81 seconds passed).
450 of 1000 orders created (3.89 seconds passed).
460 of 1000 orders created (3.96 seconds passed).
470 of 1000 orders created (4.04 seconds passed).
480 of 1000 orders created (4.12 seconds passed).
490 of 1000 orders created (4.19 seconds passed).
500 of 1000 orders created (4.27 seconds passed).
510 of 1000 orders created (4.34 seconds passed).
520 of 1000 orders created (4.41 seconds passed).
530 of 1000 orders created (4.49 seconds passed).
540 of 1000 orders created (4.56 seconds passed).
550 of 1000 orders created (4.63 seconds passed).
560 of 1000 orders created (4.72 seconds passed).
570 of 1000 orders created (4.81 seconds passed).
580 of 1000 orders created (4.89 seconds passed).
590 of 1000 orders created (4.97 seconds passed).
600 of 1000 orders created (5.05 seconds passed).
610 of 1000 orders created (5.12 seconds passed).
620 of 1000 orders created (5.2 seconds passed).
630 of 1000 orders created (5.28 seconds passed).
640 of 1000 orders created (5.36 seconds passed).
650 of 1000 orders created (5.45 seconds passed).
660 of 1000 orders created (5.51 seconds passed).
670 of 1000 orders created (5.59 seconds passed).
680 of 1000 orders created (5.66 seconds passed).
690 of 1000 orders created (5.74 seconds passed).
700 of 1000 orders created (5.82 seconds passed).
710 of 1000 orders created (5.9 seconds passed).
720 of 1000 orders created (5.99 seconds passed).
730 of 1000 orders created (6.04 seconds passed).
740 of 1000 orders created (6.12 seconds passed).
750 of 1000 orders created (6.19 seconds passed).
760 of 1000 orders created (6.27 seconds passed).
770 of 1000 orders created (6.34 seconds passed).
780 of 1000 orders created (6.43 seconds passed).
790 of 1000 orders created (6.5 seconds passed).
800 of 1000 orders created (6.58 seconds passed).
810 of 1000 orders created (6.65 seconds passed).
820 of 1000 orders created (6.73 seconds passed).
830 of 1000 orders created (6.81 seconds passed).
840 of 1000 orders created (6.89 seconds passed).
850 of 1000 orders created (6.96 seconds passed).
860 of 1000 orders created (7.04 seconds passed).
870 of 1000 orders created (7.11 seconds passed).
880 of 1000 orders created (7.18 seconds passed).
890 of 1000 orders created (7.27 seconds passed).
900 of 1000 orders created (7.36 seconds passed).
910 of 1000 orders created (7.43 seconds passed).
920 of 1000 orders created (7.5 seconds passed).
930 of 1000 orders created (7.58 seconds passed).
940 of 1000 orders created (7.64 seconds passed).
950 of 1000 orders created (7.73 seconds passed).
960 of 1000 orders created (7.81 seconds passed).
970 of 1000 orders created (7.88 seconds passed).
980 of 1000 orders created (7.97 seconds passed).
990 of 1000 orders created (8.06 seconds passed).
1000 of 1000 orders created (8.13 seconds passed).
123.08 orders per second.
```

```
Root URL:                        http://peatio.trade:4000
Currencies:                      BTC, USD
Markets:                         BTCUSD
Number of simultaneous traders:  10
Number of orders to create:      1000
Number of simultaneous requests: 10
Minimum order volume:            1.0
Maximum order volume:            100.0
Order volume step:               1.0
Minimum order price:             0.5
Maximum order price:             1.5
Order price step:                0.1

Creating 10 traders... OK
Making each trader billionaire... OK
10 of 1000 orders created (0.1 seconds passed).
20 of 1000 orders created (0.19 seconds passed).
30 of 1000 orders created (0.27 seconds passed).
40 of 1000 orders created (0.33 seconds passed).
50 of 1000 orders created (0.42 seconds passed).
60 of 1000 orders created (0.49 seconds passed).
70 of 1000 orders created (0.57 seconds passed).
80 of 1000 orders created (0.64 seconds passed).
90 of 1000 orders created (0.72 seconds passed).
100 of 1000 orders created (0.81 seconds passed).
110 of 1000 orders created (0.88 seconds passed).
120 of 1000 orders created (0.96 seconds passed).
130 of 1000 orders created (1.03 seconds passed).
140 of 1000 orders created (1.1 seconds passed).
150 of 1000 orders created (1.19 seconds passed).
160 of 1000 orders created (1.28 seconds passed).
170 of 1000 orders created (1.37 seconds passed).
180 of 1000 orders created (1.45 seconds passed).
190 of 1000 orders created (1.52 seconds passed).
200 of 1000 orders created (1.6 seconds passed).
210 of 1000 orders created (1.69 seconds passed).
220 of 1000 orders created (1.74 seconds passed).
230 of 1000 orders created (1.81 seconds passed).
240 of 1000 orders created (1.88 seconds passed).
250 of 1000 orders created (1.96 seconds passed).
260 of 1000 orders created (2.04 seconds passed).
270 of 1000 orders created (2.1 seconds passed).
280 of 1000 orders created (2.19 seconds passed).
290 of 1000 orders created (2.25 seconds passed).
300 of 1000 orders created (2.81 seconds passed).
310 of 1000 orders created (2.94 seconds passed).
320 of 1000 orders created (3.0 seconds passed).
330 of 1000 orders created (3.07 seconds passed).
340 of 1000 orders created (3.16 seconds passed).
350 of 1000 orders created (3.24 seconds passed).
360 of 1000 orders created (3.32 seconds passed).
370 of 1000 orders created (3.39 seconds passed).
380 of 1000 orders created (3.46 seconds passed).
390 of 1000 orders created (3.53 seconds passed).
400 of 1000 orders created (3.6 seconds passed).
410 of 1000 orders created (3.67 seconds passed).
420 of 1000 orders created (3.76 seconds passed).
430 of 1000 orders created (3.84 seconds passed).
440 of 1000 orders created (3.9 seconds passed).
450 of 1000 orders created (3.99 seconds passed).
460 of 1000 orders created (4.08 seconds passed).
470 of 1000 orders created (4.15 seconds passed).
480 of 1000 orders created (4.24 seconds passed).
490 of 1000 orders created (4.32 seconds passed).
500 of 1000 orders created (4.39 seconds passed).
510 of 1000 orders created (4.47 seconds passed).
520 of 1000 orders created (4.54 seconds passed).
530 of 1000 orders created (4.6 seconds passed).
540 of 1000 orders created (4.68 seconds passed).
550 of 1000 orders created (4.76 seconds passed).
560 of 1000 orders created (4.82 seconds passed).
570 of 1000 orders created (4.9 seconds passed).
580 of 1000 orders created (4.96 seconds passed).
590 of 1000 orders created (5.05 seconds passed).
600 of 1000 orders created (5.12 seconds passed).
610 of 1000 orders created (5.2 seconds passed).
620 of 1000 orders created (5.28 seconds passed).
630 of 1000 orders created (5.36 seconds passed).
640 of 1000 orders created (5.44 seconds passed).
650 of 1000 orders created (5.51 seconds passed).
660 of 1000 orders created (5.58 seconds passed).
670 of 1000 orders created (5.67 seconds passed).
680 of 1000 orders created (5.75 seconds passed).
690 of 1000 orders created (5.82 seconds passed).
700 of 1000 orders created (5.89 seconds passed).
710 of 1000 orders created (5.96 seconds passed).
720 of 1000 orders created (6.03 seconds passed).
730 of 1000 orders created (6.1 seconds passed).
740 of 1000 orders created (6.18 seconds passed).
750 of 1000 orders created (6.26 seconds passed).
760 of 1000 orders created (6.33 seconds passed).
770 of 1000 orders created (6.4 seconds passed).
780 of 1000 orders created (6.47 seconds passed).
790 of 1000 orders created (6.55 seconds passed).
800 of 1000 orders created (6.62 seconds passed).
810 of 1000 orders created (6.7 seconds passed).
820 of 1000 orders created (6.78 seconds passed).
830 of 1000 orders created (6.85 seconds passed).
840 of 1000 orders created (6.93 seconds passed).
850 of 1000 orders created (7.0 seconds passed).
860 of 1000 orders created (7.08 seconds passed).
870 of 1000 orders created (7.15 seconds passed).
880 of 1000 orders created (7.25 seconds passed).
890 of 1000 orders created (7.56 seconds passed).
900 of 1000 orders created (7.9 seconds passed).
910 of 1000 orders created (7.98 seconds passed).
920 of 1000 orders created (8.06 seconds passed).
930 of 1000 orders created (8.12 seconds passed).
940 of 1000 orders created (8.19 seconds passed).
950 of 1000 orders created (8.25 seconds passed).
960 of 1000 orders created (8.34 seconds passed).
970 of 1000 orders created (8.42 seconds passed).
980 of 1000 orders created (8.49 seconds passed).
990 of 1000 orders created (8.57 seconds passed).
1000 of 1000 orders created (8.67 seconds passed).
115.54 orders per second.
```

```
Root URL:                        http://peatio.trade:4000
Currencies:                      BTC, USD
Markets:                         BTCUSD
Number of simultaneous traders:  10
Number of orders to create:      1000
Number of simultaneous requests: 10
Minimum order volume:            1.0
Maximum order volume:            100.0
Order volume step:               1.0
Minimum order price:             0.5
Maximum order price:             1.5
Order price step:                0.1

Creating 10 traders... OK
Making each trader billionaire... OK
10 of 1000 orders created (0.1 seconds passed).
20 of 1000 orders created (0.19 seconds passed).
30 of 1000 orders created (0.25 seconds passed).
40 of 1000 orders created (0.33 seconds passed).
50 of 1000 orders created (0.39 seconds passed).
60 of 1000 orders created (0.46 seconds passed).
70 of 1000 orders created (0.53 seconds passed).
80 of 1000 orders created (0.61 seconds passed).
90 of 1000 orders created (0.68 seconds passed).
100 of 1000 orders created (0.75 seconds passed).
110 of 1000 orders created (0.83 seconds passed).
120 of 1000 orders created (0.9 seconds passed).
130 of 1000 orders created (0.96 seconds passed).
140 of 1000 orders created (1.03 seconds passed).
150 of 1000 orders created (1.12 seconds passed).
160 of 1000 orders created (1.19 seconds passed).
170 of 1000 orders created (1.25 seconds passed).
180 of 1000 orders created (1.32 seconds passed).
190 of 1000 orders created (1.4 seconds passed).
200 of 1000 orders created (1.49 seconds passed).
210 of 1000 orders created (1.56 seconds passed).
220 of 1000 orders created (1.63 seconds passed).
230 of 1000 orders created (1.71 seconds passed).
240 of 1000 orders created (1.78 seconds passed).
250 of 1000 orders created (1.85 seconds passed).
260 of 1000 orders created (1.93 seconds passed).
270 of 1000 orders created (1.99 seconds passed).
280 of 1000 orders created (2.06 seconds passed).
290 of 1000 orders created (2.14 seconds passed).
300 of 1000 orders created (2.21 seconds passed).
310 of 1000 orders created (2.3 seconds passed).
320 of 1000 orders created (2.37 seconds passed).
330 of 1000 orders created (2.44 seconds passed).
340 of 1000 orders created (2.53 seconds passed).
350 of 1000 orders created (2.61 seconds passed).
360 of 1000 orders created (2.67 seconds passed).
370 of 1000 orders created (2.73 seconds passed).
380 of 1000 orders created (2.81 seconds passed).
390 of 1000 orders created (2.88 seconds passed).
400 of 1000 orders created (2.97 seconds passed).
410 of 1000 orders created (3.05 seconds passed).
420 of 1000 orders created (3.13 seconds passed).
430 of 1000 orders created (3.2 seconds passed).
440 of 1000 orders created (3.27 seconds passed).
450 of 1000 orders created (3.34 seconds passed).
460 of 1000 orders created (3.41 seconds passed).
470 of 1000 orders created (3.49 seconds passed).
480 of 1000 orders created (3.56 seconds passed).
490 of 1000 orders created (3.63 seconds passed).
500 of 1000 orders created (3.71 seconds passed).
510 of 1000 orders created (3.78 seconds passed).
520 of 1000 orders created (3.86 seconds passed).
530 of 1000 orders created (3.94 seconds passed).
540 of 1000 orders created (4.02 seconds passed).
550 of 1000 orders created (4.09 seconds passed).
560 of 1000 orders created (4.16 seconds passed).
570 of 1000 orders created (4.25 seconds passed).
580 of 1000 orders created (4.32 seconds passed).
590 of 1000 orders created (4.39 seconds passed).
600 of 1000 orders created (4.45 seconds passed).
610 of 1000 orders created (4.51 seconds passed).
620 of 1000 orders created (4.59 seconds passed).
630 of 1000 orders created (4.67 seconds passed).
640 of 1000 orders created (4.74 seconds passed).
650 of 1000 orders created (4.82 seconds passed).
660 of 1000 orders created (4.9 seconds passed).
670 of 1000 orders created (4.97 seconds passed).
680 of 1000 orders created (5.05 seconds passed).
690 of 1000 orders created (5.13 seconds passed).
700 of 1000 orders created (5.2 seconds passed).
710 of 1000 orders created (5.28 seconds passed).
720 of 1000 orders created (5.37 seconds passed).
730 of 1000 orders created (5.44 seconds passed).
740 of 1000 orders created (5.51 seconds passed).
750 of 1000 orders created (5.59 seconds passed).
760 of 1000 orders created (5.66 seconds passed).
770 of 1000 orders created (5.74 seconds passed).
780 of 1000 orders created (5.81 seconds passed).
790 of 1000 orders created (5.89 seconds passed).
800 of 1000 orders created (5.97 seconds passed).
810 of 1000 orders created (6.03 seconds passed).
820 of 1000 orders created (6.13 seconds passed).
830 of 1000 orders created (6.18 seconds passed).
840 of 1000 orders created (6.25 seconds passed).
850 of 1000 orders created (6.49 seconds passed).
860 of 1000 orders created (6.58 seconds passed).
870 of 1000 orders created (6.65 seconds passed).
880 of 1000 orders created (6.73 seconds passed).
890 of 1000 orders created (6.8 seconds passed).
900 of 1000 orders created (6.87 seconds passed).
910 of 1000 orders created (6.95 seconds passed).
920 of 1000 orders created (7.03 seconds passed).
930 of 1000 orders created (7.1 seconds passed).
940 of 1000 orders created (7.17 seconds passed).
950 of 1000 orders created (7.27 seconds passed).
960 of 1000 orders created (7.35 seconds passed).
970 of 1000 orders created (7.43 seconds passed).
980 of 1000 orders created (7.49 seconds passed).
990 of 1000 orders created (7.58 seconds passed).
1000 of 1000 orders created (7.66 seconds passed).
130.98 orders per second.


```

```
Root URL:                        http://peatio.trade:4000
Currencies:                      BTC, USD
Markets:                         BTCUSD
Number of simultaneous traders:  10
Number of orders to create:      1000
Number of simultaneous requests: 10
Minimum order volume:            1.0
Maximum order volume:            100.0
Order volume step:               1.0
Minimum order price:             0.5
Maximum order price:             1.5
Order price step:                0.1

Creating 10 traders... OK
Making each trader billionaire... OK
10 of 1000 orders created (0.17 seconds passed).
20 of 1000 orders created (0.25 seconds passed).
30 of 1000 orders created (0.33 seconds passed).
40 of 1000 orders created (0.4 seconds passed).
50 of 1000 orders created (0.46 seconds passed).
60 of 1000 orders created (0.56 seconds passed).
70 of 1000 orders created (0.63 seconds passed).
80 of 1000 orders created (0.71 seconds passed).
90 of 1000 orders created (0.78 seconds passed).
100 of 1000 orders created (0.86 seconds passed).
110 of 1000 orders created (0.95 seconds passed).
120 of 1000 orders created (1.03 seconds passed).
130 of 1000 orders created (1.14 seconds passed).
140 of 1000 orders created (1.23 seconds passed).
150 of 1000 orders created (1.3 seconds passed).
160 of 1000 orders created (1.39 seconds passed).
170 of 1000 orders created (1.46 seconds passed).
180 of 1000 orders created (1.53 seconds passed).
190 of 1000 orders created (1.61 seconds passed).
200 of 1000 orders created (1.68 seconds passed).
210 of 1000 orders created (1.75 seconds passed).
220 of 1000 orders created (1.82 seconds passed).
230 of 1000 orders created (1.91 seconds passed).
240 of 1000 orders created (1.99 seconds passed).
250 of 1000 orders created (2.06 seconds passed).
260 of 1000 orders created (2.13 seconds passed).
270 of 1000 orders created (2.2 seconds passed).
280 of 1000 orders created (2.29 seconds passed).
290 of 1000 orders created (2.37 seconds passed).
300 of 1000 orders created (2.43 seconds passed).
310 of 1000 orders created (2.52 seconds passed).
320 of 1000 orders created (2.59 seconds passed).
330 of 1000 orders created (2.68 seconds passed).
340 of 1000 orders created (2.73 seconds passed).
350 of 1000 orders created (2.81 seconds passed).
360 of 1000 orders created (2.89 seconds passed).
370 of 1000 orders created (2.97 seconds passed).
380 of 1000 orders created (3.05 seconds passed).
390 of 1000 orders created (3.13 seconds passed).
400 of 1000 orders created (3.21 seconds passed).
410 of 1000 orders created (3.28 seconds passed).
420 of 1000 orders created (3.36 seconds passed).
430 of 1000 orders created (3.44 seconds passed).
440 of 1000 orders created (3.51 seconds passed).
450 of 1000 orders created (3.59 seconds passed).
460 of 1000 orders created (3.69 seconds passed).
470 of 1000 orders created (3.75 seconds passed).
480 of 1000 orders created (3.84 seconds passed).
490 of 1000 orders created (3.91 seconds passed).
500 of 1000 orders created (3.98 seconds passed).
510 of 1000 orders created (4.06 seconds passed).
520 of 1000 orders created (4.15 seconds passed).
530 of 1000 orders created (4.23 seconds passed).
540 of 1000 orders created (4.31 seconds passed).
550 of 1000 orders created (4.37 seconds passed).
560 of 1000 orders created (4.45 seconds passed).
570 of 1000 orders created (4.54 seconds passed).
580 of 1000 orders created (4.63 seconds passed).
590 of 1000 orders created (4.7 seconds passed).
600 of 1000 orders created (4.77 seconds passed).
610 of 1000 orders created (4.84 seconds passed).
620 of 1000 orders created (4.91 seconds passed).
630 of 1000 orders created (4.98 seconds passed).
640 of 1000 orders created (5.06 seconds passed).
650 of 1000 orders created (5.15 seconds passed).
660 of 1000 orders created (5.22 seconds passed).
670 of 1000 orders created (5.3 seconds passed).
680 of 1000 orders created (5.38 seconds passed).
690 of 1000 orders created (5.44 seconds passed).
700 of 1000 orders created (5.53 seconds passed).
710 of 1000 orders created (5.59 seconds passed).
720 of 1000 orders created (5.67 seconds passed).
730 of 1000 orders created (5.75 seconds passed).
740 of 1000 orders created (5.81 seconds passed).
750 of 1000 orders created (5.89 seconds passed).
760 of 1000 orders created (5.97 seconds passed).
770 of 1000 orders created (6.03 seconds passed).
780 of 1000 orders created (6.11 seconds passed).
790 of 1000 orders created (6.19 seconds passed).
800 of 1000 orders created (6.27 seconds passed).
810 of 1000 orders created (6.36 seconds passed).
820 of 1000 orders created (6.43 seconds passed).
830 of 1000 orders created (6.51 seconds passed).
840 of 1000 orders created (6.59 seconds passed).
850 of 1000 orders created (6.66 seconds passed).
860 of 1000 orders created (6.72 seconds passed).
870 of 1000 orders created (6.8 seconds passed).
880 of 1000 orders created (6.87 seconds passed).
890 of 1000 orders created (6.95 seconds passed).
900 of 1000 orders created (7.03 seconds passed).
910 of 1000 orders created (7.11 seconds passed).
920 of 1000 orders created (7.19 seconds passed).
930 of 1000 orders created (7.27 seconds passed).
940 of 1000 orders created (7.33 seconds passed).
950 of 1000 orders created (7.4 seconds passed).
960 of 1000 orders created (7.48 seconds passed).
970 of 1000 orders created (7.57 seconds passed).
980 of 1000 orders created (7.63 seconds passed).
990 of 1000 orders created (7.7 seconds passed).
1000 of 1000 orders created (7.77 seconds passed).
128.71 orders per second.
```

```
Root URL:                        http://peatio.trade:4000
Currencies:                      BTC, USD
Markets:                         BTCUSD
Number of simultaneous traders:  10
Number of orders to create:      1000
Number of simultaneous requests: 10
Minimum order volume:            1.0
Maximum order volume:            100.0
Order volume step:               1.0
Minimum order price:             0.5
Maximum order price:             1.5
Order price step:                0.1

Creating 10 traders... OK
Making each trader billionaire... OK
10 of 1000 orders created (0.13 seconds passed).
20 of 1000 orders created (0.19 seconds passed).
30 of 1000 orders created (0.27 seconds passed).
40 of 1000 orders created (0.37 seconds passed).
50 of 1000 orders created (0.46 seconds passed).
60 of 1000 orders created (0.53 seconds passed).
70 of 1000 orders created (0.61 seconds passed).
80 of 1000 orders created (0.67 seconds passed).
90 of 1000 orders created (0.76 seconds passed).
100 of 1000 orders created (0.83 seconds passed).
110 of 1000 orders created (0.91 seconds passed).
120 of 1000 orders created (0.99 seconds passed).
130 of 1000 orders created (1.06 seconds passed).
140 of 1000 orders created (1.13 seconds passed).
150 of 1000 orders created (1.21 seconds passed).
160 of 1000 orders created (1.27 seconds passed).
170 of 1000 orders created (1.36 seconds passed).
180 of 1000 orders created (1.43 seconds passed).
190 of 1000 orders created (1.51 seconds passed).
200 of 1000 orders created (1.57 seconds passed).
210 of 1000 orders created (1.64 seconds passed).
220 of 1000 orders created (1.73 seconds passed).
230 of 1000 orders created (1.81 seconds passed).
240 of 1000 orders created (1.86 seconds passed).
250 of 1000 orders created (1.93 seconds passed).
260 of 1000 orders created (2.02 seconds passed).
270 of 1000 orders created (2.09 seconds passed).
280 of 1000 orders created (2.17 seconds passed).
290 of 1000 orders created (2.26 seconds passed).
300 of 1000 orders created (2.32 seconds passed).
310 of 1000 orders created (2.41 seconds passed).
320 of 1000 orders created (2.48 seconds passed).
330 of 1000 orders created (2.55 seconds passed).
340 of 1000 orders created (2.61 seconds passed).
350 of 1000 orders created (2.7 seconds passed).
360 of 1000 orders created (2.78 seconds passed).
370 of 1000 orders created (2.88 seconds passed).
380 of 1000 orders created (2.95 seconds passed).
390 of 1000 orders created (3.03 seconds passed).
400 of 1000 orders created (3.11 seconds passed).
410 of 1000 orders created (3.18 seconds passed).
420 of 1000 orders created (3.26 seconds passed).
430 of 1000 orders created (3.34 seconds passed).
440 of 1000 orders created (3.42 seconds passed).
450 of 1000 orders created (3.5 seconds passed).
460 of 1000 orders created (3.6 seconds passed).
470 of 1000 orders created (3.67 seconds passed).
480 of 1000 orders created (3.75 seconds passed).
490 of 1000 orders created (3.82 seconds passed).
500 of 1000 orders created (3.91 seconds passed).
510 of 1000 orders created (3.98 seconds passed).
520 of 1000 orders created (4.06 seconds passed).
530 of 1000 orders created (4.15 seconds passed).
540 of 1000 orders created (4.22 seconds passed).
550 of 1000 orders created (4.29 seconds passed).
560 of 1000 orders created (4.36 seconds passed).
570 of 1000 orders created (4.43 seconds passed).
580 of 1000 orders created (4.51 seconds passed).
590 of 1000 orders created (4.59 seconds passed).
600 of 1000 orders created (4.67 seconds passed).
610 of 1000 orders created (4.75 seconds passed).
620 of 1000 orders created (4.83 seconds passed).
630 of 1000 orders created (4.9 seconds passed).
640 of 1000 orders created (4.97 seconds passed).
650 of 1000 orders created (5.06 seconds passed).
660 of 1000 orders created (5.14 seconds passed).
670 of 1000 orders created (5.2 seconds passed).
680 of 1000 orders created (5.28 seconds passed).
690 of 1000 orders created (5.36 seconds passed).
700 of 1000 orders created (5.42 seconds passed).
710 of 1000 orders created (5.51 seconds passed).
720 of 1000 orders created (5.58 seconds passed).
730 of 1000 orders created (5.67 seconds passed).
740 of 1000 orders created (5.74 seconds passed).
750 of 1000 orders created (5.81 seconds passed).
760 of 1000 orders created (5.89 seconds passed).
770 of 1000 orders created (5.98 seconds passed).
780 of 1000 orders created (6.04 seconds passed).
790 of 1000 orders created (6.11 seconds passed).
800 of 1000 orders created (6.22 seconds passed).
810 of 1000 orders created (6.28 seconds passed).
820 of 1000 orders created (6.37 seconds passed).
830 of 1000 orders created (6.45 seconds passed).
840 of 1000 orders created (6.53 seconds passed).
850 of 1000 orders created (6.59 seconds passed).
860 of 1000 orders created (6.68 seconds passed).
870 of 1000 orders created (6.76 seconds passed).
880 of 1000 orders created (6.85 seconds passed).
890 of 1000 orders created (6.93 seconds passed).
900 of 1000 orders created (6.99 seconds passed).
910 of 1000 orders created (7.07 seconds passed).
920 of 1000 orders created (7.15 seconds passed).
930 of 1000 orders created (7.23 seconds passed).
940 of 1000 orders created (7.31 seconds passed).
950 of 1000 orders created (7.38 seconds passed).
960 of 1000 orders created (7.46 seconds passed).
970 of 1000 orders created (7.54 seconds passed).
980 of 1000 orders created (7.62 seconds passed).
990 of 1000 orders created (7.69 seconds passed).
1000 of 1000 orders created (7.77 seconds passed).
128.91 orders per second.
```