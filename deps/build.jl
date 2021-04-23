# QuEST.jl/deps/build.jl
#
# Authors:
#  - Anabel Ovide, Uni Tartu
#  - Alejandro Villoria, Uni Tartu
#  - Dirk Oliver Theis, Ketita Labs & Uni Tartu
#
# MIT License
#
# (c) Ketita Labs, Uni Tartu, and the authors.
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation files
# (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

#
# This script builds the package.
#

"""
True, if expert installation has been selected.  This variable changes the behavior of the
function `_auxBuild():
- if false, QuEST is built (cmake, make etc)
- if true, QuEST is not built.

In any case: QuEST is downloaded, and the C-interface is generated from the `.h`-files.
"""
const EXPERT_BUILD = haskey(ENV, "QUEST_JL_EXPERT_BUILD")



using Clang.Generators

"""
Function `_bits_string()`

Transforms the precision *code* (1,2,4,...) to the number of bits as a string
("32,"64","2983",...).
"""
function _bits_string(;precision_code::Int) ::String
    @assert precision_code ∈ [1,2]
    precision_code==1  && return "32"
    precision_code==2  && return "64"
end

"""
Function `clang_from_h()` — Use Clang.jl to auto-generate C-interface frome `.h`-files

# Arguments:

"""
function _clang_from_h(makePrecision ::Int ; quest_root::String, isWindows ::Bool) ::Nothing
    precision = _bits_string(precision_code=makePrecision)

    questclang_include = joinpath(quest_root,"QuEST","include") |> normpath
    questclang_headers = [ joinpath(questclang_include,header)   for header in ["QuEST.h","QuEST_precision.h"] ] # ?readdir(questclang_include) if endswith(header, ".h")]

    options = Dict(
        "general"=>Dict(
            "library_name"=>"questclang",
            "output_file_path"=>joinpath(@__DIR__, "questclang_"*precision*".jl"),
        )
    )

    args = ["-I"*joinpath(questclang_include, ".."), "-DQuEST_PREC=$(makePrecision)"]

    ctx = create_context(questclang_headers, args, options)

    build!(ctx)
end




"""
Execute commands to build QuEST
"""
function _auxBuild(makePrecision ::Int ; isWindows ::Bool) ::Nothing
    precision = _bits_string(precision_code=makePrecision)

    mkdir("build"*precision)
    cd("build"*precision)

    _clang_from_h(makePrecision ; quest_root="..", isWindows)

    if EXPERT_BUILD
        nothing
    else

        # `run()` with `wait=true` throws an error if anything goes wrong,
        # e.g., non-zero exit status
        if isWindows
            run(`cmake -DPRECISION=$makePrecision .. -G "MinGW Makefiles"`; wait=true)
        else
            run(`cmake -DPRECISION=$makePrecision ..` ; wait=true)
        end

        run(`make` ; wait=true)
    end

    cd("..")

    nothing
end


"""
Clone repository, call `_auxBuild()`
"""
function build(;isWindows::Bool) ::Nothing
    @info "Cloning QuEST..."
    run(`git clone https://github.com/TartuQC/QuEST.git` ; wait=true)
    cd("QuEST")
    @info "Build with 32-bit floats..."
    _auxBuild(1 ; isWindows)
    @info "Build with 64-bit floats..."
    _auxBuild(2 ; isWindows)
    @info "Build successful."
    cd("..")
end

#
# File "main" section
#

if EXPERT_BUILD
    @warn "Expert installation: Make sure the libraries `libQuEST_32` and `libQuEST_64` are loadable."
else
    @warn "Non-expert installation: Downloading & building QuEST with default settings"
end


if ispath("QuEST") && !isempty(readdir("QuEST"))
    rm("QuEST" ; force=true,recursive=true)
end

if Sys.isunix()
    build(isWindows=false)
elseif Sys.iswindows()
    build(isWindows=true)
else
    error("OS not supported.")
end

open("build_setup.jl", "w") do f
    write(f,
          "const EXPERT_BUILD = Bool($(EXPERT_BUILD))\n")
end

#EOF
