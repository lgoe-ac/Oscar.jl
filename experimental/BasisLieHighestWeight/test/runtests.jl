using Oscar
using Test
# using TestSetExtensions

include("MBOld.jl")

G = Oscar.GAP.Globals
forGap = Oscar.GAP.julia_to_gap
fromGap = Oscar.GAP.gap_to_julia

"""
We are testing our code in multiple ways. First, we calculated two small examples per hand and compare those. Then we 
check basic properties of the result. For example we know the size of our monomial basis. These properties get partially
used in the algorithm and could therefore be true for false results. We have another basic algorithm that solves the 
problem without the recursion, weightspaces and saving of computations. The third test compares the results we can 
compute with the weaker version.
"""

function compare_algorithms(dynkin::Char, n::Int64, lambda::Vector{Int64})
    # old algorithm
    mons_old = MBOld.basisLieHighestWeight(string(dynkin), n, lambda) # basic algorithm

    # new algorithm
    mons_new = BasisLieHighestWeight.basis_lie_highest_weight(string(dynkin), n, lambda) 
    L = G.SimpleLieAlgebra(forGap(string(dynkin)), n, G.Rationals)
    gap_dim = G.DimensionOfHighestWeightModule(L, forGap(lambda)) # dimension

    # comparison
    # convert set of monomials over different ring objects to string representation to compare for equality
    @test issetequal(string.(mons_old), string.(mons_new)) # compare if result of old and new algorithm match
    @test gap_dim == length(mons_new) # check if dimension is correct
end

function check_dimension(dynkin::Char, n::Int64, lambda::Vector{Int64}, monomial_order::String)
    w = BasisLieHighestWeight.basis_lie_highest_weight(string(dynkin), n, lambda, monomial_order=monomial_order) 
    L = G.SimpleLieAlgebra(forGap(string(dynkin)), n, G.Rationals)
    gap_dim = G.DimensionOfHighestWeightModule(L, forGap(lambda)) # dimension
    @test gap_dim == length(w) # check if dimension is correct
end

@testset "Test basisLieHighestWeight" begin
    @testset "Known examples" begin
        mons = BasisLieHighestWeight.basis_lie_highest_weight("A", 2, [1,0])
        @test issetequal(string.(mons), Set(["1", "x3", "x1"]))
        mons = BasisLieHighestWeight.basis_lie_highest_weight("A", 2, [1,0], operators=[1,2,1])
        @test issetequal(string.(mons), Set(["1", "x2*x3", "x3"]))
    end
    @testset "Compare with simple algorithm and check dimension" begin
        @testset "Dynkin type $dynkin" for dynkin in ('A', 'B', 'C', 'D')
            @testset "n = $n" for n in 1:4
                if (!(dynkin == 'B' && n < 2) && !(dynkin == 'C' && n < 2) && !(dynkin == 'D' && n < 4))
                    for i in 1:n                                # w_i
                       lambda = zeros(Int64,n)
                        lambda[i] = 1
                       compare_algorithms(dynkin, n, lambda)
                    end
                    
                    if (n > 1)
                        lambda = [1, (0 for i in 1:n-2)..., 1]  # w_1 + w_n
                        compare_algorithms(dynkin, n, lambda)
                    end
    
                    if (n < 4)
                        lambda = ones(Int64,n)                  # w_1 + ... + w_n
                        compare_algorithms(dynkin, n, lambda)
                    end
                end 
            end
        end
    end
    @testset "Check dimension" begin
        @testset "Monomial order $monomial_order" for monomial_order in ("Lex", "RevLex", "GRevLex")
            # the functionality longest-word was temporarily removed because it required coxeter groups from 
            # https://github.com/jmichel7/Gapjm.jl
            #@testset "Operators $ops" for ops in ("regular", "longest-word") 
            check_dimension('A', 3, [1,1,1], monomial_order)
                #check_dimension('B', 3, [2,1,0], monomial_order, ops)
                #check_dimension('C', 3, [1,1,1], monomial_order, ops)
                #check_dimension('D', 4, [3,0,1,1], monomial_order, ops)
                #check_dimension('F', 4, [2,0,1,0], monomial_order, ops)
                #check_dimension('G', 2, [1,0], monomial_order, ops)
                #check_dimension('G', 2, [2,2], monomial_order, ops)
            #end
        end
    end
end
