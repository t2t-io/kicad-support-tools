require! <[debug path fs colors]>
{NetlistParser} = require \../helpers/netlist-parser
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
  command: "bom <netlist>"
  describe: "generate bom script from the netlist file exported from kicad"

  builder: (yargs) ->
    yargs
      .example '$0 bom ', 'generate bom script from the netlist file exported from kicad'
      .alias \o, \outputDir
      .default \o, \-
      .describe \o, "output directory for generated BOM files"
      .alias \f, \fields
      .default \f, ""
      .describe \f, "extra fields/properties to be retrieved from bom file, e.g. mfr,mpn,furnished_by"
      .alias \a, \alias
      .default \a, null
      .describe \a, "field name alias"
      .alias \v, \verbose
      .default \v, no
      .describe \v, "verbose output"
      .boolean 'v'
      .demand <[o v]>


  handler: (argv) ->
    {config} = global
    {outputDir, alias} = argv
    global.verbose = argv.verbose
    TRACE "args: #{(JSON.stringify argv).gray}"
    DBG "verbose = #{verbose}"
    DBG "checking #{argv.netlist} ..."
    (err0, fstats) <- fs.stat argv.netlist
    return ERR_EXIT "failed to find netlist file #{argv.netlist}", err0 if err0?
    return ERR_EXIT "#{argv.netlist} is not a file" unless fstats.isFile!
    DBG "checking #{outputDir} ..."
    (err1, dstats) <- fs.stat outputDir
    return ERR_EXIT "no such output directory: #{outputDir}", err1 if err1?
    return ERR_EXIT "#{outputDir} is not a directory" unless dstats.isDirectory!
    DBG "reading #{argv.netlist} ..."
    (err2, buffer) <- fs.readFile argv.netlist
    return ERR_EXIT "failed to read netlist file #{argv.netlist}", err2 if err2?
    text = buffer.toString!
    alias = READ_AS_JSON argv.alias if alias?
    p = new NetlistParser {}, alias, text, (argv.netlist.endsWith '.json')
    {components} = p
    fields = <[id designator rid ref value footprint sheetpath datasheet]>
    fields = fields ++ (argv.fields.split ',')
    data = [ (c.get_field_values fields) for c in components ]
    data = [fields] ++ data
    (err, output) <- CSVIZE data, {quoted_string: yes}
    return ERR_EXIT "failed to generate csv string for the given field data", err if err?
    console.log output