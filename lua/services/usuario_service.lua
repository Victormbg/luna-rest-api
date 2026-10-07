-- lua/services/usuario_service.lua
local cjson = require("cjson")
local usuario_service = {}

local FILE_PATH = "usuarios.json"

-- Cache em memória RAM (compartilhado entre requisições do mesmo worker)
local cache_usuarios = nil

-- Força o cjson a serializar tabelas vazias como Array JSON [] em vez de Objeto {}
cjson.encode_empty_table_as_object(false)

-- Função privada para ler do arquivo ou da memória
local function carregar_dados()
    -- Se já estiver carregado na RAM, usa o cache
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

-- Função privada para salvar na RAM e no disco
local function salvar_dados(dados)
    cache_usuarios = dados -- Atualiza a RAM
    
    local f = io.open(FILE_PATH, "w+")
    if not f then return false end

    f:write(cjson.encode(dados))
    f:close()
    return true
end

-- Lista todos os usuários (lê diretamente da memória)
function usuario_service.listar_todos()
    return carregar_dados()
end

-- Cria um novo usuário
function usuario_service.criar(novo_usuario)
    local usuarios = carregar_dados()
    
    novo_usuario.id = #usuarios + 1
    table.insert(usuarios, novo_usuario)
    
    salvar_dados(usuarios)

    return novo_usuario
end

return usuario_service