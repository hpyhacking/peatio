## How to use Peatio with PostgreSQL

1. Ensure your PostgreSQL version is 10.2.x.
2. Replace `mysql2` Gem with `pg`, lock version range to `~> 0.21`.
3. Replace adapter name in config/database.yml: `mysql2` to `postgresql`.
4. Remove `config/initializers/abstract_mysql2_adapter.rb`
5. Run `bundle install`.
