import Lina.FFI
import Lina.Version

namespace Lina

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
open Lina.Version

def parse (str : String) : IO (Except String Request) := do
  let (http, result) ← leanParseHttp str

  match result with
  | 4294967294 => pure $ Except.error "Incomplete request"
  | 4294967295 => pure $ Except.error "Invalid request"
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
      pure $ Except.ok { version, method, path, headers, body }

end Request
end Lina