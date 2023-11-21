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

module.exports = exports = {
  command: "bom [subcommand]",
  describe: "run bom-related actions (subcommands)",
  builder: (yargs) => {
    return yargs
      .commandDir('bom_cmds')
      .demandCommand()
      .help();
  }
}
