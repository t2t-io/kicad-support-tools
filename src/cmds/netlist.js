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
  command: "netlist [subcommand]",
  describe: "run netlist-related actions (subcommands)",
  builder: (yargs) => {
    return yargs
      .commandDir('netlist_cmds')
      .demandCommand()
      .help();
  }
}
