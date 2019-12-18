CREATE TABLE IF NOT EXISTS person (
  name VARCHAR(45),
  phone VARCHAR(14) NOT NULL PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS plan (
  id BIGSERIAL PRIMARY KEY NOT NULL,
  name VARCHAR(45) NOT NULL,  
  description VARCHAR(450),  
  date Date NOT NULL DEFAULT NOW(),  
  time TIME,
  min_people INTEGER,
  owner_phone VARCHAR(14),
  FOREIGN KEY (owner_phone) REFERENCES person(phone)
);

CREATE TABLE IF NOT EXISTS plan_person (
  plan_id INTEGER,
  person_phone VARCHAR(14),
  required_person boolean DEFAULT false,
  answer boolean,
  FOREIGN KEY (plan_id) REFERENCES plan(id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (person_phone) REFERENCES person(phone) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT plan_person_key PRIMARY KEY (plan_id, person_phone)
);
