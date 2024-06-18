module Rulia

export jltrycall, funcfind

function display_buffer(res)
    buf = IOBuffer();
    td = TextDisplay(buf);
    display(td, res);
    String(take!(buf))
end

function funcfind(name; mod::Module = Main)
    r = mod
    ns = split(name, ".")
    for n in ns
        r = getfield(r, Symbol(n))
    end
    r
end

function jltrycall(fname, args, kwargs)
    try
        f = funcfind(fname);
        f(args...; kwargs...);
    catch e
        e #showerror(stdout,e)
    end;
end

function jltryfunc(f, args, kwargs)
    try
        f(args...; kwargs...);
    catch e
        e #showerror(stdout,e)
    end;
end

end