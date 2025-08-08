# Pacotes necessários
pacotes <- c("readxl", "readr", "dplyr", "stringr", "openxlsx", "lubridate")
invisible(lapply(pacotes, function(p) {
  if (!requireNamespace(p, quietly = TRUE)) stop(paste("Pacote ausente:", p))
}))

library(readxl)
library(readr)
library(dplyr)
library(stringr)
library(openxlsx)
library(lubridate)

# ---- util: texto -> número pt-BR (milhar ".", decimal ",") ----
to_num <- function(x) {
  x <- str_replace_all(x, "\\u00A0", " ")   # NBSP
  x <- str_replace_all(x, "%", "")
  x <- str_squish(x)
  readr::parse_number(x, locale = readr::locale(decimal_mark = ",", grouping_mark = "."))
}

# ---- carrega df da ANBIMA a partir do anexo bruto (XLS) ----
carregar_anbima_df <- function(xls_path) {
  if (!file.exists(xls_path)) {
    stop("Arquivo bruto da ANBIMA não encontrado: ", xls_path,
         "\nGaranta que o passo de download salvou 'anbima_raw.xls'.")
  }
  # Lê tudo como texto para normalizar depois
  df <- readxl::read_xls(xls_path, col_types = "text")
  # Remover linhas totalmente vazias (opcional)
  df <- df %>% filter(if_all(everything(), ~ !is.na(.x) & .x != ""))
  df
}

# ---- normaliza para numérico onde fizer sentido (heurística) ----
normalizar_numericos <- function(df) {
  out <- df
  for (nm in names(out)) {
    if (is.character(out[[nm]])) {
      parsed <- to_num(out[[nm]])
      # heurística: se >= 50% vira número, consideramos coluna numérica
      if (mean(!is.na(parsed)) >= 0.5) out[[nm]] <- parsed
    }
  }
  out
}

# Caso você saiba exatamente as colunas numéricas, comente a heurística acima
# e use algo como:
# num_cols <- c("PU", "Taxa", "Duration", "Spread")
# df <- df %>% mutate(across(all_of(num_cols), to_num))

baixar_anbima <- function() {
  dir_out   <- file.path("data", "ajustes", "anbima")
  dir.create(dir_out, recursive = TRUE, showWarnings = FALSE)

  xls_raw   <- file.path(dir_out, "anbima_raw.xls")
  data_ref  <- Sys.Date()
  data_str  <- format(data_ref, "%Y-%m-%d")

  caminho_csv  <- file.path(dir_out, paste0(data_str, "_ANBIMA.csv"))
  caminho_xlsx <- file.path(dir_out, paste0(data_str, "_ANBIMA.xlsx"))

  tryCatch({
    cat("📥 Lendo bruto ANBIMA:", xls_raw, "\n")
    df_raw   <- carregar_anbima_df(xls_raw)
    df_clean <- normalizar_numericos(df_raw)

    # --- Salvar CSV pt-BR (sep=';' e dec=',') ---
    write.csv2(
      df_clean,
      file      = caminho_csv,
      row.names = FALSE,
      na        = ""
    )

    # --- Gerar XLSX formatado ---
    wb <- createWorkbook()
    addWorksheet(wb, "ANBIMA", gridLines = FALSE)

    writeDataTable(wb, "ANBIMA", x = df_clean, tableStyle = "TableStyleMedium9")

    headerStyle <- createStyle(
      fontColour = "white", fgFill = "#4F81BD", textDecoration = "bold",
      halign = "center", valign = "center"
    )
    addStyle(wb, "ANBIMA", headerStyle, rows = 1, cols = 1:ncol(df_clean), gridExpand = TRUE)

    # Formatação numérica (2 casas, milhar) em todas as colunas numéricas
    num_idx <- which(vapply(df_clean, is.numeric, logical(1)))
    if (length(num_idx)) {
      addStyle(
        wb, "ANBIMA", createStyle(numFmt = "#,##0.00"),
        rows = 2:(nrow(df_clean) + 1), cols = num_idx,
        gridExpand = TRUE, stack = TRUE
      )
    }

    freezePane(wb, "ANBIMA", firstRow = TRUE)
    setColWidths(wb, "ANBIMA", cols = 1:ncol(df_clean), widths = "auto")

    saveWorkbook(wb, caminho_xlsx, overwrite = TRUE)

    cat("✅ ANBIMA CSV salvo em:",  caminho_csv,  "\n")
    cat("✅ ANBIMA XLSX salvo em:", caminho_xlsx, "\n")

  }, error = function(e) {
    cat("❌ Erro no ANBIMA:", e$message, "\n")
    quit(status = 1)
  })
}

# Executa
baixar_anbima()

# 🔁 Limpeza de arquivos antigos (>5 dias) — CSV e XLSX
limite  <- Sys.Date() - 5
arquivos <- list.files("data/ajustes/anbima", pattern = "\\.(csv|xlsx)$",
                       full.names = TRUE, ignore.case = TRUE)
for (arq in arquivos) {
  data_arq <- as.Date(sub("_.*", "", basename(arq)))
  if (!is.na(data_arq) && data_arq < limite) {
    file.remove(arq)
    cat("🧹 Removido arquivo antigo:", basename(arq), "\n")
  }
}
