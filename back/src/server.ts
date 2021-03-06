import cors from '@koa/cors';
import Router from '@koa/router';
import Koa, { Context } from 'koa';
import koaBody from 'koa-body';
import logger from 'koa-logger';
import { Pool } from 'pg';

import Config from './config';

const fs = require('fs');
const path = require("path");
const app = new Koa();
const router = new Router();

const pool = new Pool({
  database: Config.db.database,
  host: Config.db.host,
  password: Config.db.password,
  port: Config.db.port,
  user: Config.db.user,
});

router.post('/mock/answer', koaBody(), async (ctx) => {
  console.log('answer', ctx.request.body);

  ctx.status = 201;
  ctx.body = {
    status: 'success',
    data:  {}
  };
});

router.get('/mock/plan/:id', async (ctx) => {
/*   {
    name: 'hhh',
    description: 'vhcf',
    date: '2019-12-18 23:00:00.000Z',
    time: '6:44',
    min_attendees: '5',
    attendes: '[627263808]'
  } */
  ctx.status = 200;
  console.log(ctx.params.id);

  ctx.body = {
    data: {
      id: 0,
      name: 'plan 1',
      description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus dignissim mattis purus, et aliquet enim vestibulum in. Praesent quis dui interdum, feugiat nisi posuere, porttitor risus. Phasellus sit amet enim egestas, dapibus nulla eu, finibus ipsum. In sit amet augue neque. Maecenas tincidunt a arcu eu dapibus. Quisque gravida tortor at rutrum finibus. Nullam ac molestie ante. Ut ac congue erat. Sed nisi purus, gravida a nisl et, euismod vestibulum metus. Pellentesque commodo porta viverra. Maecenas venenatis congue lacus, in viverra lorem tincidunt eget.',
      date: '2019-12-18 23:00:00.000Z',
      author: 'Pepe',
      time: '12:00',
      answers: [
        {
          plan_id: 0,
          answer: null,
          date: '2019-12-18 23:00:00.000Z',
          time: '22:45',
          phone: 60000001
        },
        {
          plan_id: 1,
          answer: true,
          date: '2019-12-18 23:00:00.000Z',
          time: '12:00',
          phone: 60000001
        },
        {
          plan_id: 1,
          answer: true,
          date: '2019-12-18 23:00:00.000Z',
          time: '12:00',
          phone: 60000002
        },
        {
          plan_id: 2,
          answer: false,
          date: '2019-12-18 23:00:00.000Z',
          time: '12:30',
          phone: 60000002
        },
        {
          plan_id: 3,
          answer: true,
          date: '2019-12-18 23:00:00.000Z',
          time: '22:00',
          phone: 60000003
        },
        {
          plan_id: 4,
          answer: null,
          date: '2019-12-18 23:00:00.000Z',
          time: '22:45',
          phone: 60000004
        }
      ]
    }
  };
});

router.get('/mock/plans', async (ctx) => {
  ctx.status = 200;

  ctx.body = {
    data: {
      result: [
        {
          id: 0,
          name: 'plan 1',
          description: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus dignissim mattis purus, et aliquet enim vestibulum in. Praesent quis dui interdum, feugiat nisi posuere, porttitor risus. Phasellus sit amet enim egestas, dapibus nulla eu, finibus ipsum. In sit amet augue neque. Maecenas tincidunt a arcu eu dapibus. Quisque gravida tortor at rutrum finibus. Nullam ac molestie ante. Ut ac congue erat. Sed nisi purus, gravida a nisl et, euismod vestibulum metus. Pellentesque commodo porta viverra. Maecenas venenatis congue lacus, in viverra lorem tincidunt eget.'
        },
        {
          id: 1,
          name: 'plan 2',
          description: 'Lorem ipsum dolor sit amet.'
        },
        {
          id: 2,
          name: 'plan 3',
          description: 'Phasellus dignissim mattis purus, et aliquet enim vestibulum in. Praesent quis dui interdum, feugiat nisi posuere, porttitor risus. Phasellus sit amet enim egestas, dapibus nulla eu, finibus ipsum. In sit amet augue neque. Maecenas tincidunt a arcu eu dapibus. Quisque gravida tortor at rutrum finibus. Nullam ac molestie ante. Ut ac congue erat. Sed nisi purus, gravida a nisl et, euismod vestibulum metus. Pellentesque commodo porta viverra. Maecenas venenatis congue lacus, in viverra lorem tincidunt eget.'
        },
        {
          id: 3,
          name: 'plan 4',
          description: 'Dolor sit amet, consectetur adipiscing elit.'
        }
      ]
    }
  };
});

