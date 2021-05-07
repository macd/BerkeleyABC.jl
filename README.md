# BerkeleyABC

A Julia wrapper around, and a few tests for, the Berkeley ABC logic synthesis 
and verification program.

### Using ABC

The ABC package exports only four functions start_abc, end_abc, restart_abc,
and parse_timing.  Both start_abc and restart_abc return a function which takes 
a string version of a command to the ABC shell. The command returns a tuple of the
status and the string that would have been printed to the console. For example

    using ABC
    abc_cmd = start_abc()
    res = abc_cmd("read_blif cla_32.blif")
    
which results in

    (0, ["Hierarchy reader flattened 32 instances of logic boxes and left 0 black boxes."])
    
we can then do

    # read in a standard cell library
    res = abc_cmd("read_lib Nangate45_typ.lib")
    # run a simple area based script
    res = abc_cmd("&get; &st; &dch; &nf; &put; ps; stime -p")
    
Notice that the last command above was `stime` which runs ABCs delay tracer on the design.
We can then run `parse_timing` on the result to find out

    parse_timing(res)
    
which gives a named tuple `(gates = 157, area = 191.79, delay = 1181.52)`
    
### Installing ABC

Just the usual `] add ABC` using the package manager.

### Further documentation

For further information on the ABC logic synthesis system, please see
https://github.com/berkeley-abc/abc

