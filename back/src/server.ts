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

router.get('/mock/plan/:id', async (ctx) => {
  ctx.status = 200;
  console.log(ctx.params.id);

  ctx.body = {
    data: {
      id: 0,
      name: 'plan 1',
      descripcion: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus dignissim mattis purus, et aliquet enim vestibulum in. Praesent quis dui interdum, feugiat nisi posuere, porttitor risus. Phasellus sit amet enim egestas, dapibus nulla eu, finibus ipsum. In sit amet augue neque. Maecenas tincidunt a arcu eu dapibus. Quisque gravida tortor at rutrum finibus. Nullam ac molestie ante. Ut ac congue erat. Sed nisi purus, gravida a nisl et, euismod vestibulum metus. Pellentesque commodo porta viverra. Maecenas venenatis congue lacus, in viverra lorem tincidunt eget.',
      date: new Date().toUTCString(),
      time: '12:00',
      answers: [
        {
          plan_id: 1,
          anwer: true,
          date: new Date().toUTCString(),
          time: '12:00'
        },
        {
          plan_id: 2,
          anwer: false,
          date: new Date().toUTCString(),
          time: '12:30'
        },
        {
          plan_id: 3,
          anwer: true,
          date: new Date().toUTCString(),
          time: '22:00'
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

router.post('/register', koaBody(), async (ctx) => {
  try {
    let res;
    const body = ctx.request.body;
    const owner_values = [body.name, body.phone];
    if(await isPhoneInPersonTable(body.phone)) {
      res = await pool.query('UPDATE person SET name = $1 WHERE phone = $2', owner_values);
    } else {
      const owner_text = 'INSERT INTO person(name, phone) VALUES($1, $2) RETURNING *';
      res = await pool.query(owner_text, owner_values);
  
      ctx.status = 201;
    }

    ctx.body = {
      status: 'success',
      data: {
        response: res.rows[0]
      }
    }
  } catch (error) {
    ctx.body = {
      status: 'error',
      data: {
        response: error.detail
      }
    }
  }
});

router.post('/api/plans', koaBody(), async (ctx) => {
  try {
    const body = ctx.request.body

    // insert plan
    const plan_text = 'INSERT INTO plan(name, description, date, time, min_people, owner_phone) VALUES($1, $2, $3, $4, $5, $6) RETURNING id';
    const plan_values = [body.name, body.description, body.date, body.time, body.min_people, body.owner_phone];

    const createdPlan = await pool.query(plan_text, plan_values);
    const planID = createdPlan.rows[0].id;

    // set owner answer
    await pool.query('INSERT INTO plan_person(plan_id, person_phone, answer) VALUES($1, $2, $3)', [planID, body.owner_phone, true]);

    //person
    body.people.forEach( async (person: {phone: string, required: boolean}) => {

      // insert every person to person table if phone is not registered
      if (!await isPhoneInPersonTable(person.phone)) {
        const text = 'INSERT INTO person(phone) VALUES($1)';
        await pool.query(text, [person.phone]);
      }

      // insert every person to plan_person
      await pool.query('INSERT INTO plan_person(plan_id, person_phone, required_person) VALUES($1, $2, $3)', [planID, person.phone, person.required]);
    });

    ctx.status = 201;
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

router.get('/api/plans', async (ctx) => {
  try {
    const result = await pool.query('SELECT * FROM plan');
    ctx.body = {
      data: {
        result: result.rows[0]
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

router.get('/api/plans/:id', koaBody(), async (ctx) => {
  try {
    const result = await pool.query('SELECT * FROM plan WHERE id = $1', [ctx.params.id]);

    ctx.status = 201;
    ctx.body = {
      status: 'success',
      data: {
        result: result.rows[0]
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