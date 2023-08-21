namespace Lina

structure Response where
  status : Int
  headers : List (String × String)
  body : String

def Response.toString (version: Version) (r : Response) : String :=
  let headers := r.headers.map (λ (k, v) => s!"{k}: {v}¬")
  let headers := String.join headers
  let major := version.major
  let minor := version.minor
  s!"HTTP/{major}.{minor} {r.status}\n{headers}\n{r.body}"

end Lina