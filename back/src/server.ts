import cors from '@koa/cors';
import Router from '@koa/router';
import Koa from 'koa';
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
    // check if  the phone exists in attendee
    const body = ctx.request.body;
    const owner_text = 'INSERT INTO attendee(name, phone) VALUES($1, $2) RETURNING *';
    const owner_values = [body.name, body.phone];
    const res = await pool.query(owner_text, owner_values);

    ctx.status = 201;
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
  const body = ctx.request.body

  // insert every attendee to attendee
  

  // insert mandatory attendees

  // insert plan
  const plan_text = 'INSERT INTO plan(name, description, date, time, min_attendees) VALUES($1, $2, $3, $4, $5) RETURNING *';
  const plan_values = [body.name, body.description, body.date, body.time, body.min_attendees];

  await pool.query(plan_text, plan_values);
  
  // insert answers


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