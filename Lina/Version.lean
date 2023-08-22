-- Definition of a HTTP Version as defined in https://datatracker.ietf.org/doc/html/rfc2616#section-3.1
namespace Lina

-- Http version defined in the HTTP Protocol
structure Version where
  major : Nat
  minor : Nat
  deriving Repr

end Lina