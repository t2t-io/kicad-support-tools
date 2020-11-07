import kinparse
nl = kinparse.parse_netlist('tsp4-mcu.net')
for n in nl.nets:
    for p in n.pins:
        if(p.ref == 'U7'):
            print p.num, n.name

