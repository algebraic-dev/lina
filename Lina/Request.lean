import Lina.FFI
import Lina.Version

namespace Lina

structure Request where
  used    : UInt32
  request : Lina.Request.Unsafe.HttpRequest
  body    : String

inductive Result (α : Type) where
  | success : α → Result α
  | error   : String → Result α
  deriving Repr

namespace Request

open Lina.Request.Unsafe
open Lina.Version

def parse (str : String) : IO (Except String Request) := do
  let (request, result) ← leanParseHttp str

  match result with
  | 4294967294 => pure $ Except.error "Incomplete request"
  | 4294967295 => pure $ Except.error "Invalid request"
  | sizeOfPart => pure $ Except.ok { used := sizeOfPart, request, body := str.drop (sizeOfPart.toNat) }

def method (req : Request) : String := 
  leanHttpRequestMethod req.request

def path (req : Request) : String := 
  leanHttpObjectPath req.request

def version (req : Request) : Version :=
  let major := leanMajorVersion req.request
  let minor := leanMinorVersion req.request
  Version.mk (major.toNat) (minor.toNat)

partial def headers (req : Request) : Array (String × String) := 
  let size := leanHeaderCount req.request
  
  let rec loop (i : USize) (acc : Array (String × String)) : Array (String × String) :=
    if i < size then
      let name  := leanHeaderName req.request (i.toUInt32)
      let value := leanHeaderValue req.request (i.toUInt32)
      loop (i + 1) (acc.push (name, value))
    else
      acc

  loop 0 #[]

end Request
end Lina