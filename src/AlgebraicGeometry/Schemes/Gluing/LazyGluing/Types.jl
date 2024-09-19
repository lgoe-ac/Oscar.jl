@attributes mutable struct LazyGluing{
                                       LeftAffineSchemeType<:AbsAffineScheme, 
                                       RightAffineSchemeType<:AbsAffineScheme,
                                       GluingDataType
                                      }<:AbsGluing{
                                                    LeftAffineSchemeType,
                                                    RightAffineSchemeType, 
                                                    Scheme, Scheme,
                                                    Map, Map
                                                   }

  X::LeftAffineSchemeType
  Y::RightAffineSchemeType
  GD::GluingDataType
  compute_function::Function
  compute_gluing_domains::Function
  gluing_domains::Union{Tuple{PrincipalOpenSubset, PrincipalOpenSubset},
                         Tuple{AffineSchemeOpenSubscheme, AffineSchemeOpenSubscheme}}
  G::AbsGluing

  function LazyGluing(X::AbsAffineScheme, Y::AbsAffineScheme, 
      compute_function::Function, GD::GluingDataType
    ) where {GluingDataType}
    return new{typeof(X), typeof(Y), GluingDataType}(X, Y, GD, compute_function)
  end
  function LazyGluing(X::AbsAffineScheme, Y::AbsAffineScheme, 
      compute_function::Function, compute_gluing_domains::Function, 
      GD::GluingDataType
    ) where {GluingDataType}
    return new{typeof(X), typeof(Y), GluingDataType}(X, Y, GD, compute_function, 
                                                      compute_gluing_domains)
  end
end


### Preparations for some sample use cases
mutable struct RestrictionDataIsomorphism
  G::AbsGluing
  i::AbsAffineSchemeMor
  j::AbsAffineSchemeMor
  i_res::SchemeMor
  j_res::SchemeMor
  function RestrictionDataIsomorphism(G::AbsGluing, i::AbsAffineSchemeMor, j::AbsAffineSchemeMor)
    return new(G, i, j)
  end
end

mutable struct RestrictionDataClosedEmbedding
  G::AbsGluing
  X::AbsAffineScheme
  Y::AbsAffineScheme
  UX::Scheme
  VY::Scheme
  function RestrictionDataClosedEmbedding(G::AbsGluing, X::AbsAffineScheme, Y::AbsAffineScheme)
    return new(G, X, Y)
  end
end
