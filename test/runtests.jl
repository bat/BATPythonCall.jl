# This file is a part of BATPythonCall.jl, licensed under the MIT License (MIT).

import Test

Test.@testset "Package BATPythonCall" begin
    # include("test_aqua.jl")
    include("test_pycall_density.jl")
    include("test_docs.jl")
end # testset
