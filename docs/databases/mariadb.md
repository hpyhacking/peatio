## How to use Peatio with MariaDB

Peatio supports MariaDB 10.2.7 and upper.

MariaDB json types are not well supported by Rails, to make the application work properly you need to enable explicit serialization and deserialization of JSON fields.

To do so, set the following environment variable:

```bash
export DATABASE_SUPPORT_JSON=false
```
