local redis_util = require("lua.utils.redis")
local cjson = require("cjson")

local usuario_service = {}

-- Chaves utilizadas no Redis
local REDIS_KEY_USUARIOS = "usuarios:lista"
local REDIS_KEY_COUNTER = "usuarios:id_counter"

cjson.encode_empty_table_as_object(false)

-- Obtém e incrementa atomicamente o próximo ID no Redis
local function obter_proximo_id(red)
    local id, err = red:incr(REDIS_KEY_COUNTER)
    if not id then
        ngx.log(ngx.ERR, "Erro ao incrementar contador ID: ", err)
        return nil
    end
    return id
end

-- Busca a lista completa de usuários cadastrados no Redis
function usuario_service.listar_todos()
    local red, err = redis_util.get_client()
    if not red then return {} end

    local dados, err_get = red:get(REDIS_KEY_USUARIOS)
    redis_util.close(red)

    if not dados or dados == ngx.null or dados == "" then
        return {}
    end

    local ok, usuarios = pcall(cjson.decode, dados)
    if ok and type(usuarios) == "table" then
        return usuarios
    end

    return {}
end

-- Persiste toda a tabela de usuários de volta no Redis
local function salvar_todos(red, usuarios)
    local json_string = cjson.encode(usuarios)
    local ok, err = red:set(REDIS_KEY_USUARIOS, json_string)
    if not ok then
        ngx.log(ngx.ERR, "Erro ao salvar lista no Redis: ", err)
        return false
    end
    return true
end

-- Cria um novo usuário e salva no Redis
function usuario_service.criar(novo_usuario)
    local red, err = redis_util.get_client()
    if not red then return nil end

    local usuarios = usuario_service.listar_todos()

    novo_usuario.id = obter_proximo_id(red)
    if not novo_usuario.id then
        redis_util.close(red)
        return nil
    end

    table.insert(usuarios, novo_usuario)
    salvar_todos(red, usuarios)

    redis_util.close(red)
    return novo_usuario
end

-- Atualiza um usuário existente pelo ID
function usuario_service.atualizar(id, dados_novos)
    local red, err = redis_util.get_client()
    if not red then return nil end

    local usuarios = usuario_service.listar_todos()
    local usuario_atualizado = nil

    for i, u in ipairs(usuarios) do
        if u.id == id then
            if dados_novos.nome ~= nil then usuarios[i].nome = dados_novos.nome end
            if dados_novos.dev ~= nil then usuarios[i].dev = dados_novos.dev end

            salvar_todos(red, usuarios)
            usuario_atualizado = usuarios[i]
            break
        end
    end

    redis_util.close(red)
    return usuario_atualizado
end

-- Remove um usuário pelo ID
function usuario_service.deletar(id)
    local red, err = redis_util.get_client()
    if not red then return false end

    local usuarios = usuario_service.listar_todos()
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
        salvar_todos(red, novos_usuarios)
    end

    redis_util.close(red)
    return removido
end

return usuario_service