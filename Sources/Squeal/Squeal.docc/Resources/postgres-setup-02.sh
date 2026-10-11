createdb blog

psql blog <<'SQL'
CREATE TABLE users (
    id    uuid PRIMARY KEY,
    email text NOT NULL UNIQUE,
    name  text NOT NULL,
    age   int  NOT NULL,
    bio   text
);

CREATE TABLE posts (
    id           uuid PRIMARY KEY,
    author_id    uuid NOT NULL REFERENCES users (id),
    title        text NOT NULL,
    likes        int  NOT NULL DEFAULT 0,
    published_at timestamptz
);
SQL
