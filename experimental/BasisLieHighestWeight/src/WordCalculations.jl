function compute_betas_lustzig(
  lie_algebra::LieAlgebraStructure, word::Vector{Int}
)::Vector{Vector{Int}}
  """
  Calculate betas from type, rank and a longest-word from the weylgroup.
  """
  # Construct Gap-Objects
  root_system = GAP.Globals.RootSystem(lie_algebra.lie_algebra_gap)

  simple_roots = GAP.Globals.SimpleSystem(root_system)
  weyl_group = GAP.Globals.WeylGroup(root_system)
  sparse_cartan_matrix = GAP.Globals.SparseCartanMatrix(weyl_group)

  # Calculate betas by applying simple-reflections step-by-step.
  betas = []

  for k in 1:length(word)
    beta = copy(simple_roots[word[k]])
    for j in (k - 1):-1:1  # Iterate in reverse
      GAP.Globals.ApplySimpleReflection(sparse_cartan_matrix, word[j], beta)
    end
    push!(betas, beta)
  end

  julia_betas = [Int[i for i in GAP.Globals.List(gap_obj)] for gap_obj in betas]
  return julia_betas
end

function compute_betas_simple_reflections(
  lie_algebra::LieAlgebraStructure, word::Vector{<:Union{Int,Vector{Int}}}
)::Vector{Vector{Int}}
  """
  Calculate betas from type, rank and a longest-word from the weylgroup.
  """
  # Construct Gap-Objects
  root_system = GAP.Globals.RootSystem(lie_algebra.lie_algebra_gap)

  simple_roots = GAP.Globals.SimpleSystem(root_system)
  weyl_group = GAP.Globals.WeylGroup(root_system)
  sparse_cartan_matrix = GAP.Globals.SparseCartanMatrix(weyl_group)

  # Positive roots
  root_system = GAP.Globals.RootSystem(lie_algebra.lie_algebra_gap)
  positive_roots = Vector{Vector{Int}}(GAP.Globals.PositiveRoots(root_system))

  # Calculate betas by adding roots for vectors
  # Root-system Gap-Objects
  betas = []
  for root in word
    if isa(root, Int)
      push!(betas, positive_roots[root])
    elseif isa(root, Vector{Int})
      result = zeros(Int, length(first(positive_roots)))
      for idx in root
        result .+= positive_roots[idx]
      end
      push!(betas, result)
    else
      error("Invalid input, only accepts Vector of Int and Vector{Int}")
    end
  end
  return betas
end

function roots_to_root_vectors(
  lie_algebra::LieAlgebraStructure,
  chevalley_basis::NTuple{3,Vector{GAP.Obj}},
  roots::Vector{Vector{Int}},
)::Vector{GAP.Obj}
  """
  Returns for list of roots the corresponding root-vectors from GAP
  """
  # Root-system Gap-Objects
  root_system = GAP.Globals.RootSystem(lie_algebra.lie_algebra_gap)

  # positive-roots
  positive_roots = Vector{Vector{Int}}(GAP.Globals.PositiveRoots(root_system))
  positive_root_vectors = chevalley_basis[1]

  # negative-roots
  negative_roots = Vector{Vector{Int}}(GAP.Globals.NegativeRoots(root_system))
  negative_root_vectors = chevalley_basis[2]

  return [
    find_root_in_chevalley_basis(
      positive_roots, positive_root_vectors, negative_roots, negative_root_vectors, root
    ) for root in roots
  ]
end

function find_root_in_chevalley_basis(
  positive_roots::Vector{Vector{Int}},
  positive_root_vectors::Vector{GAP.Obj},
  negative_roots::Vector{Vector{Int}},
  negative_root_vectors::Vector{GAP.Obj},
  root::Vector{Int},
)::GAP.Obj
  """
  For a given positive or negative root, return the GAP root vector.
  """
  # Check if root is positive-root
  for (i, root_i) in enumerate(positive_roots)
    if root == root_i
      return positive_root_vectors[i]
    end
  end

  # Check if root is negative-root
  for (i, root_i) in enumerate(negative_roots)
    if root == root_i
      return negative_root_vectors[i]
    end
  end

  return false
end

function get_operators_lustzig(
  lie_algebra::LieAlgebraStructure,
  chevalley_basis::NTuple{3,Vector{GAP.Obj}},
  reduced_expression::Vector{Int},
)::Vector{GAP.Obj}
  """
  Computes the operators for the lustzig and nz polytopes for a longest weyl-word 
  reduced_expression.

  \beta_k := s_{i_1} … s_{i_{k-1}} (\alpha_{i_k})

  F.e. for A, 2, [1, 2, 1], we get
  \beta_1 = \alpha_1
  \beta_2 = \alpha_1 + \alpha_2
  \beta_3 = \alpha_2
  """
  betas = compute_betas_lustzig(lie_algebra, reduced_expression)
  operators = roots_to_root_vectors(lie_algebra, chevalley_basis, betas)
  return operators
end

function get_operators_simple_reflections(
  lie_algebra::LieAlgebraStructure,
  chevalley_basis::NTuple{3,Vector{GAP.Obj}},
  reduced_expression::Vector{Union{Int,Vector{Int}}},
)::Vector{GAP.Obj}
  """
  Computes the operators given a Vector of either the index of a positive root, or
  a vector that gets evaluated as its sum. F.e.

  B3, [1, [1, 2]] -> [positive root 1, positive root 4]
  """
  betas = compute_betas_simple_reflections(lie_algebra, reduced_expression)
  operators = roots_to_root_vectors(lie_algebra, chevalley_basis, betas)

  return operators
end
