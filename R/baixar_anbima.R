# Pacotes
pacotes <- c("httr", "readxl", "readr", "lubridate")
invisible(lapply(pacotes, function(p) {
  if (!requireNamespace(p, quietly = TRUE)) stop(paste("Pacote ausente:", p))
}))

library(httr)
library(readxl)
library(readr)
library(lubridate)

# Função para sanitizar nome da aba
sanitize <- function(name) {
  name <- iconv(name, to = "ASCII//TRANSLIT")
  name <- gsub("[^[:alnum:]_]", "_", name)
  name <- gsub("_+", "_", name)
  tolower(trimws(name))
}

# Função para montar URL
get_anbima_url <- function(data_ref) {
  meses <- c("jan", "fev", "mar", "abr", "mai", "jun",
             "jul", "ago", "set", "out", "nov", "dez")
  sprintf("https://www.anbima.com.br/informacoes/merc-sec/arqs/m%s%s%s.xls",
          format(data_ref, "%y"),
          meses[as.integer(format(data_ref, "%m"))],
          format(data_ref, "%d"))
}

# Verifica se data.frame tem conteúdo válido
tem_dados <- function(df) {
  if (nrow(df) == 0 || ncol(df) == 0) return(FALSE)
  df <- df[, colSums(is.na(df) | df == "") < nrow(df), drop = FALSE]
  df <- df[rowSums(is.na(df) | df == "") < ncol(df), , drop = FALSE]
  return(nrow(df) > 0 && ncol(df) > 0)
}

baixar_anbima <- function() {
  # Define data de referência (último dia útil)
  data_ref <- Sys.Date() - 1
  while (weekdays(data_ref) %in% c("sábado", "domingo")) {
    data_ref <- data_ref - 1
  }

  url <- get_anbima_url(data_ref)
  dir_out <- "data/ajustes/anbima"
  dir.create(dir_out, recursive = TRUE, showWarnings = FALSE)
  dest_xls <- file.path(dir_out, "anbima_raw.xls")

  cat("📥 Tentando baixar:", url, "\n")

  tryCatch({
    resp <- GET(url, write_disk(dest_xls, overwrite = TRUE))
    if (status_code(resp) != 200) stop("Arquivo ANBIMA não encontrado")

    abas <- excel_sheets(dest_xls)

    for (aba in abas) {
      dados <- read_excel(dest_xls, sheet = aba)
      if (tem_dados(dados)) {
        nome_csv <- file.path(dir_out, paste0(format(data_ref, "%Y-%m-%d"), "_", sanitize(aba), ".csv"))
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

# 🔁 Remoção de arquivos antigos (>5 dias), exceto o .xls
arquivos <- list.files("data/ajustes/anbima", pattern = "\\.csv$", full.names = TRUE)
limite <- Sys.Date() - 5

for (arq in arquivos) {
  data_arq <- as.Date(sub("_.*", "", basename(arq)))
  if (!is.na(data_arq) && data_arq < limite) {
    file.remove(arq)
    cat("🧹 Removido arquivo antigo:", basename(arq), "\n")
  }
}
