# Use
#
#     DOCUMENTER_DEBUG=true julia --color=yes make.jl local [nonstrict] [fixdoctests]
#
# for local builds.

using Documenter
using BATPythonCall

# Doctest setup
DocMeta.setdocmeta!(
    BATPythonCall,
    :DocTestSetup,
    :(using BATPythonCall);
    recursive=true,
)

makedocs(
    sitename = "BATPythonCall",
    modules = [BATPythonCall],
    format = Documenter.HTML(
        prettyurls = !("local" in ARGS),
        canonical = "https://bat.github.io/BATPythonCall.jl/stable/"
    ),
    pages = [
        "Home" => "index.md",
        "API" => "api.md",
        "LICENSE" => "LICENSE.md",
    ],
    doctest = ("fixdoctests" in ARGS) ? :fix : true,
    linkcheck = !("nonstrict" in ARGS),
    strict = !("nonstrict" in ARGS),
)

deploydocs(
    repo = "github.com/bat/BATPythonCall.jl.git",
    forcepush = true,
    push_preview = true,
)
