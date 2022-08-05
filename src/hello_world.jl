# This file is a part of BATPythonCall.jl, licensed under the MIT License (MIT).


"""
    BATPythonCall.hello_world()

Prints "Hello, World!" and returns 42.

```jldoctest
using BATPythonCall

BATPythonCall.hello_world()

# output

Hello, World!
42
```
"""
function hello_world()
    println("Hello, World!")
    return 42
end
