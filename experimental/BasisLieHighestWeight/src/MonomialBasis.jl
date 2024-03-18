@attributes mutable struct MonomialBasis
  lie_algebra::LieAlgebraStructure
  highest_weight::Vector{Int}
  birational_sequence::BirationalSequence
  monomial_ordering::MonomialOrdering
  dimension::Int
  monomials::Set{ZZMPolyRingElem}
  monomials_parent::ZZMPolyRing

  function MonomialBasis(
    lie_algebra::LieAlgebraStructure,
    highest_weight::Vector{<:IntegerUnion},
    birational_sequence::BirationalSequence,
    monomial_ordering::MonomialOrdering,
    monomials::Set{ZZMPolyRingElem},
  )
    return new(
      lie_algebra,
      Int.(highest_weight),
      birational_sequence,
      monomial_ordering,
      length(monomials),
      monomials,
      parent(first(monomials)),
    )
  end
end

base_lie_algebra(basis::MonomialBasis) = basis.lie_algebra

highest_weight(basis::MonomialBasis) = basis.highest_weight

dim(basis::MonomialBasis) = basis.dimension
length(basis::MonomialBasis) = dim(basis)

monomials(basis::MonomialBasis) = basis.monomials

monomial_ordering(basis::MonomialBasis) = basis.monomial_ordering

birational_sequence(basis::MonomialBasis) = basis.birational_sequence

function Base.show(io::IO, ::MIME"text/plain", basis::MonomialBasis)
  io = pretty(io)
  print(io, "Monomial basis of a highest weight module")
  print(io, Indent(), "\nof highest weight $(highest_weight(basis))", Dedent())
  print(io, Indent(), "\nof dimension $(dim(basis))", Dedent())
  print(io, Indent(), "\nwith monomial ordering $(monomial_ordering(basis))", Dedent())
  print(io, "\nover ", Lowercase(), base_lie_algebra(basis))
  if get_attribute(basis, :algorithm, nothing) === basis_lie_highest_weight_compute
    print(
      io,
      Indent(),
      "\nwhere the used birational sequence consists of the following roots (given as coefficients w.r.t. alpha_i):",
      Indent(),
    )
    for weight in birational_sequence(basis).weights_alpha
      print(io, '\n', Int.(weight))
    end
    print(io, Dedent(), Dedent())
    print(
      io,
      Indent(),
      "\nand the basis was generated by Minkowski sums of the bases of the following highest weight modules:",
      Indent(),
    )
    for gen in get_attribute(basis, :minkowski_gens)
      print(io, '\n', Int.(gen))
    end
    print(io, Dedent(), Dedent())
  elseif get_attribute(basis, :algorithm, nothing) === basis_coordinate_ring_kodaira_compute
    print(
      io,
      Indent(),
      "\nwhere the used birational sequence consists of the following roots (given as coefficients w.r.t. alpha_i):",
      Indent(),
    )
    for weight in birational_sequence(basis).weights_alpha
      print(io, '\n', Int.(weight))
    end
    print(io, Dedent(), Dedent())
    print(
      io,
      Indent(),
      "\nand the basis was generated by Minkowski sums of the bases of the following highest weight modules:",
      Indent(),
    )
    for gen in get_attribute(basis, :minkowski_gens)
      print(io, '\n', Int.(gen))
    end
    print(io, Dedent(), Dedent())
  end
end

function Base.show(io::IO, basis::MonomialBasis)
  if get(io, :supercompact, false)
    print(io, "Monomial basis of a highest weight module")
  else
    io = pretty(io)
    print(
      io,
      "Monomial basis of a highest weight module with highest weight $(highest_weight(basis)) over ",
    )
    print(IOContext(io, :supercompact => true), Lowercase(), base_lie_algebra(basis))
  end
end


struct MonomialBasisDemazure
  reduced_expression::Vector{Int}
  monomial_basis::MonomialBasis
end

function Base.show(io::IO, ::MIME"text/plain", demazure_basis::MonomialBasisDemazure)
  io = pretty(io)
  println(io, "Monomial basis of a Demazure module")
  println(io, Indent(), "of Weyl group element ", demazure_basis.reduced_expression, Dedent())
  println(io, Indent(), "of highest weight $(highest_weight(demazure_basis.monomial_basis))", Dedent())
  println(io, Indent(), "of dimension $(dim(demazure_basis.monomial_basis))", Dedent())
  println(io, Indent(), "with monomial ordering $(monomial_ordering(demazure_basis.monomial_basis))", Dedent())
  println(io, "over ", Lowercase(), base_lie_algebra(demazure_basis.monomial_basis))
  print(
      io,
      Indent(),
      "where the used birational sequence consists of the following roots (given as coefficients w.r.t. alpha_i):",
      Indent(),
  )
  for weight in demazure_basis.monomial_basis.birational_sequence.weights_alpha
      print(io, '\n', Int.(weight))
  end
  println(io, Dedent(), Dedent())
  print(
      io,
      Indent(),
      "and the basis was generated by Minkowski sums of the bases of the following highest weight modules:",
      Indent(),
  )
  for gen in demazure_basis.monomial_basis.minkowski_gens
      print(io, '\n', Int.(gen))
  end
  print(io, Dedent(), Dedent())
end

function Base.show(io::IO, demazure_basis::MonomialBasisDemazure)
  if get(io, :supercompact, false)
      print(io, "Monomial basis of a Demazure module")
  else
      print(
          io,
          "Monomial basis of a Demazure module with Weyl group element ", demazure_basis.reduced_expression,
          " and highest weight $(highest_weight(demazure_basis.monomial_basis)) over ",
      )
      print(IOContext(io, :supercompact => true), base_lie_algebra(demazure_basis.monomial_basis))
  end
end
