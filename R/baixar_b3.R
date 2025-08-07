baixar_b3 <- function() {
  url <- sprintf("https://www2.cetip.com.br/ConsultarTaxaDi/ConsultarTaxaDICetip.aspx?data=%s", format(Sys.Date() - 1, "%d/%m/%Y"))
  dest <- "data/ajustes/b3.csv"
  tryCatch({
    resp <- httr::GET(url)
    if (httr::status_code(resp) != 200) stop("Erro no download B3")
    writeBin(httr::content(resp, "raw"), dest)
    cat("✅ Download B3 concluído com sucesso\n")
  }, error = function(e) {
    cat("❌ Falha no download B3:", e$message, "\n")
    quit(status = 1)
  })
}

if (!dir.exists("data/ajustes")) dir.create("data/ajustes", recursive = TRUE)
baixar_b3()
