# This file is a part of BATPythonCall.jl, licensed under the MIT License (MIT).

using BATPythonCall
using Test

using BAT, ValueShapes, DensityInterface
using PythonCall
using InverseFunctions
using Zygote


@testset "pycall_density" begin
    numpy = pyimport("numpy")

    pyexec("""
    import numpy
    
    def loglike(x):
        return -0.5 * numpy.dot(x, x)
    
    def loglike_with_grad(x):
        return (loglike(x), -x)
    """,
    Main)
    
    pyloglike, pyloglike_with_grad = pyeval("""(loglike, loglike_with_grad)""", Main)
    
    
    x = rand(3)
    
    pyloglike(x)
    pyloglike_with_grad(x)
    
    likelihood = PyCallDensityWithGrad(pyloglike, pyloglike_with_grad)
    @inferred logdensityof(likelihood)(x)
    
    # For comparison:
    #likelihood = BAT.LFDensityWithGrad(x -> - 0.5 * dot(x,x), x -> (- 0.5 * dot(x,x), -x))
    
    @inferred Zygote.gradient(logdensityof(likelihood), x)
    y, back = Zygote.pullback(logdensityof(likelihood), x)
    @inferred back(1)
    
    using Distributions, ValueShapes, LinearAlgebra
    prior = MvNormal(Diagonal(fill(1.0, 3)))
    
    posterior = PosteriorMeasure(likelihood, prior)
    
    logdensityof(posterior)(x)
    BAT.valgradof(logdensityof(posterior))(x)
    
    target, trafo = bat_transform(PriorToGaussian(), posterior)
    
    inverse(trafo)(trafo(rand(prior)))
    
    bat_findmode(posterior, NelderMeadOpt())
    bat_findmode(posterior, LBFGSOpt())
    
    # bat_sample(posterior, MCMCSampling(mcalg = MetropolisHastings()))
    bat_sample(posterior, MCMCSampling(mcalg = HamiltonianMC()))
end
