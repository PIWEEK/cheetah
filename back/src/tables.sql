CREATE TABLE IF NOT EXISTS plans (
  id integer PRIMARY KEY NOT NULL,
  name VARCHAR(45) NOT NULL,  
  description VARCHAR(450),  
  date Date NOT NULL DEFAULT NOW(),  
  time TIME,
  attendees: attendees[],
  min_attendees INTEGER,
  required_attendees: attendees[],
  owner INTEGER REFERENCES attendees (id)
)

CREATE TABLE IF NOT EXISTS attendees (
  id INTEGER PRIMARY KEY NOT NULL,
  name VARCHAR(45) NOT NULL,
  phone VARCHAR(14) NOT NULL
)

CREATE TABLE IF NOT EXISTS answers (
  attendee_id INTEGER REFERENCES attendees,
  plan_id INTEGER REFERENCES plans,
  answer boolean
)