router.post('/mock/create', koaBody(), async (ctx) => {
  console.log(ctx.request.body);

  ctx.status = 201;
  ctx.body = {
    status: 'success',
    data:  {
      id : 123,
      name: 'New plan', 
      description: 'plan descripcion',  
      date: '2019-12-09 23:00:00.000Z',
      time: '8:52',    
      min_people: 0
    }
  };
});

router.post('/mock/create-user', koaBody(), async (ctx) => {
  console.log(ctx.request.body);

  ctx.status = 201;
  ctx.body = {
    status: 'success',
    data:  {}
  };
});

pool.query(fs.readFileSync(path.resolve(__dirname, '../src/tables.sql'), 'utf8'));

router.get('/', async (ctx) => {
  const result = await pool.query('SELECT NOW()');

  ctx.body = {
    text: `Hello World ${result.rows[0].now}`,
  };
});

router.get('/api/persons/:phone', koaBody(), async (ctx) => {
  try {
    const result = await pool.query('SELECT * FROM person WHERE phone = $1', [ctx.params.phone]);

    ctx.status = 201;
    ctx.body = {
      status: 'success',
      data: {
        result: result.rows[0],
      },
    };
  } catch (error) {
    ctx.body = {
      status: 'error',
      data: {
        response: error.detail,
      },
    };
  }
});

router.post('/api/persons', koaBody(), async (ctx) => {
  try {
    let res;
    const body = ctx.request.body;
    const ownerValues = [body.name, body.phone];
    if (await isPhoneInPersonTable(body.phone)) {
      res = await pool.query('UPDATE person SET name = $1 WHERE phone = $2', ownerValues);
    } else {
      const ownerText = 'INSERT INTO person(name, phone) VALUES($1, $2) RETURNING *';
      res = await pool.query(ownerText, ownerValues);

      ctx.status = 201;
    }

    ctx.body = {
      status: 'success',
      data: {
        response: res.rows[0],
      },
    };
  } catch (error) {
    ctx.body = {
      status: 'error',
      data: {
        response: error.detail,
      },
    };
  }
});

router.put('/api/persons/:phone', koaBody(), async (ctx) => {
  try {
    let res;
    const body = ctx.request.body;

    res = await pool.query('UPDATE person SET name = $1 WHERE phone = $2', [body.name, ctx.params.phone]);

    ctx.body = {
      status: 'success',
      data: {
        response: res.rows[0],
      },
    };
  } catch (error) {
    ctx.body = {
      status: 'error',
      data: {
        response: error.detail,
      },
    };
  }
}); 

router.post('/api/plans', koaBody(), async (ctx) => {
  try {
    const body = ctx.request.body;
    // insert plan
    let plan_text;
    let plan_values;
    let people;

    // set parentId for plans with parent
    if (body.parent_id) {
      plan_text = 'INSERT INTO plan(date, time, owner_phone, parentId) VALUES($1, $2, $3, $4) RETURNING id';
      plan_values = [body.date, body.time, body.owner_phone, body.parent_id];
      const personPhones: any = await pool.query('SELECT person_phone, required_person FROM plan_person WHERE plan_id = $1', [body.parent_id]);

      people = personPhones.rows
      .map((person: any) => {
        return {
          phone: person.person_phone,
          required: person.required_person
        };
      })
      .filter((person: any) => {
        return person.phone !== body.owner_phone;
      });
    } else {
      plan_text = 'INSERT INTO plan(name, description, date, time, min_people, owner_phone) VALUES($1, $2, $3, $4, $5, $6) RETURNING id';
      plan_values = [body.name, body.description, body.date, body.time, body.min_people, body.owner_phone];
      people = body.people;          
    }

    const createdPlan = await pool.query(plan_text, plan_values);
    const planId = createdPlan.rows[0].id;

    await pool.query('INSERT INTO plan_person(plan_id, person_phone, answer) VALUES($1, $2, $3)', [planId, body.owner_phone, true]);

    //person
    people.forEach( async (person: {phone: string, required: boolean}) => {
      // insert every person to person table if phone is not registered
      if (!await isPhoneInPersonTable(person.phone)) {
        const text = 'INSERT INTO person(phone) VALUES($1)';
        await pool.query(text, [person.phone]);
      }

      // insert every person to plan_person
      await pool.query('INSERT INTO plan_person(plan_id, person_phone, required_person) VALUES($1, $2, $3)', [planId, person.phone, person.required]);
    });

    ctx.status = 201;
    ctx.body = {
      status: 'success'
    }

  } catch(error) {
    console.log(error);
    
    ctx.body = {
      status: 'error',
      data: {
        response: error.detail
      }
    }
  }
});

