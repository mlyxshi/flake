## S3 Cache Server 2种情况

1. nix build 下载
```
if (GET http://HOST/BUCKET/HASH.narinfo 判断是否存在){
    GET http://HOST/BUCKET/nar/HASH.nar.zst
}else{
    本地build
}
```
2. nix copy 上传
```
if(GET http://HOST/BUCKET/HASH.narinfo 判断是否存在){
    不上传
}else{
    if(HEAD http://HOST/BUCKET/nar/HASH.nar.zst 判断是否存在){
        不上传  <--不确定,还没出现过这种情况
    }else{
        PUT http://HOST/BUCKET/HASH.narinfo
        PUT http://HOST/BUCKET/nar/HASH.nar.zst
    }
}
```
## nix copy to S3 的问题
nix copy 是整个closure，意味着会上传（本来就存在于cache.nixos.org的path）到自己的s3 server，浪费时间/空间

## Hack
GET http://HOST/BUCKET/HASH.narinfo traefik转发到 ./main.ts， 用offical cache先判断下，如果官方已经cache过了，就直接返回200（假装自己server里存在，不上传）








