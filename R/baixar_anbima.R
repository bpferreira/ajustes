library(httr)
library(readxl)
library(readr)
library(lubridate)

# Sanitiza nome da aba para uso no nome do arquivo
sanitize <- function(name) {
  name <- iconv(name, to = "ASCII//TRANSLIT")
  name <- gsub("[^[:alnum:]_]", "_", name)
  name <- gsub("_+", "_", name)
  tolower(trimws(name))
}

# Gera URL no novo formato da ANBIMA
get_anbima_url <- function(data_ref) {
  meses <- c("jan", "fev", "mar", "abr", "mai", "jun",
             "jul", "ago", "set", "out", "nov", "dez")
  ano <- format(data_ref, "%y")
  mes <- meses[as.integer(format(data_ref, "%m"))]
  dia <- format(data_ref, "%d")
  
  sprintf("https://www.anbima.com.br/informacoes/merc-sec/arqs/m%s%s%s.xls",
          ano, mes, dia)
}

# Verifica se o data.frame possui conteúdo real
tem_dados <- function(df) {
  if (nrow(df) == 0 || ncol(df) == 0) return(FALSE)
  df <- df[, colSums(is.na(df) | df == "") < nrow(df), drop = FALSE]
  df <- df[rowSums(is.na(df) | df == "") < ncol(df), , drop = FALSE]
  return(nrow(df) > 0 && ncol(df) > 0)
}

baixar_anbima <- function() {
  # Recuar até último dia útil (ignorando sábado/domingo)
  data_ref <- Sys.Date() - 1
  while (weekdays(data_ref) %in% c("sábado", "domingo")) {
    data_ref <- data_ref - 1
  }

  url <- get_anbima_url(data_ref)
  dest_xls <- "data/ajustes/anbima/anbima_raw.xls"
  dir.create("data/ajustes/anbima", recursive = TRUE, showWarnings = FALSE)

  cat("📥 Tentando baixar:", url, "\n")

  tryCatch({
    resp <- GET(url, write_disk(dest_xls, overwrite = TRUE))
    if (status_code(resp) != 200) stop("Arquivo ANBIMA não encontrado")

    abas <- excel_sheets(dest_xls)

    for (aba in abas) {
      dados <- read_excel(dest_xls, sheet = aba)

      if (tem_dados(dados)) {
        nome_csv <- paste0("data/ajustes/anbima/", sanitize(aba), ".csv")
        write_csv(dados, nome_csv)
        cat("✅ Aba salva:", nome_csv, "\n")
      } else {
        cat("⚠️ Aba ignorada (sem conteúdo):", aba, "\n")
      }
    }

  }, error = function(e) {
    cat("❌ Erro no download ANBIMA:", e$message, "\n")
    quit(status = 1)
  })
}

baixar_anbima()
