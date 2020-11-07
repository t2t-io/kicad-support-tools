// a minimal parser for pcb netlist
// for kicad 5.x
// (c) t2t.io

module.exports = function(lns){
    
  lns = lns.slice(lns.indexOf('(nets'))
  lns = lns.split('\n')
  lns = lns.map( i => i.trim())

  var parsed = [];

  lns.shift();
  var ln = lns.shift();

  const { match } = require('assert');
  var bl = require('balanced-match')
  function matchp(s){
    return bl('(', ')', s)
  }

  while(1){
    if(ln.startsWith('(net')){
      var firstm = matchp(ln)
      let code = firstm.body.slice(5)
      let name = matchp(firstm.post).body.slice(5)
      let neo = {
        code: code, // /code [^)]+/.exec(ln)[0].slice(5),
        name: name,  // /name [^)]+/.exec(ln)[0].slice(5),
        nodes: []
      }
      while(1){
        ln = lns.shift();
        if(ln.startsWith('(node')){
          firstm = matchp(ln.slice(4))  //remove the leadin '(' to make imbalalanced!
          let ref = firstm.body.slice(4)
          let pin = matchp(firstm.post).body.slice(4)
          neo.nodes.push({
            ref: ref, // /ref [^)]/.exec(ln)[0].slice(4),
            pin: pin, // /pin [^)]/.exec(ln)[0].slice(4),
          })
        }else{
          parsed.push(neo);
          break;
        }
      }
    }else{
      //console.log('break for no consecutive net');
      //console.log(JSON.stringify(parsed) );
      return parsed;
    }
  }
}