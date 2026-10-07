-- lua/services/usuario_service.lua
local cjson = require("cjson")
local usuario_service = {}

local FILE_PATH = "usuarios.json"
local cache_usuarios = nil

cjson.encode_empty_table_as_object(false)

local function carregar_dados()
    if cache_usuarios then
        return cache_usuarios
    end

    local f = io.open(FILE_PATH, "r")
    if not f then
        cache_usuarios = {}
        return cache_usuarios
    end

    local conteudo = f:read("*a")
    f:close()

    if not conteudo or conteudo == "" then
        cache_usuarios = {}
        return cache_usuarios
    end

    local ok, dados = pcall(cjson.decode, conteudo)
    if ok and type(dados) == "table" then
        cache_usuarios = dados
    else
        cache_usuarios = {}
    end

    return cache_usuarios
end

local function salvar_dados(dados)
    cache_usuarios = dados
    
    local f = io.open(FILE_PATH, "w+")
    if not f then return false end

    f:write(cjson.encode(dados))
    f:close()
    return true
end

function usuario_service.listar_todos()
    return carregar_dados()
end

function usuario_service.criar(novo_usuario)
    local usuarios = carregar_dados()
    
    novo_usuario.id = #usuarios + 1
    table.insert(usuarios, novo_usuario)
    
    salvar_dados(usuarios)

    return novo_usuario
end

-- Deleta um usuário pelo ID
function usuario_service.deletar(id)
    local usuarios = carregar_dados()
    local novos_usuarios = {}
    local removido = false

    for _, u in ipairs(usuarios) do
        if u.id == id then
            removido = true
        else
            table.insert(novos_usuarios, u)
        end
    end

    if removido then
        salvar_dados(novos_usuarios)
    end

    return removido
end

return usuario_service