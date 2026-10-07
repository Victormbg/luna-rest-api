-- lua/services/usuario_service.lua
local cjson = require("cjson")
local usuario_service = {}

local FILE_PATH = "db/usuarios.json"
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
    
    -- Garante que o arquivo/pasta exista
    local f = io.open(FILE_PATH, "w+")
    if not f then return false end

    f:write(cjson.encode(dados))
    f:close()
    return true
end

function usuario_service.listar_todos()
    return carregar_dados()
end

local function obter_proximo_id(usuarios)
    local maior_id = 0
    for _, u in ipairs(usuarios) do
        if u.id and u.id > maior_id then
            maior_id = u.id
        end
    end
    return maior_id + 1
end

function usuario_service.criar(novo_usuario)
    local usuarios = carregar_dados()
    novo_usuario.id = obter_proximo_id(usuarios)
    table.insert(usuarios, novo_usuario)
    salvar_dados(usuarios)
    return novo_usuario
end

function usuario_service.atualizar(id, dados_novos)
    local usuarios = carregar_dados()
    for i, u in ipairs(usuarios) do
        if u.id == id then
            if dados_novos.nome then usuarios[i].nome = dados_novos.nome end
            if dados_novos.dev ~= nil then usuarios[i].dev = dados_novos.dev end
            salvar_dados(usuarios)
            return usuarios[i]
        end
    end
    return nil
end

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