# Usa a imagem oficial minimalista do OpenResty baseada em Alpine Linux
FROM openresty/openresty:alpine

# Instala o servidor e o cliente Redis via gerenciador de pacotes do Alpine
RUN apk add --no-cache redis

# Define o diretório de trabalho no container
WORKDIR /usr/local/openresty/nginx

# Cria a pasta de logs requerida pelo Nginx/OpenResty
RUN mkdir -p logs

# Copia a estrutura da aplicação
COPY conf/ ./conf/
COPY lua/ ./lua/

# Expõe as portas da API (8080) e do Redis (6379)
EXPOSE 8080 6379

# Inicia o serviço do Redis em background e roda o OpenResty no foreground
CMD ["sh", "-c", "redis-server --daemonize yes && openresty -g 'daemon off;'"]