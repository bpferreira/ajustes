# Usa imagem base do R com tidyverse pré-instalado (readr, readxl, dplyr, etc.)
FROM rocker/tidyverse:4.3.1

# Define repositório CRAN confiável
ENV R_REPOS="https://cloud.r-project.org"

# Instala pacotes adicionais usados nos scripts
RUN R -e "install.packages(c('httr', 'lubridate', 'xml2', 'rvest', 'readxl', 'zoo'), repos=Sys.getenv('R_REPOS'))"

# Define diretório de trabalho
WORKDIR /home/rproject

# Copia todo o conteúdo do projeto para dentro do container
COPY . .

# Garante que o diretório de saída exista (usado nos scripts)
RUN mkdir -p data/ajustes/b3 data/ajustes/anbima

# Comando padrão — sobrescrito no GitHub Actions, mas útil para debug local
CMD ["Rscript"]
