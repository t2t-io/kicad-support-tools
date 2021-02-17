require! <[debug path fs colors]>
{NetlistParser} = require \../helpers/netlist-parser
{SqlManager} = require \../helpers/sql-mgr
CSVIZE = require \csv-stringify
DBG = debug 'netlist/bom'
TRACE = -> return console.error.apply null, arguments if global.verbose


READ_AS_JSON = (filepath) ->
  buffer = fs.readFileSync filepath
  throw new Error "failed to read #{filepath}" unless buffer?
  text = buffer.toString!
  json = JSON.parse text
  return json


ERR_EXIT = (message, err=null) ->
  console.error message
  console.dir err if err?
  return process.exit 1


module.exports = exports =
  command: "sql <query>"
  describe: "perform SQL query on netlist file, and output csv/tsv"

  builder: (yargs) ->
    yargs
      .example '$0 sql ', 'generate bom script from the netlist file exported from kicad'
      .alias \o, \output
      .default \o, \-
      .describe \o, "output csv or tsv for the performed query"
      .alias \n, \netlist
      .default \n, null
      .describe \n, "netlist file path"
      .alias \a, \alias
      .default \a, null
      .describe \a, "field name alias"
      .alias \v, \verbose
      .default \v, no
      .describe \v, "verbose output"
      .boolean 'v'
      .demand <[n o v]>


  handler: (argv) ->
    {config} = global
    {output, alias, query} = argv
    global.verbose = argv.verbose
    TRACE "args: #{(JSON.stringify argv).gray}"
    DBG "verbose = #{verbose}"
    DBG "checking #{argv.netlist} ..."
    (err0, fstats) <- fs.stat argv.netlist
    return ERR_EXIT "failed to find netlist file #{argv.netlist}", err0 if err0?
    return ERR_EXIT "#{argv.netlist} is not a file" unless fstats.isFile!
    DBG "reading #{argv.netlist} ..."
    (err2, buffer) <- fs.readFile argv.netlist
    return ERR_EXIT "failed to read netlist file #{argv.netlist}", err2 if err2?
    text = buffer.toString!
    alias = READ_AS_JSON argv.alias if argv.alias?
    p = new NetlistParser {}, alias, text, (argv.netlist.endsWith '.json')
    s = new SqlManager {}, query
    (serr, results) <- s.load_and_run p
    return ERR_EXIT "failed to perform query", serr if serr?
    DBG "done."
    {columns, rows} = results
    header = yes
    quoted_string = yes
    (cerr, text) <- CSVIZE rows, {columns, header, quoted_string}
    return ERR_EXIT "failed to generate CSV", cerr if cerr?
    return console.log text if output is '-'
    (werr) <- fs.writeFile output, text
    return ERR_EXIT "failed to write #{output}", werr if werr?
    TRACE "write #{text.length} bytes to #{output}"

##
#
# [todo]
#   1. Use `console-table-printer` (https://www.npmjs.com/package/console-table-printer) to
#      print the csv to console in pretty way.
#