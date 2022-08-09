# This file is a part of BATPythonCall.jl, licensed under the MIT License (MIT).


function pyconvert_put!(ch::Channel{T}, py_x) where T
    x = pyconvert(T, py_x)
    put!(ch, x)
end

function process_pycalls(ch::Channel{Tuple{Py,Any,Channel}})
    while isopen(ch)
        @assert Base.Threads.threadid() == 1
        f, x, reply_ch = take!(ch)
        py_x = Py(x)
        py_y = f(py_x)
        pyconvert_put!(reply_ch, py_y)
    end
end


function threadsafe_pycall(f, x, ::Type{R}) where R
    reply_ch = Channel{R}(1)
    put!(pycall_ch[], (f, x, reply_ch))
    take!(reply_ch)::R
end
    


"""
    struct PyCallDensityWithGrad <: BAT.BATDensity

Constructors:

```julia
    PyCallDensityWithGrad(logf, valgradlogf)
```
"""
struct PyCallDensityWithGrad <: BAT.BATDensity
    logf::PythonCall.Py
    valgradlogf::PythonCall.Py
end

export PyCallDensityWithGrad


function DensityInterface.logdensityof(density::PyCallDensityWithGrad, x::AbstractArray{<:Real})
    threadsafe_pycall(density.logf, x, Float64)::Float64
end


function ChainRulesCore.rrule(::typeof(DensityInterface.logdensityof), density::PyCallDensityWithGrad, x::AbstractArray{<:Real})
    logd, gradlogd = threadsafe_pycall(density.valgradlogf, x, Tuple{Float64,Vector{Float64}})::Tuple{Float64,Vector{Float64}}
    @assert logd isa Real
    function pcdwg_pullback(thunked_ΔΩ)
        ΔΩ = ChainRulesCore.unthunk(thunked_ΔΩ)
        @assert ΔΩ isa Real
        tangent = gradlogd * ΔΩ
        (NoTangent(), ZeroTangent(), tangent)
    end
    return logd, pcdwg_pullback
end

BAT.vjp_algorithm(density::PyCallDensityWithGrad) = BAT.ZygoteAD()
