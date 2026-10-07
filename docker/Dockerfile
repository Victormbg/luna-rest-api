# Usa a imagem oficial minimalista do OpenResty baseada em Alpine Linux
FROM openresty/openresty:alpine

# Define o diretório de trabalho no container
WORKDIR /usr/local/openresty/nginx

# Copia as pastas do projeto (voltando um nível para pegar a raiz)
COPY conf/ ./conf/
COPY lua/ ./lua/
COPY db/ ./db/

# Expõe a porta da API
EXPOSE 8080

# Comando para iniciar o OpenResty
CMD ["openresty", "-g", "daemon off;"]