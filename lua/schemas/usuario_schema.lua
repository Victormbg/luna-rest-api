-- lua/schemas/usuario_schema.lua
return {
    nome = {
        type = "string",
        required = true,
        custom = function(val)
            if val:match("^%s*$") then
                return "O campo 'nome' não pode ser uma string vazia"
            end
        end
    },
    idade = {
        type = "number",
        required = false,
        custom = function(val)
            if val % 1 ~= 0 or val <= 0 then
                return "O campo 'idade' deve ser um número inteiro positivo"
            end
        end
    },
    salario = {
        type = "number",
        required = false
    },
    dev = {
        type = "boolean",
        required = false
    },
    nivel = {
        type = "string",
        required = false
    },
    tecnologias = {
        type = "table",
        required = false
    },
    ativo = {
        type = "boolean",
        required = false
    }
}