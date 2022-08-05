# This file is a part of BATPythonCall.jl, licensed under the MIT License (MIT).

using Test
using BATPythonCall
import Documenter

Documenter.DocMeta.setdocmeta!(
    BATPythonCall,
    :DocTestSetup,
    :(using BATPythonCall);
    recursive=true,
)
Documenter.doctest(BATPythonCall)
