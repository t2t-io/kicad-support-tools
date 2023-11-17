#!/usr/bin/env node
/**
 * Copyright (c) 2019-2023 T2T Inc. All rights reserved
 * 
 *  https://www.t2t.io
 *  https://tic-tac-toe.io
 * 
 * Taipei, Taiwan
 */
'use strict';

const { promises: fs } = require("fs");
const { setTimeout: sleep } = require('timers/promises');
const colors = require('colors');
const YAML = require('js-yaml');

(async function () {
  /*
  let config_file_path = null;
  let config_data = null;
  let config = null;
  try {
    config_file_path = process.env.CONFIG_FILE_PATH || `${__dirname}/config/default.yml`;
    config_data = await fs.readFile(config_file_path, 'utf8');
    config = YAML.load(config_data.toString());
    console.error(`\nloaded ${config_file_path.green}\n`);
  } catch (error) {
    console.error(`failed to load ${config_file_path}`.red);
  }

  global.context = {
    config: config,
    top_dir: __dirname,
    data_dir: `${__dirname}/data`,
  };
  */
  console.log(`\n${__filename} is running...\n`);
  let cli = require('./src/cli');
})();