router.get('/api/plans', async (ctx) => {
  try {
    const result = await pool.query('SELECT * FROM plan');
    ctx.body = {
      data: {
        result: result.rows
      }
    }
  } catch(error) {
    ctx.body = {
      status: 'error',
      data: {
        response: error.detail
      }
    }
  }
});

router.get('/api/user-plans/:user', async (ctx) => {
  try {
    const resultWithoutParent = await pool.query(`
    SELECT plan_person.*, plan_person_plan.name, plan_person_plan.description, plan_person_plan.id FROM plan_person
    INNER JOIN plan plan_person_plan ON plan_person_plan.id = plan_person.plan_id
    WHERE person_phone = $1 AND plan_person_plan.parentid IS NULL AND NOT owner_phone=$1
    `, [ctx.params.user]);

    const result = await pool.query(`
    SELECT plan_person.*, parent_plan.name, parent_plan.description, parent_plan.id, parent_plan.owner_phone FROM plan_person
    INNER JOIN plan plan_person_plan ON plan_person_plan.id = plan_person.plan_id
    INNER JOIN plan parent_plan ON parent_plan.id = plan_person_plan.parentid
    WHERE person_phone = $1 AND plan_person_plan.parentid IS NOT NULL AND answer IS NULL
    `, [ctx.params.user]);

    const final: any = [];

    [...resultWithoutParent.rows, ...result.rows].forEach((it) => {
      const finded = final.find((it2: any) => {
        return it2.id === it.id;
      });

      if (!finded) {
        final.push(it);
      }
    });

    ctx.body = {
      data: {
        result: final
      }
    }
  } catch(error) {
    console.log(error);
    ctx.body = {
      status: 'error',
      data: {
        response: error.detail
      }
    }
  }
});

// my plans
router.get('/api/plans/user/:phone', koaBody(), async (ctx) => {
  try {
    const result = await pool.query(`SELECT * 
    FROM plan WHERE owner_phone = $1 AND parentid IS NULL`, [ctx.params.phone]);
    ctx.status = 200;
    ctx.body = {
      data: {
        result: result.rows
      }
    }
  } catch(error) {
    ctx.body = {
      status: 'error',
      data: {
        result: error.detail
      }
    }
  }
});

router.get('/api/plans/:id/:user', koaBody(), async (ctx) => {
  try {
    let plan: any = await pool.query(`
    SELECT plan.*, person.name as owner_name FROM plan
    inner join person
    ON plan.owner_phone = person.phone 
    WHERE id = $1`, [ctx.params.id]);

    const parentPlan = plan.rows[0];

    const alternativePlans: any = await pool.query('SELECT * FROM plan WHERE parentId = $1', [ctx.params.id]);
    const ids = [...alternativePlans.rows.map((it: any) => it.id), ctx.params.id];

    const answersPlan = await pool.query(`SELECT 
    answer.plan_id, answer.person_phone, answer.answer, plan.date, plan.time, plan.owner_phone
    FROM plan plan 
    inner join plan_person answer
      on plan.id = answer.plan_id
    WHERE id IN (${ids.join(', ')}) AND answer.person_phone = $1
    `, [ctx.params.user]);

    parentPlan.answers = answersPlan.rows.filter((it) => {
      return !(it.plan_id === Number(ctx.params.id) && parentPlan.owner_phone === ctx.params.user) && !(it.owner_phone ===  ctx.params.user);
    });

/*     await alternativePlans.rows.forEach(async (alternativePlan: any) => {
      const answersAlternativePlan = await pool.query(`
        SELECT answer.plan_id, answer.person_phone, answer.answer, plan.date, plan.time 
        FROM plan plan inner join plan_person answer on plan.id = answer.plan_id WHERE id = $1
      `, [alternativePlan.id]);

      alternativePlan.answers = answersAlternativePlan.rows;
      console.log('answersAlternativePlan.rows', answersAlternativePlan.rows);
    });

    console.log('alternativePlans', alternativePlans.rows);
 */
    ctx.status = 200;
    ctx.body = {
      status: 'success',
      data: {
        result: parentPlan
      }
    }
  } catch(error) {
    console.log(error);
    ctx.body = {
      status: 'error',
      data: {
        response: error.detail
      }
    }
  }
});

