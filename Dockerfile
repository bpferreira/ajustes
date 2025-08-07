# Usa imagem base do R com build tools e tidyverse pré-instalado (economiza tempo)
FROM rocker/tidyverse:4.3.1

# Define repositório confiável para evitar lentidão
ENV R_REPOS="https://cloud.r-project.org"

# Instala apenas pacotes adicionais que você precisa além do tidyverse
RUN R -e "install.packages(c('httr', 'lubridate'), repos=Sys.getenv('R_REPOS'))"

# Define o diretório de trabalho
WORKDIR /home/rproject

# Copia seu código local para dentro da imagem (para rodar localmente se quiser)
COPY . .

# Comando padrão (opcional para testes locais, ignorado no GitHub Actions)
CMD ["Rscript"]
