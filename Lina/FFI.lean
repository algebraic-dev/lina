namespace Lina
namespace Request
namespace Unsafe

@[extern "lean_parser_initialize"]
opaque initParse : IO Unit

builtin_initialize initParse

opaque Parse.Nonempty : NonemptyType

def HttpRequest : Type := Parse.Nonempty.type

@[extern "lean_parse_http"]
opaque leanParseHttp : String → IO (HttpRequest × UInt32)

@[extern "lean_http_request_method"]
opaque leanHttpRequestMethod : (s: @& HttpRequest) → String

@[extern "lean_http_object_path"]
opaque leanHttpObjectPath :  (s: @& HttpRequest) → String

@[extern "lean_minor_version"]
opaque leanMinorVersion : (s: @& HttpRequest) → USize

@[extern "lean_major_version"]
opaque leanMajorVersion : (s: @& HttpRequest) → USize

@[extern "lean_header_count"]
opaque leanHeaderCount : (s: @& HttpRequest) → USize

@[extern "lean_header_name"]
opaque leanHeaderName : (s: @& HttpRequest) → UInt32 → String

@[extern "lean_header_value"]
opaque leanHeaderValue : (s: @& HttpRequest) → UInt32 → String

end Unsafe
end Request
end Lina