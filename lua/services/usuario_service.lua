-- lua/services/usuario_service.lua
local cjson = require("cjson")
local usuario_service = {}

-- Define o arquivo utilizado para persistência dos usuários.
local FILE_PATH = "db/usuarios.json"

-- Mantém os usuários em memória para evitar leituras repetidas do arquivo.
local cache_usuarios = nil

-- Configura tabelas vazias para serem serializadas como arrays JSON.
cjson.encode_empty_table_as_object(false)

-- Carrega os usuários do cache ou do arquivo JSON.
local function carregar_dados()
    -- Retorna o cache quando os dados já foram carregados.
    if cache_usuarios then
        return cache_usuarios
    end

    -- Abre o arquivo para leitura.
    local f = io.open(FILE_PATH, "r")
    if not f then
        cache_usuarios = {}
        return cache_usuarios
    end

    -- Lê todo o conteúdo e fecha o arquivo.
    local conteudo = f:read("*a")
    f:close()

    -- Trata arquivo vazio como uma lista sem usuários.
    if not conteudo or conteudo == "" then
        cache_usuarios = {}
        return cache_usuarios
    end

    -- Converte o conteúdo JSON para uma tabela Lua.
    local ok, dados = pcall(cjson.decode, conteudo)
    if ok and type(dados) == "table" then
        cache_usuarios = dados
    else
        -- Em caso de JSON inválido, inicia com uma lista vazia.
        cache_usuarios = {}
    end

    return cache_usuarios
end

-- Persiste os dados no arquivo e atualiza o cache em memória.
local function salvar_dados(dados)
    cache_usuarios = dados
    
    -- Abre o arquivo para escrita, criando ou sobrescrevendo seu conteúdo.
    local f = io.open(FILE_PATH, "w+")
    if not f then return false end

    -- Serializa a tabela Lua para JSON e grava no arquivo.
    f:write(cjson.encode(dados))
    f:close()
    return true
end

-- Retorna todos os usuários cadastrados.
function usuario_service.listar_todos()
    return carregar_dados()
end

-- Calcula o próximo ID com base no maior ID existente.
local function obter_proximo_id(usuarios)
    local maior_id = 0

    for _, u in ipairs(usuarios) do
        if u.id and u.id > maior_id then
            maior_id = u.id
        end
    end

    return maior_id + 1
end

-- Cria um novo usuário e persiste os dados.
function usuario_service.criar(novo_usuario)
    local usuarios = carregar_dados()

    -- Gera automaticamente o ID do novo usuário.
    novo_usuario.id = obter_proximo_id(usuarios)

    table.insert(usuarios, novo_usuario)
    salvar_dados(usuarios)

    return novo_usuario
end

-- Atualiza os dados de um usuário existente pelo ID.
function usuario_service.atualizar(id, dados_novos)
    local usuarios = carregar_dados()

    for i, u in ipairs(usuarios) do
        if u.id == id then
            -- Atualiza apenas os campos enviados na requisição.
            if dados_novos.nome then usuarios[i].nome = dados_novos.nome end
            if dados_novos.dev ~= nil then usuarios[i].dev = dados_novos.dev end

            salvar_dados(usuarios)
            return usuarios[i]
        end
    end

    -- Retorna nil quando o usuário não é encontrado.
    return nil
end

-- Remove um usuário pelo ID.
function usuario_service.deletar(id)
    local usuarios = carregar_dados()
    local novos_usuarios = {}
    local removido = false

    -- Recria a lista mantendo somente os usuários que não serão removidos.
    for _, u in ipairs(usuarios) do
        if u.id == id then
            removido = true
        else
            table.insert(novos_usuarios, u)
        end
    end

    -- Persiste a nova lista somente quando houve uma remoção.
    if removido then
        salvar_dados(novos_usuarios)
    end

    return removido
end

return usuario_service