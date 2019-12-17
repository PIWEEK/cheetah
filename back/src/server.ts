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
  console.log('--------------------');
  console.log(ctx);
  console.log(ctx.request.body);

  ctx.status = 201;
  ctx.body = {
    status: 'success',
    data:  {
      name: `bien`,
    }
  };
})

pool.query(fs.readFileSync(path.resolve(__dirname, '../src/tables.sql'), 'utf8'));

router.get('/', async (ctx) => {
  const result = await pool.query('SELECT NOW()');

  ctx.body = {
    text: `Hello World ${result.rows[0].now}`,
  };
});

app
  .use(router.routes())
  .use(router.allowedMethods())
  .use(cors())
  .use(koaBody())
  .use(logger())
  .listen(3000);