router.delete('/api/plans/:id', async (ctx) => {
  try {
    await pool.query('DELETE FROM plan WHERE id = $1', [ctx.params.id]);
    ctx.status = 200;
    ctx.body = {
      status: 'success'
    }
  } catch(error) {
    ctx.body = {
      status: 'error',
      data: {
        response: error.detail
      }
    }
  }
});

router.put('/api/plan_persons', koaBody(), async (ctx) => {
  try {
    const body = ctx.request.body;
    await pool.query('UPDATE plan_person SET answer = $1 WHERE person_phone = $2 AND plan_id = $3', [body.answer, body.phone, body.planId]);
    ctx.status = 200;
    ctx.body = {
      status: 'success'
    }
  } catch(error) {
    ctx.body = {
      status: 'error',
      data: {
        response: error.detail,
      },
    };
  }
});

router.put('/api/deactivate_plan/:id', koaBody(), async (ctx) => {
  try {
    await pool.query('UPDATE plan SET is_active = $1 WHERE id = $2', [false, ctx.params.id]);

    ctx.status = 200;
    ctx.body = {
      status: 'success'
    };
  } catch (error) {
    ctx.body = {
      status: 'error',
      data: {
        response: error.detail,
      },
    };
  }
});

router.put('/api/plans/:id', koaBody(), async (ctx) => {
  try {
    const body = ctx.request.body;

    await pool.query('UPDATE plan SET name = $1, description = $2, date = $3, time = $4, min_people = $5 WHERE id = $6', [body.name, body.description, body.date, body.time, body.min_people, ctx.params.id]);

    const planPersons = await pool.query('SELECT * FROM plan_person WHERE plan_id = $1', [ctx.params.id]);
    body.people.forEach( async (person: {phone: string, required: boolean}) => {

      // insert to new person for this plan in plan_person table
      if (!await isPersonInPlan(ctx.params.id, person.phone)) {
        if (!await isPhoneInPersonTable(person.phone)) {
          const text = 'INSERT INTO person(phone) VALUES($1)';
          await pool.query(text, [person.phone]);
        }
        await pool.query('INSERT INTO plan_person(plan_id, person_phone, required_person) VALUES($1, $2, $3)', [ctx.params.id, person.phone, person.required]);
      } else {
        await pool.query('UPDATE plan_person SET required_person = $1 WHERE plan_id = $2 AND person_phone = $3', [person.required, ctx.params.id, person.phone]);
      }

    });

    planPersons.rows.forEach( async (planPerson: {planId: number, person_phone: string, required_person: boolean, answer: boolean}) => {
      const person = body.people.find((p: {phone: string, required: boolean}) => p.phone === planPerson.person_phone);
      if (!person && !planPerson.answer) {
        await pool.query('DELETE FROM plan_person WHERE plan_id = $1 AND person_phone = $2', [ctx.params.id, planPerson.person_phone]);
      }
    });

    ctx.status = 200;
    ctx.body = {
      status: 'success',
    }

  } catch(error) {
    ctx.body = {
      status: 'error',
      data: {
        response: error.detail,
      },
    };
  }
});

app
  .use(router.routes())
  .use(router.allowedMethods())
  .use(cors())
  .use(koaBody())
  .use(logger())
  .listen(3000);

  async function isPhoneInPersonTable(phone: string) {
    const getPhone = await pool.query('SELECT * FROM person WHERE phone = $1', [phone]);
  
    return !!(getPhone.rowCount > 0);
  }

  async function isPersonInPlan(planId: string, phone: string) {
    const getPersonInPlan = await pool.query('SELECT * FROM plan_person WHERE plan_id = $1 AND person_phone = $2', [planId, phone]);
  
    return !!(getPersonInPlan.rowCount > 0);
  }