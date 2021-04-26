var settings = {
  development: {
    db: "notejam.db",
    dsn: "sqlite://notejam.db"
  },
  test: {
    db: "notejam_test.db",
    dsn: "sqlite://notejam_test.db"
  },
  production: {
    db: (process.env.db ? process.env.db: "notejam_prod.db"),
    dsn: (process.env.dsn ? process.env.dsn: "sqlite://notejam_prod.db")
  }
};


var env = process.env.NODE_ENV
if (!env) {
  env = 'development'
};
module.exports = settings[env];
