import Lina.FFI

namespace Lina

structure Version where
  major : Nat
  minor : Nat
  deriving Repr

structure Request where
  version : Version
  method : String
  path : String
  headers : List (String × String)
  body : String
  deriving Repr

inductive Result (α : Type) where
  | success : α → Result α
  | error   : String → Result α
  deriving Repr

namespace Request

open Lina.Request.Unsafe

def parse (str : String) : IO (Result Request) := do
  let (http, result) ← leanParseHttp str

  match result with
  | 4294967294 => pure $ Result.error "Incomplete request"
  | 4294967295 => pure $ Result.error "Invalid request"
  | sizeOfPart => do
      let major ← leanMajorVersion http
      let minor ← leanMinorVersion http
      let method := leanHttpRequestMethod http

      let headerCount ← leanHeaderCount http

      let mut headers : List (String × String) := []

      for i in [:headerCount.toNat] do
        let name := leanHeaderName http i.toUInt32
        let value := leanHeaderValue http i.toUInt32
        headers := (name, value) :: headers
        
      let body := str.drop (sizeOfPart.toNat)
      let path := leanHttpObjectPath http
      let version := { major := major.toNat, minor := minor.toNat }
      pure $ Result.success { version, method, path, headers, body }

end Request
end Lina