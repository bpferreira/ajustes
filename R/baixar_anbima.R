baixar_anbima <- function() {
  data_ref <- Sys.Date() - 1
  url <- sprintf("https://www.anbima.com.br/merc_sec/arqs/ms%02d%02d%02d.xls",
                 lubridate::day(data_ref),
                 lubridate::month(data_ref),
                 lubridate::year(data_ref) %% 100)
  dest <- "data/ajustes/anbima.xls"
  tryCatch({
    resp <- httr::GET(url, httr::write_disk(dest, overwrite = TRUE))
    if (httr::status_code(resp) != 200) stop("Erro no download ANBIMA")
    cat("✅ Download ANBIMA concluído com sucesso\n")
  }, error = function(e) {
    cat("❌ Falha no download ANBIMA:", e$message, "\n")
    quit(status = 1)
  })
}

if (!dir.exists("data/ajustes")) dir.create("data/ajustes", recursive = TRUE)
baixar_anbima()
