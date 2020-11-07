const fs = require('fs')
const np = require('./np') 
const process = require('process')

var nl = np(fs.readFileSync('tsp4-mcu.net', 'utf8')) 
var COI = process.argv[2] //'U7'
// find every net directly connecting to U7
//var dl = nl.filter( e => {
    //return e.nodes.filter(f => f.ref == COI).length > 0;
//})
var dl = [], el = [];
nl.forEach( e => {
  if(e.nodes.filter(f => f.ref == COI).length > 0)
    dl.push(e)
  else
    el.push(e)
})

//console.log(JSON.stringify(dl, null,2 ))
var pins = {}
dl.forEach(i => {
   i.nodes.forEach(j=>{
      if(j.ref == COI) {
        if(i.nodes.length >1 )
            pins[j.pin] = i.name
        else
            pins[j.pin] = 'NC'
      }
   }) 
})

Object.entries(pins).forEach( p =>{
  let k = p[0]
  let v = p[1]

  if(v.indexOf('Net-')>0){
    dl.filter( e => e.name == v ).forEach( n =>{
      n.nodes.filter( ne => ne.ref != COI).forEach( m => {
        //console.log('other components to trace: '+JSON.stringify(m) );
        let indirectNet = netsContaining(nl, m.ref).map( p => p.name).filter( n=> n != v) 
        //console.log(indirectNet); 
        pins[k]= /*v+ ' | ' + */ m.ref+ ' | ' +indirectNet;
      })
    })
  }
})

console.log(pins)

function netsContaining(netlist, symbol){
  return netlist.filter( n => n.nodes.filter( m => m.ref == symbol).length > 0)
}
