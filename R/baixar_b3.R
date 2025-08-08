# Pacotes necessários
pacotes <- c("httr", "rvest", "xml2", "readr", "dplyr",
             "lubridate", "zoo", "purrr", "stringr", "openxlsx")
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
library(stringr)
library(openxlsx)

# Função para converter texto -> número no formato pt-BR
to_num <- function(x) {
  x <- str_replace_all(x, "\\u00A0", " ")  # NBSP
  x <- str_replace_all(x, "%", "")
  x <- str_squish(x)
  readr::parse_number(x, locale = readr::locale(decimal_mark = ",", grouping_mark = "."))
}

baixar_ajustes_b3 <- function(produto) {
  url <- "https://www2.bmf.com.br/pages/portal/bmfbovespa/lumis/lum-ajustes-do-pregao-ptBR.asp"
  data_ref <- Sys.Date()
  data_str <- format(data_ref, "%Y-%m-%d")
  dir_out <- "data/ajustes/b3"
  dir.create(dir_out, recursive = TRUE, showWarnings = FALSE)

  caminho_csv  <- file.path(dir_out, paste0(data_str, "_", produto, ".csv"))
  caminho_xlsx <- file.path(dir_out, paste0(data_str, "_", produto, ".xlsx"))

  tryCatch({
    cat("📥 Acessando:", url, "\n")

    tabela <- url %>%
      GET(config = config(ssl_verifypeer = FALSE)) %>%
      read_html() %>%
      html_nodes("table") %>%
      html_table(fill = TRUE, na.strings = "NA") %>%
      .[[1]]

    # Validação
    if (ncol(tabela) != 6) stop("❌ Estrutura da tabela da B3 mudou. Esperado 6 colunas.")

    names(tabela) <- c("Ativo", "Vct", "AjusteD_1", "AjusteD0", "Variacao", "AjPorContrato")

    # Preenche Ativo vazio
    tabela$Ativo[tabela$Ativo == ""] <- NA
    tabela$Ativo <- na.locf(tabela$Ativo)

    # Filtra produto
    tabela_produto <- tabela %>% filter(grepl(paste0("^", produto), Ativo))
    if (nrow(tabela_produto) == 0) stop(paste("Produto não encontrado:", produto))

    # Converte colunas numéricas
    num_cols <- c("AjusteD_1", "AjusteD0", "Variacao", "AjPorContrato")
    tabela_produto <- tabela_produto %>%
      mutate(across(all_of(num_cols), to_num))

    # --- Salvar CSV pt-BR ---
    write.csv2(
      tabela_produto,
      file = caminho_csv,
      row.names = FALSE,
      na = ""
    )

    # --- Salvar XLSX formatado ---
    wb <- createWorkbook()
    addWorksheet(wb, "Ajustes", gridLines = FALSE)

    # Escreve como tabela com estilo
    writeDataTable(wb, "Ajustes", x = tabela_produto, tableStyle = "TableStyleMedium9")

    # Estilo de cabeçalho
    headerStyle <- createStyle(
      fontColour = "white", fgFill = "#4F81BD", textDecoration = "bold",
      halign = "center", valign = "center"
    )
    addStyle(wb, "Ajustes", headerStyle, rows = 1, cols = 1:ncol(tabela_produto), gridExpand = TRUE)

    # Formato numérico para colunas numéricas
    num_fmt <- "#,##0.00"
    num_idx <- match(num_cols, names(tabela_produto))
    num_idx <- num_idx[!is.na(num_idx)]
    if (length(num_idx)) {
      addStyle(wb, "Ajustes", createStyle(numFmt = num_fmt),
               rows = 2:(nrow(tabela_produto) + 1), cols = num_idx,
               gridExpand = TRUE, stack = TRUE)
    }

    # Melhorias visuais
    freezePane(wb, "Ajustes", firstRow = TRUE)
    setColWidths(wb, "Ajustes", cols = 1:ncol(tabela_produto), widths = "auto")

    saveWorkbook(wb, caminho_xlsx, overwrite = TRUE)

    cat("✅", produto, "CSV salvo em:",  caminho_csv,  "\n")
    cat("✅", produto, "XLSX salvo em:", caminho_xlsx, "\n")

  }, error = function(e) {
    cat("❌ Erro ao baixar", produto, ":", e$message, "\n")
    quit(status = 1)
  })
}

# Rodar para múltiplos produtos
produtos <- c("DI1", "DAP")
walk(produtos, baixar_ajustes_b3)

# 🔁 Limpeza de arquivos antigos (>5 dias) — CSV e XLSX
limite <- Sys.Date() - 5
arquivos_antigos <- list.files("data/ajustes/b3", pattern = "\\.(csv|xlsx)$", full.names = TRUE, ignore.case = TRUE)

for (arq in arquivos_antigos) {
  data_arq <- as.Date(sub("_.*", "", basename(arq)))
  if (!is.na(data_arq) && data_arq < limite) {
    file.remove(arq)
    cat("🧹 Removido arquivo antigo:", basename(arq), "\n")
  }
}
