require! <[debug path fs colors]>
{Buffer} = require \buffer
TRACE = -> return console.error.apply null, arguments if global.verbose


ERR_EXIT = (message, err=null) ->
  console.error message
  console.dir err if err?
  return process.exit 1


module.exports = exports =
  command: "check <netlist>"
  describe: "check netlist before converting to json"

  builder: (yargs) ->
    yargs
      .example '$0 check ', 'check netlist before converting to json'
      .alias \v, \verbose
      .default \v, no
      .describe \v, "verbose output"
      .boolean 'v'
      .demand <[v]>


  handler: (argv) ->
    {config} = global
    {netlist} = argv
    global.verbose = argv.verbose
    TRACE "args: #{(JSON.stringify argv).gray}"
    (ferr, buffer) <- fs.readFile netlist
    return ERR_EXIT "failed to read #{netlist}", ferr if ferr?
    TRACE "read #{buffer.length} bytes from #{netlist}"
    text = buffer.toString!
    TRACE "text #{text.length} bytes from #{netlist}"
    lines = text.split '\n'
    module.warnings = no
    name = path.basename netlist
    for let line, i in lines
      y = i.toString! .cyan
      token = '\\"'
      xs = line.split token
      token = token.red
      if xs.length > 1
        xs = [ x.gray for x in xs ]
        console.log "#{name}##{y}: detects DoubleQuote character => #{xs.join token}"
        module.warnings = module.warnings + 1
    for let line, i in lines
      y = i.toString! .cyan
      token = '\\\''
      xs = line.split token
      token = token.yellow
      if xs.length > 1
        xs = [ x.gray for x in xs ]
        console.log "#{name}##{y}: detects SingleQuote character => #{xs.join token}"
        module.warnings = module.warnings + 1
    for let line, i in lines
      y = i.toString! .cyan
      bytes = Buffer.from line
      if bytes.length != line.length
        module.index = -1
        for let b, j in bytes
          if b >= 128
            if module.index is -1
              module.index = j
        if module.index != -1
          {index} = module
          prefix = line.substring 0, index
          c = line[index].magenta
          postfix = line.substring index + 1
          console.log "#{name}##{y}: detect non-ascii character(s) => #{prefix.gray}#{c}#{postfix.gray}"
    return process.exit 1 if module.warnings > 0
    return process.exit 0
