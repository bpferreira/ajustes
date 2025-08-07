# Pacotes necessários
pacotes <- c("httr", "rvest", "xml2", "readr", "dplyr", 
             "lubridate", "zoo", "purrr")
invisible(lapply(pacotes, function(p) {
  if (!requireNamespace(p, quietly = TRUE)) stop(paste("Pacote ausente:", p))
}))

library(httr)
library(rvest)
library(xml2)
library(readr)
library(dplyr)
library(lubridate)
library(zoo)
library(purrr)

baixar_ajustes_b3 <- function(produto) {
  url <- "https://www2.bmf.com.br/pages/portal/bmfbovespa/lumis/lum-ajustes-do-pregao-ptBR.asp"
  data_str <- format(Sys.Date(), "%Y-%m-%d")
  dir.create("data/ajustes/b3", recursive = TRUE, showWarnings = FALSE)
  caminho_saida <- file.path("data/ajustes/b3", paste0(data_str, "_", produto, ".csv"))

  tryCatch({
    cat("📥 Acessando:", url, "\n")

    tabela <- url %>%
      GET(config = config(ssl_verifypeer = FALSE)) %>%
      read_html() %>%
      html_nodes("table") %>%
      html_table(fill = TRUE, na.strings = "NA") %>%
      .[[1]]

    # Validação da estrutura esperada
    if (ncol(tabela) != 6) stop("❌ Estrutura da tabela da B3 mudou. Esperado 6 colunas.")

    names(tabela) <- c("Ativo", "Vct", "AjusteD_1", "AjusteD0", "Variacao", "AjPorContrato")

    limpar_coluna <- function(x) {
      x <- gsub("\\.", "", x)
      x <- gsub(",", ".", x)
      parse_number(x)
    }

    tabela$AjusteD_1 <- limpar_coluna(tabela$AjusteD_1)
    tabela$AjusteD0 <- limpar_coluna(tabela$AjusteD0)
    tabela$Variacao <- limpar_coluna(tabela$Variacao)
    tabela$AjPorContrato <- limpar_coluna(tabela$AjPorContrato)

    tabela$Ativo[tabela$Ativo == ""] <- NA
    tabela$Ativo <- na.locf(tabela$Ativo)

    tabela_produto <- tabela %>% filter(grepl(paste0("^", produto), Ativo))

    if (nrow(tabela_produto) == 0) stop(paste("Produto não encontrado:", produto))

    write_csv(tabela_produto, caminho_saida)
    cat("✅", produto, "salvo em:", caminho_saida, "\n")

  }, error = function(e) {
    cat("❌ Erro ao baixar", produto, ":", e$message, "\n")
    quit(status = 1)
  })
}

# Rodar para múltiplos produtos
produtos <- c("DI1", "DAP")
walk(produtos, baixar_ajustes_b3)
