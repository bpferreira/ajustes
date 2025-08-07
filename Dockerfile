# Usa imagem base do R com tidyverse (inclui readr, readxl, dplyr, etc.)
FROM rocker/tidyverse:4.3.1

# Define repositório CRAN confiável
ENV R_REPOS="https://cloud.r-project.org"

# Instala pacotes adicionais utilizados nos scripts
RUN R -e "install.packages(c('httr', 'lubridate', 'xml2', 'rvest', 'zoo', 'purrr'), repos=Sys.getenv('R_REPOS'))"

# Define diretório de trabalho
WORKDIR /home/rproject

# Copia todo o conteúdo do projeto para dentro do container
COPY . .

# Garante que as pastas de saída existam
RUN mkdir -p data/ajustes/b3 data/ajustes/anbima

# Comando padrão (útil para teste local, sobrescrito no GitHub Actions)
CMD ["Rscript"]
