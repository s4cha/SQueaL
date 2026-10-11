CREATE TABLE users (
    id    uuid PRIMARY KEY,
    email text NOT NULL UNIQUE,
    name  text NOT NULL
);

CREATE TABLE posts (
    id         uuid PRIMARY KEY,
    author_id  uuid NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    title      text NOT NULL,
    likes      int  NOT NULL DEFAULT 0,
    created_at timestamptz NOT NULL DEFAULT now()
);
