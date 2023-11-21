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
const { parse } = require('csv-parse/sync');
const { PrismaClient } = require('@prisma/client');
const YAML = require('js-yaml');

/*
model Part {
  id           Int      @id @default(autoincrement())
  createdAt    DateTime @default(now())
  updatedAt    DateTime @updatedAt
  design       String   @default("default") // avt22a, ucb24b, ...
  board        String   @default("MB") // the abbreviation of the board, e.g. AVTCM, MB, IOB, ...
  reference    String // the reference on the board, e.g. U1, R2, ...
  designator   String // the designator on the board, e.g. U, R, C, ...
  index        Int // the index value of reference, e.g. 1, 2, 3, ...
  value        String // the value of the part, e.g. 10k, 1uF, ...
  footprint    String // the footprint of the part, e.g. C_0402_1005Metric, L_0603_1608Metric, SOT-23-5
  datasheet    String // the datasheet url, e.g. https://datasheet.octopart.com/CL21B104KCFNNNE-Samsung-Electro-Mechanics-datasheet-136482490.pdf
  furnished_by String // the name of the company that furnished the part, e.g. T2T, EMS, or --
  mfr          String // the manufacturer of the part, e.g. AVX, KEMET, ...
  mpn          String // the manufacturer part number, e.g. 06035C104KAT2A, ...
  octopart     String // the octopart url, e.g. https://octopart.com/search?q=06035C104KAT2A
  spec         String // the spec text
}

Component	References	Quantity Per PCB	Value	Footprint	furnished_by	
mfr	mpn	octopart	spec	LCSC	LCSC Link	digikey	ipn	alternative
*/

function DEBUG_OBJECT(message, object) {
  if (process.env['VERBOSE'] && process.env['VERBOSE'] == "true") {
    console.log(message, object);
  }
}

class PartParser {
  constructor(config) {
    this.config = config;
  }

  parse(row) {
    let { config } = this;
    let { fields } = config;
    let pv = fields.map(f => {
      let { field, default: dft, names } = f;
      let values = names.map(n => row[n]);
      values = values.filter(v => v);
      let value = values[0] || dft;
      value = typeof (value) == 'string' ? value.trim() : value;
      return [field, value];
    });
    let part = Object.fromEntries(pv);
    part.designator = /[A-Za-z]+/.exec(part.reference)[0];  // R19 => R
    part.serial = parseInt(/\d+/.exec(part.reference)[0]);  // R19 => 19
    return part;
  }

}



module.exports = exports = {
  command: "import [csvfile]",
  describe: "import BOM from CSV/TSV file to SQLite database",
  builder: (yargs) =>
    yargs
      .alias('d', 'database_file')
      .describe('d', 'SQLite database file')
      .alias('c', 'config_file')
      .describe('c', 'schema configuration file to parse TSV/CSV file')
      .alias('b', 'board')
      .describe('b', 'abbreviation name of PCB board, e.g. MB, IOB, PB, ...')
      .default('b', 'MB')
      .alias('r', 'design_rev')
      .describe('r', 'design revision, e.g. avt22a, ucb24b, ...')
      .default('r', 'default')
      .alias('t', 'tab')
      .describe('t', 'tab separated')
      .default('t', false)
      .alias('v', 'verbose')
      .describe('v', 'verbose mode')
      .default('v', false)
      .boolean(['t', 'v'])
      .demand(['d', 'b', 'r', 'csvfile']),

  handler: async (args) => {
    DEBUG_OBJECT('args', args);

    const { database_file, config_file, board, design_rev, csvfile, tab, verbose } = args;
    const design = design_rev;

    const config = YAML.load(await fs.readFile(config_file, 'utf8'));
    DEBUG_OBJECT('config', config);
    console.log(`config_file: ${config_file.yellow} loaded`);

    const text = await fs.readFile(csvfile, 'utf8');
    const data = parse(text, { columns: true, delimiter: tab ? '\t' : ',' });
    DEBUG_OBJECT('data', data);
    console.log(`csvfile: ${csvfile.yellow} loaded`);

    const connection_string = `file:${database_file}`;
    console.log(`connection_string: ${connection_string.yellow}`);
    const prisma = new PrismaClient({ datasourceUrl: connection_string });
    await prisma.$connect();
    console.log(`prisma connected`);
    await prisma.part.deleteMany({ where: { board, design } }); // delete all parts with same board and design
    console.log(`delete parts with board: ${board.yellow} and design: ${design.yellow}`);

    let parser = new PartParser(config);
    let rows = data.map(row => {
      let part = parser.parse(row);
      part.board = board;
      part.design = design;
      return part;
    });

    for (let row of rows) {
      let { reference } = row;
      if (verbose) {
        console.log(`${design.gray}#${board.green}: inserting ${reference.yellow}} ...`);
      }
      try {
        await prisma.part.create({ data: row });
      } catch (error) {
        console.log(row);
        console.dir(error);
        process.exit(1);
      }
    }
    console.log(`inserted ${rows.length.toString().blue} parts into database`);
  }

}
