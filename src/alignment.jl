"""
    align(x::Union{Int,Ptr}, [n])

Return aligned memory address with minimum increment. `align` assumes `n` is a
power of 2.
"""
function align end
@inline align(x::Integer) = vadd_fast(x, REGISTER_SIZE-1) & -REGISTER_SIZE
@inline align(x::Ptr{T}, args...) where {T} = reinterpret(Ptr{T}, align(reinterpret(UInt, x), args...))
@inline align(x::Integer, n) = (nm1 = n - One(); (x + nm1) & -n)
@inline align(x::Integer, ::Type{T}) where {T} = align(x, StaticInt{REGISTER_SIZE}() ÷ static_sizeof(T))

# @generated align(::Val{L}, ::Type{T}) where {L,T} = align(L, T)
aligntrunc(x::Integer, n) = x & -n
aligntrunc(x::Integer) = aligntrunc(x, REGISTER_SIZE)
aligntrunc(x::Integer, ::Type{T}) where {T} = aligntrunc(x, REGISTER_SIZE ÷ sizeof(T))
alignment(x::Integer, N = 64) = reinterpret(Int, x) % N

function valloc(N::Int, ::Type{T} = Float64, a = max(REGISTER_SIZE, L₁CACHE.linesize)) where {T}
    # We want alignment to both vector and cacheline-sized boundaries
    reinterpret(Ptr{T}, align(reinterpret(UInt,Libc.malloc(sizeof(T)*N + a - 1)), a))
end

