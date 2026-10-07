-- lua/routes/api.lua
local res = require("utils.response")

local uri = ngx.var.uri

-- Rota de Token de Autenticação (/token)
if uri == "/token" then
    local auth_controller = require("controllers.auth_controller")
    if auth_controller and auth_controller.handle then
        return auth_controller.handle()
    end
    return res.erro(500, "Erro ao carregar o controller de autenticação")
end

-- Rota de Usuários (/usuarios e /usuarios/:id)
if uri:match("^/usuarios") then
    local usuario_controller = require("controllers.usuario_controller")
    if usuario_controller and usuario_controller.handle then
        return usuario_controller.handle()
    end
    return res.erro(500, "Erro ao carregar o controller de usuários")
end

-- Caso nenhuma rota corresponda
return res.erro(404, "Rota não encontrada")