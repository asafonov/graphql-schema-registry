CREATE OR REPLACE FUNCTION update_updated_time_column()
  RETURNS TRIGGER AS $$
  BEGIN
     NEW.updated_time = now(); 
     RETURN NEW;
  END;
  $$ LANGUAGE 'plpgsql';

CREATE TABLE IF NOT EXISTS persisted_queries
(
    key          varchar(100) NOT NULL,
    query        text         NOT NULL,
    is_active    int          NOT NULL DEFAULT '1',
    updated_time timestamp              DEFAULT NULL,
    added_time   timestamp     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (key)
);

CREATE TRIGGER update_persisted_queries_updated_time BEFORE UPDATE
        ON persisted_queries FOR EACH ROW EXECUTE PROCEDURE 
        update_updated_time_column();

CREATE TABLE IF NOT EXISTS services
(
    id           serial NOT NULL,
    name         varchar(255) NOT NULL DEFAULT '',
    is_active    int          NOT NULL DEFAULT '1',
    updated_time timestamp              DEFAULT NULL,
    added_time   timestamp     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE(name)
);

CREATE TRIGGER update_services_updated_time BEFORE UPDATE
        ON services FOR EACH ROW EXECUTE PROCEDURE 
        update_updated_time_column();

CREATE TABLE IF NOT EXISTS schema
(
    id           serial NOT NULL,
    service_id   int         DEFAULT NULL,
    is_active    int               DEFAULT '1',
    type_defs    text,
    added_time   timestamp     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_time timestamp     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT schema_ibfk_1 FOREIGN KEY (service_id) REFERENCES services (id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX service_id ON schema (service_id);

CREATE TABLE IF NOT EXISTS container_schema
(
    id         serial NOT NULL,
    service_id int NOT NULL,
    schema_id  int NOT NULL,
    version    varchar(100) NOT NULL DEFAULT '',
    added_time timestamp     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE(service_id, version),
    CONSTRAINT container_schema_ibfk_1 FOREIGN KEY (service_id) REFERENCES services (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT container_schema_ibfk_2 FOREIGN KEY (schema_id) REFERENCES schema (id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX schema_id ON container_schema (schema_id);
