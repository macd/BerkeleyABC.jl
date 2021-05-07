module BerkeleyABC
using ABC_jll

export start_abc, stop_abc, restart_abc, parse_timing

function start_abc(;load_aliases=true)
    ccall((:Abc_Start, libabc), Cvoid, ())
    pAbc = ccall((:Abc_FrameGetGlobalFrame, libabc), Ptr{UInt}, ())
    abc_cmd(cmd) = ccall((:Cmd_CommandExecute, libabc), Int, (Ptr{Int}, Cstring), pAbc, cmd)
    if load_aliases
        abc_cmd("source $(abc_rc)")
    end
    function cmd(args)
        status = 0
        res = ""
        mktemp() do _, io
            redirect_stdout(io)
            status = abc_cmd(args)
            Base.Libc.flush_cstdio()
            seek(io, 0)
            res = readlines(io)
        end
        return status, res
    end
end

function stop_abc()
    ccall((:Abc_Stop, libabc), Cvoid, ())
end

function restart_abc()
    stop_abc()
    start_abc()
end

# So yeah, kinda brittle parsing of the abc stime command
function parse_timing((st, res))
    if st != 0
        println("Error parsing timing: bad ABC result")
        return
    end
    # first find the correct line to parse
    line = ""
    for outer line in res
        all(occursin.(["Gates", "Area", "Delay"], (line,))) && break
    end

    toks = filter(!=(""), split(line, r"[ =]"))
    g, a, d = findfirst.(contains.(["Gates", "Area", "Delay"]), (toks,))

    gates = 0
    area = delay = 0.0

    try
        gates = parse(Int, split(toks[g+1], '\e')[1])
        area  = parse(Float64, split(toks[a+1], '\e')[1])
        delay = parse(Float64, split(toks[d+1], '\e')[1])
    catch
        println("Parsing area and delay failed on the following line:")
        println(res[1])
        println(toks)
    end
    
    (gates=gates, area=area, delay=delay)
end

end
