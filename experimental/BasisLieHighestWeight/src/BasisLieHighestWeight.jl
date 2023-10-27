module BasisLieHighestWeight

using ..Oscar
using ..Oscar: GAPWrap, IntegerUnion, isweighted

using AbstractAlgebra.PrettyPrinting

import Oscar: dim, monomial_ordering, monomials

import Base: length

# TODO: Test im ZZx should be a graded_polynomial_ring with weights_w as weights

# TODO (?) Maybe export and docstring: 
# get_dim_weightspace
# orbit_weylgroup
# get_lattice_points_of_weightspace
# convert_lattice_points_to_monomials
# convert_monomials_to_lattice_points
# action_matrices_of_operators
# weights_for_operators

# TODO Use Oscar-Lie-Algebra type instead of LieAlgebra
# TODO Data-Type for weights of Lie-Algebras? Two types, in alpha_i and w_i, conversion is defined in RootConversion
# w_to_aplha
# alpha_to_w

# TODO GAPWrap-wrappers are missing for 
# ChevalleyBasis
# DimensionOfHighestWeightModule
# SimpleLieAlgebra
# Rationals
# HighestWeightModule
# List
# MatrixOfAction
# RootSystem
# CartanMatrix
# WeylGroup
# DominantCharacter
# DimensionOfHighestWeightModule
# CanonicalGenerators

include("LieAlgebras.jl")
include("BirationalSequence.jl")
include("MonomialBasis.jl")
include("NewMonomial.jl")
include("TensorModels.jl")
include("MonomialOrder.jl")
include("RootConversion.jl")
include("WeylPolytope.jl")
include("MainAlgorithm.jl")
include("UserFunctions.jl")

end

export BasisLieHighestWeight
