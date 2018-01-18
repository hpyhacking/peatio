if Raven?
  dsn = document.querySelector('meta[name="sentry-dsn"]')?.getAttribute('content')
  Raven.config(dsn).install() if dsn
