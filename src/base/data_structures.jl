# QuEST.jl/src/data_structures.jl
#
# Authors:
#  - Dirk Oliver Theis, Ketita Labs
#  - Bahman Ghandchi, Ketita Labs
#
# Copyright (c) 2020-2021 Ketita Labs oü, Tartu, Estonia
#
# MIT License
#
# Copyright (c) 2020-2021 Ketita Labs oü, Tartu, Estonia
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

struct QASMLogger
    buffer     ::Ptr{Cchar}
    bufferSize ::Cint
    bufferFill ::Cint
    isLogging  ::Cint
  end

module _Hide_It
import ..Qreal
  
struct Complex
    real ::Qreal
    imag ::Qreal
end
struct Vector
    x ::Qreal
    y ::Qreal
    z ::Qreal
end

end #^ module _Hide_It
import ._Hide_It

#struct Complex
#    real ::Qreal
#    imag ::Qreal
#end

struct ComplexMatrix2
    real ::NTuple{2,NTuple{2, Qreal}}
    imag ::NTuple{2,NTuple{2, Qreal}}
end

struct ComplexArray
    real ::Ptr{Qreal}
    imag ::Ptr{Qreal}
  end

struct ComplexMatrix4
    real ::NTuple{4,NTuple{4, Qreal}}
    imag ::NTuple{4,NTuple{4, Qreal}}
end

struct ComplexMatrixN
    numQubits ::Cint
    real      ::Ptr{Ptr{Qreal}}
    imag      ::Ptr{Ptr{Qreal}}
end

struct DiagonalOp
    numQubits           :: Cint 
    numElemsPerChunk    :: Clonglong
    numChunks           :: Cint
    hunkId              :: Cint
    real                :: Ptr{Qreal}
    imag                :: Ptr{Qreal}
    deviceOperator      :: Ptr{ComplexArray}
end

struct PauliHamil 
    pauliCodes          ::Ptr{Cint}
    termCoeffs          ::Ptr{Qreal}
    numSumTerms         ::Cint
    numQubits           ::Cint
end

struct QuESTEnv
    rank     ::Cint
    numRanks ::Cint
end

struct Qureg
    isDensityMatrix       ::Cint
    numQubitsRepresented  ::Cint
    numQubitsInStateVec   ::Cint
    numAmpsPerChunk       ::Clonglong
    numAmpsTotal          ::Clonglong
    chunkId               ::Cint
    numChunks             ::Cint
       
    stateVec              ::ComplexArray 
    pairStateVec          ::ComplexArray
       
    deviceStateVec        ::ComplexArray
    firstLevelReduction   ::Ptr{Qreal}
    secondLevelReduction  ::Ptr{Qreal}
    
    qasmLog               ::Ptr{QASMLogger}
end

#struct Vector
#    x ::Qreal
#    y ::Qreal
#    z ::Qreal
#end



function createCloneQureg(qureg ::Qureg, env ::QuESTEnv) ::Qureg
    return ccall(:createCloneQureg, Qureg, (Qureg,QuESTEnv), qureg, env)
end

function createComplexMatrixN(numQubits ::T where T<:Integer) ::ComplexMatrixN;
    @assert 1 ≤ numQubits ≤ 50
    
    return ccall(:createComplexMatrixN, ComplexMatrixN, (Cint,), Cint(numQubits))
end

function createDensityQureg(numQubits ::T where T<:Integer, env ::QuESTEnv) ::Qureg
    @assert 1 ≤ numQubits ≤ 50        
    return ccall(:createDensityQureg, Qureg, (Cint,QuESTEnv), Cint(numQubits), env)
end

function createDiagonalOp(numQubits     :: T where T<:Integer,
                          env           :: QuESTEnv)    :: DiagonalOp
    return ccall(:createDiagonalOp, DiagonalOp, (Cint, QuESTEnv), Cint(numQubits), env)
end

