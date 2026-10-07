-- lua/controllers/hello.lua
local cjson = require("cjson")

ngx.status = 200
ngx.say(cjson.encode({
    sucesso = true,
    mensagem = "Hello World refatorado em Lua!"
}))