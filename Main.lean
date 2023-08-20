import «Lina»


def main : IO Unit := do
  let str := "POST /cgi-bin/process.cgi HTTP/1.1\r\nUser-Agent: Mozilla/4.0 (compatible; MSIE5.01; Windows NT)\r\nHost: www.tutorialspoint.com\r\nContent-Type: application/x-www-form-urlencoded\r\nContent-Length: 12\r\nAccept-Language: en-us\r\nAccept-Encoding: gzip, deflate\r\nConnection: Keep-Alive\r\n\r\nlicenseID=string&content=string&/paramsXML=string\r\n"  
  
  let parsed ← Lina.Request.parse str

  match parsed with
  | Lina.Result.success res => IO.println (repr res)
  | Lina.Result.error err => IO.println err
