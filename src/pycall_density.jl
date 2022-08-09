# This file is a part of BATPythonCall.jl, licensed under the MIT License (MIT).


const g_pythoncall_lock = ReentrantLock()


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
    GC.@preserve x try
        lock(g_pythoncall_lock)
        py_x = Py(x).to_numpy()
        pyconvert(Float64, density.logf(py_x))::Float64
    finally
        unlock(g_pythoncall_lock)
    end
end


function ChainRulesCore.rrule(::typeof(DensityInterface.logdensityof), density::PyCallDensityWithGrad, x::AbstractArray{<:Real})
    logd, gradlogd = GC.@preserve x try
        lock(g_pythoncall_lock)
        py_x = Py(x).to_numpy()
        pyconvert(Tuple{Float64,Vector{Float64}}, density.valgradlogf(py_x))::Tuple{Float64,Vector{Float64}}
    finally
        unlock(g_pythoncall_lock)
    end
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
