# This file is a part of BATPythonCall.jl, licensed under the MIT License (MIT).

import Test
import Aqua
import BATPythonCall

Test.@testset "Aqua tests" begin
    Aqua.test_all(BATPythonCall)
end # testset
