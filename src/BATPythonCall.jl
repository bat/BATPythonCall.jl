# This file is a part of BATPythonCall.jl, licensed under the MIT License (MIT).

"""
    BATPythonCall

Template for Julia packages.
"""
module BATPythonCall

using DensityInterface
using ChainRulesCore
using PythonCall
using BAT

include("pycall_density.jl")


const pycall_ch = Ref(Channel{Tuple{Py,Any,Channel}}())

function __init__()
    pycall_ch[] = Channel{Tuple{Py,Any,Channel}}(4)
    pycall_task = Task(() -> process_pycalls(pycall_ch[]))
    pycall_task.sticky = true
    schedule(pycall_task)
end


end # module
