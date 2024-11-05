function is_f4_applicable(I::MPolyIdeal, ordering::MonomialOrdering)
  return (ordering == degrevlex(base_ring(I)) && !is_graded(base_ring(I))
            && ((coefficient_ring(I) isa FqField
                 && absolute_degree(coefficient_ring(I)) == 1
                 && characteristic(coefficient_ring(I)) < 2^31)
                || base_ring(I) isa QQMPolyRing))
end

@doc raw"""
    groebner_basis_f4(I::MPolyIdeal, <keyword arguments>)

Compute a Gröbner basis of `I` with respect to `degrevlex` using Faugère's F4 algorithm.
See [Fau99](@cite) for more information.

!!! note
    At current state only prime fields of characteristic `0 < p < 2^{31}` and the rationals are supported.

# Possible keyword arguments
- `initial_hts::Int=17`: initial hash table size `log_2`.
- `nr_thrds::Int=1`: number of threads for parallel linear algebra.
- `max_nr_pairs::Int=0`: maximal number of pairs per matrix, only bounded by minimal degree if `0`.
- `la_option::Int=2`: linear algebra option: exact sparse-dense (`1`), exact sparse (`2`, default), probabilistic sparse-dense (`42`), probabilistic sparse(`44`).
- `eliminate::Int=0`: size of first block of variables to be eliminated.
- `complete_reduction::Bool=true`: compute a reduced Gröbner basis for `I`
- `normalize::Bool=true`: normalizes elements in computed Gröbner basis for `I`
- `truncate_lifting::Int=0`: degree up to which the elements of the Gröbner basis are lifted to `QQ`, `0` for complete lifting
- `info_level::Int=0`: info level printout: off (`0`, default), summary (`1`), detailed (`2`).

# Examples
```jldoctest
julia> R,(x,y,z) = polynomial_ring(GF(101), [:x,:y,:z])
(Multivariate polynomial ring in 3 variables over GF(101), FqMPolyRingElem[x, y, z])

julia> I = ideal(R, [x+2*y+2*z-1, x^2+2*y^2+2*z^2-x, 2*x*y+2*y*z-y])
Ideal generated by
  x + 2*y + 2*z + 100
  x^2 + 100*x + 2*y^2 + 2*z^2
  2*x*y + 2*y*z + 100*y

julia> groebner_basis_f4(I)
Gröbner basis with elements
  1: x + 2*y + 2*z + 100
  2: y*z + 82*z^2 + 10*y + 40*z
  3: y^2 + 60*z^2 + 20*y + 81*z
  4: z^3 + 28*z^2 + 64*y + 13*z
with respect to the ordering
  degrevlex([x, y, z])
```
"""
function groebner_basis_f4(
        I::MPolyIdeal;
        initial_hts::Int=17,
        nr_thrds::Int=1,
        max_nr_pairs::Int=0,
        la_option::Int=2,
        eliminate::Int=0,
        complete_reduction::Bool=true,
        normalize::Bool=true,
        truncate_lifting::Int=0,
        info_level::Int=0
        )

    AI = AlgebraicSolving.Ideal(I.gens.O)
    vars = gens(base_ring(I))[eliminate+1:end]
    ord = degrevlex(vars)
    if length(AI.gens) == 0
        I.gb[ord]        = IdealGens(I.gens.Ox, singular_generators(I), complete_reduction)
        I.gb[ord].ord    = ord
        I.gb[ord].isGB   = true
        I.gb[ord].S.isGB = true
    else
        AlgebraicSolving.groebner_basis(AI,
                    initial_hts = initial_hts,
                    nr_thrds = nr_thrds,
                    max_nr_pairs = max_nr_pairs,
                    la_option = la_option,
                    eliminate = eliminate,
                    complete_reduction = complete_reduction,
                    normalize = normalize,
                    truncate_lifting = truncate_lifting,
                    info_level = info_level)

        I.gb[ord] =
            IdealGens(AI.gb[eliminate], ord, keep_ordering = false, isGB = true)
        I.gb[ord].isReduced = complete_reduction
    end
    return I.gb[ord]
end