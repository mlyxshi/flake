import { serve } from "https://deno.land/std@0.170.0/http/server.ts";

const port = 4507;
const bucket = "nix";

const handler = async (request: Request): Promise<Response> => {
  // console.log("----------------------------------------")
  // console.log(request.url)
  // console.log(request.method)
  // console.log(request.headers)

  const narinfoPath = request.url.split(`/${bucket}/`).pop()

  // *.narinfo   
  const officialCacheResponse = await fetch(`http://cache.nixos.org/${narinfoPath}`)
  if (officialCacheResponse.status == 200){
    return officialCacheResponse
  } 
  else{
    return await fetch(`http://cache.mlyxshi.com/${narinfoPath}`)
  }
  
};

serve(handler, { port });