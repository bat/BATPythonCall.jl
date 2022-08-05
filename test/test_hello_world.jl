# This file is a part of BATPythonCall.jl, licensed under the MIT License (MIT).

using BATPythonCall
using Test


@testset "hello_world" begin
    @test BATPythonCall.hello_world() == 42
end
