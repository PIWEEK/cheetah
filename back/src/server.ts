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
      min_people: 0
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

router.post('/create/plan', koaBody(), async (ctx) => {
  try {
    const body = ctx.request.body

    // insert plan
    const plan_text = 'INSERT INTO plan(name, description, date, time, min_people, owner_phone) VALUES($1, $2, $3, $4, $5, $6) RETURNING id';
    const plan_values = [body.name, body.description, body.date, body.time, body.min_people, body.owner_phone];

    const createdPlan = await pool.query(plan_text, plan_values);
    console.log('createdPlannnnnnn ID------>', createdPlan.rows[0].id);

    // set owner answer
    await pool.query('INSERT INTO plan_person(plan_id, person_phone, answer) VALUES($1, $2, $3)', [createdPlan.rows[0].id, body.owner_phone, true]);

    //person
    body.people.forEach( async (person: any) => {
      // insert every person to plan_person
      await pool.query('INSERT INTO plan_person(plan_id, person_phone, required_person) VALUES($1, $2)', [createdPlan.rows[0].id, person.phone, person.required]);

      // insert every person to person table if phone is not registered
      // !!!!!!!!!!!!!!
      if (!await isPhoneInPersonTable(person)) {
        const text = 'INSERT INTO person(phone) VALUES($1)';
        await pool.query(text, [person]);
      }
    });
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

  async function isPhoneInPersonTable(phone: string) {
    const getPhone = await pool.query('SELECT * FROM person WHERE phone = $1', [phone]);
  
    return !!(getPhone.rowCount > 0);
  }