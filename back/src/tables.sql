CREATE TABLE IF NOT EXISTS attendee (
  name VARCHAR(45),
  phone VARCHAR(14) NOT NULL PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS plan (
  id integer PRIMARY KEY NOT NULL,
  name VARCHAR(45) NOT NULL,  
  description VARCHAR(450),  
  date Date NOT NULL DEFAULT NOW(),  
  time TIME,
  min_attendees INTEGER,
  owner_phone VARCHAR(14),
  FOREIGN KEY (owner_phone) REFERENCES attendee(phone)
);

CREATE TABLE IF NOT EXISTS plan_attendee (
  plan_id INTEGER,
  attendee_phone VARCHAR(14),
  FOREIGN KEY (plan_id) REFERENCES plan(id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (attendee_phone) REFERENCES attendee(phone) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT plan_attendee_key PRIMARY KEY (plan_id, attendee_phone)
);

CREATE TABLE IF NOT EXISTS required_attendee (
  plan_id INTEGER,
  attendee_phone VARCHAR(14),
  FOREIGN KEY (plan_id) REFERENCES plan(id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (attendee_phone) REFERENCES attendee(phone) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT required_attendee_key PRIMARY KEY (plan_id, attendee_phone)
);

CREATE TABLE IF NOT EXISTS answer (
  plan_id INTEGER,
  attendee_phone VARCHAR(14),
  answer boolean,
  FOREIGN KEY (plan_id) REFERENCES plan(id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (attendee_phone) REFERENCES attendee(phone) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT answer_key PRIMARY KEY (plan_id, attendee_phone)
);