function createPauliHamil(numQubits     :: T where T<:Integer,
                          numSumTerms   :: T where T<:Integer)     :: PauliHamil
    return ccall(:createPauliHamil, PauliHamil, (Cint, Cint), Cint(numQubits), Cint(numSumTerms))
end

function createPauliHamilFromFile(fn        ::String)   :: PauliHamil
    return ccall(:createPauliHamilFromFile, PauliHamil, (Cstring,), fn)
end

function createQuESTEnv() :: QuESTEnv
    return ccall(:createQuESTEnv, QuESTEnv, () )
end

function createQureg(numQubits ::T where T<:Integer, env ::QuESTEnv) ::Qureg
    @assert 1 ≤ numQubits ≤ 50
    
    return ccall(:createQureg, Qureg, (Cint,QuESTEnv), Cint(numQubits), env)
end

function destroyComplexMatrixN(M ::ComplexMatrixN) ::Nothing
    ccall(:destroyComplexMatrixN, Cvoid, (ComplexMatrixN,), M)
    nothing
end

function destroyDiagonalOp(op       :: DiagonalOp,
                           env      :: QuESTEnv)    :: Nothing
    ccall(:destroyDiagonalOp, Cvoid, (DiagonalOp, QuESTEnv), op, env)
return nothing
end

function destroyPauliHamil(hamil        ::PauliHamil)   :: Nothing
    ccall(:destroyPauliHamil, Cvoid, (PauliHamil,), hamil)
    return nothing
end

function destroyQuESTEnv(env ::QuESTEnv) ::Nothing
    ccall(:destroyQuESTEnv, Cvoid, (QuESTEnv,), env)
    return nothing
end

function destroyQureg(qureg ::Qureg, env ::QuESTEnv) ::Nothing
    ccall(:destroyQureg, Cvoid, (Qureg,QuESTEnv), qureg, env)
    return nothing
end

function initComplexMatrixN(m       ::ComplexMatrixN,
                            m_j     ::Matrix{Base.Complex})    ::Nothing
    
    @assert 1<<m.numQubits == size(m_j)[1] == size(m_j)[1]
    real_ = Matrix{Qreal}(transpose(Qreal.(real(m_j))))
    imag_ = Matrix{Qreal}(transpose(Qreal.(imag(m_j))))
    ccall(:initComplexMatrixN, Cvoid, (ComplexMatrixN, Ptr{Qreal}, Ptr{Qreal}), m, real_, imag_)
    return nothing
end

function initDiagonalOp(op      :: DiagonalOp,
                        real_   :: Base.Vector{Qreal},
                        imag_   :: Base.Vector{Qreal})  ::Nothing

    @assert 1<<op.numQubits == length(real_) == length(imag)
    ccall(:initDiagonalOp, Cvoid, (DiagonalOp, Ptr{Qreal}, Ptr{Qreal}), op, real_, imag_)
    return nothing
end

function initPauliHamil(hamil       :: PauliHamil,
                        coeffs      :: Base.Vector{Qreal},
                        codes       :: Base.Vector{T} where T<:Integer)    ::Nothing

    @assert length(codes) == hamil.numSumTerms*hamil.numQubits
    ccall(:initPauliHamil, Cvoid, (PauliHamil, Ptr{Qreal}, Ptr{Cint}), hamil, coeffs, Cint(codes))
    return nothing
end

function setDiagonalOpElems(op          ::DiagonalOp,
                            startInd    ::T where T<:Integer,
                            real_       ::Base.Vector{Qreal},
                            imag_       ::Base.Vector{Qreal},
                            numElems    ::T where T<:Integer)  ::Nothing
    ccall(:setDiagonalOpElems, 
          Cvoid, 
          (DiagonalOp, Clonglong, Ptr{Qreal}, Ptr{Qreal}, Clonglong), 
          op, 
          Clonglong(startInd), 
          real_, 
          imag_, 
          Clonglong(numElems))
    return nothing
end

function syncDiagonalOp(op        ::DiagonalOp)     ::Nothing
    ccall(:syncDiagonalOp, Cvoid, (DiagonalOp,), op)
    return nothing
end