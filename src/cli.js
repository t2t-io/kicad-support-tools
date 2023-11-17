/**
 * Copyright (c) 2019-2023 T2T Inc. All rights reserved
 * 
 *  https://www.t2t.io
 *  https://tic-tac-toe.io
 * 
 * Taipei, Taiwan
 */
'use strict';

const yargs = require('yargs');
const argv = yargs
  .scriptName('kist')
  .commandDir('cmds')
  .demandCommand()
  .help()
  .argv;
