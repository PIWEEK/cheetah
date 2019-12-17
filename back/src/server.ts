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
      min_attendees: 0
    }
  };
});

router.post('/mock/create-user', koaBody(), async (ctx) => {
  console.log(ctx.request.body);
  /*
  {
    name: xx,
    phone: 60000000
  }
  */

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

    if(isPhoneInAttendees(body.phone)) {
      res = await pool.query('UPDATE attendee SET name = $1 WHERE phone = $2', owner_values);
    } else {
      const owner_text = 'INSERT INTO attendee(name, phone) VALUES($1, $2) RETURNING *';
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

router.post('/create/plan', koaBody(), async (ctx) => {
  try {
    const body = ctx.request.body

    // insert plan
    const plan_text = 'INSERT INTO plan(name, description, date, time, min_attendees, owner_phone) VALUES($1, $2, $3, $4, $5, $6) RETURNING id';
    const plan_values = [body.name, body.description, body.date, body.time, body.min_attendees, body.owner_phone];

    const createdPlan = await pool.query(plan_text, plan_values);
    console.log('createdPlannnnnn------>', createdPlan);

    // set owner answer
    await pool.query('INSERT INTO answer(plan_id, attendee_phone) VALUES($1, $2)', [createdPlan.rows[0].id, body.owner_phone]);

    //attendees
    body.attendees.forEach( async (attendee: any) => {
      // insert every attendee to plan_attendee
      await pool.query('INSERT INTO plan_attendee(plan_id, attendee_phone) VALUES($1, $2)', [createdPlan.rows[0].id, attendee]);

      // insert every attendee to attendee if phone is not registered
      if (!isPhoneInAttendees(attendee)) {
        const text = 'INSERT INTO attendee(phone) VALUES($1)';
        await pool.query(text, [attendee]);
      }

      // insert answers
      await pool.query('INSERT INTO answer(plan_id, attendee_phone) VALUES($1, $2)', [createdPlan.rows[0].id, attendee]);
    });

    // insert mandatory attendees
    if (body.mandatory) {
      body.mandatory.forEach( async (attendee: any) => {
        await pool.query('INSERT INTO required_attendee(plan_id, attendee_phone) VALUES($1, $2)', [createdPlan.rows[0].id, attendee]);
      });
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

router.get('/plans', async (ctx) => {
  const result = await pool.query('SELECT * FROM plan');
  ctx.body = {
    data: {
      result: result.rows[0]
    }
  }
});

router.get('/plan/:id', koaBody(), async (ctx) => {
  try {
    const body = ctx.request.body
    const result = await pool.query('SELECT * FROM plan WHERE id = $1', [body.id]);

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

  async function isPhoneInAttendees(phone: string) {
    const getPhone = await pool.query('SELECT * FROM attendee WHERE phone = $1', [phone]);
  
    return !!(getPhone.rowCount > 0);
  }