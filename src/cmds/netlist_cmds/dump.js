/**
 * Copyright (c) 2019-2023 T2T Inc. All rights reserved
 * 
 * https://www.t2t.io
 * https://tic-tac-toe.io
 * Taipei, Taiwan
 */
'use strict';

const { promises: fs, write } = require('fs');
const path = require('path');
const { stringify } = require('csv-stringify/sync');
const YAML = require('js-yaml');

module.exports = exports = {
  command: "dump",
  describe: "dump all data",
  builder: (yargs) =>
    yargs
      .alias('u', 'user')
      .describe('u', 'user name to login MySQL server')
      .default('u', 'root')
      .demand(['u']),

  handler: async (args) => {
    console.log(`dumping all data for netlist...!!`);
    console.log(args);
    return;
  }
}
