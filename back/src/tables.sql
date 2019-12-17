CREATE TABLE IF NOT EXISTS attendee (
  id INTEGER PRIMARY KEY NOT NULL,
  name VARCHAR(45) NOT NULL,
  phone VARCHAR(14) NOT NULL
);

CREATE TABLE IF NOT EXISTS plan (
  id integer PRIMARY KEY NOT NULL,
  name VARCHAR(45) NOT NULL,  
  description VARCHAR(450),  
  date Date NOT NULL DEFAULT NOW(),  
  time TIME,
  min_attendees INTEGER,
  owner_id INTEGER,
  FOREIGN KEY (owner_id) REFERENCES attendee(id)
);

CREATE TABLE IF NOT EXISTS plan_attendee (
  plan_id INTEGER,
  attendee_id INTEGER,
  FOREIGN KEY (plan_id) REFERENCES plan(id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (attendee_id) REFERENCES attendee(id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT plan_attendee_key PRIMARY KEY (plan_id, attendee_id)
);

CREATE TABLE IF NOT EXISTS required_attendee (
  plan_id INTEGER,
  attendee_id INTEGER,
  FOREIGN KEY (plan_id) REFERENCES plan(id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (attendee_id) REFERENCES attendee(id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT required_attendee_key PRIMARY KEY (plan_id, attendee_id)
);

CREATE TABLE IF NOT EXISTS answer (
  plan_id INTEGER,
  attendee_id INTEGER,
  answer boolean,
  FOREIGN KEY (plan_id) REFERENCES plan(id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (attendee_id) REFERENCES attendee(id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT answer_key PRIMARY KEY (plan_id, attendee_id)
);
