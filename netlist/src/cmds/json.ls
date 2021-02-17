require! <[debug path fs colors]>
SExpr = require \js-sexpr
TRACE = -> return console.error.apply null, arguments if global.verbose


ERR_EXIT = (message, err=null) ->
  console.error message
  console.dir err if err?
  return process.exit 1


module.exports = exports =
  command: "json <netlist>"
  describe: "convert netlist file from s-expression format to json format"

  builder: (yargs) ->
    yargs
      .example '$0 json ', 'convert netlist file from s-expression format to json format'
      .alias \o, \output
      .default \o, null
      .describe \o, "output json file; when it's not specified, output json to the file with same netlist filename ended with `.json`"
      .alias \v, \verbose
      .default \v, no
      .describe \v, "verbose output"
      .boolean 'v'
      .demand <[v]>


  handler: (argv) ->
    {config} = global
    {output, netlist} = argv
    output = "#{netlist}.json" unless output?
    global.verbose = argv.verbose
    TRACE "args: #{(JSON.stringify argv).gray}"
    (ferr, buffer) <- fs.readFile netlist
    return ERR_EXIT "failed to read #{netlist}", ferr if ferr?
    TRACE "read #{buffer.length} bytes from #{netlist}"
    text = buffer.toString!
    se = new SExpr!
    json = se.parse text
    TRACE "parsed"
    text = JSON.stringify json, null, '  '
    TRACE "serialized, total #{text.length} bytes"
    return console.log text if output is '-'
    (werr) <- fs.writeFile output, text
    return ERR_EXIT "failed to write #{output}", werr if werr?
    TRACE "write #{text.length} bytes to #{output}"
