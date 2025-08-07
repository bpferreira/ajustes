# Script de diagnóstico completo para investigar problemas
cat("🔍 DIAGNÓSTICO COMPLETO - Ajustes Diários\n")
cat("==========================================\n\n")

# 1. Verificar ambiente
cat("1️⃣ VERIFICANDO AMBIENTE:\n")
cat("   Diretório atual:", getwd(), "\n")
cat("   Data atual:", Sys.Date(), "\n")
cat("   Hora atual:", format(Sys.time(), "%H:%M:%S"), "\n\n")

# 2. Verificar pacotes
cat("2️⃣ VERIFICANDO PACOTES:\n")
pacotes_necessarios <- c("httr", "readxl", "readr", "lubridate", "rvest", "xml2", "dplyr", "zoo", "purrr")
for (pkg in pacotes_necessarios) {
  if (requireNamespace(pkg, quietly = TRUE)) {
    cat("   ✅", pkg, "\n")
  } else {
    cat("   ❌", pkg, "NÃO INSTALADO\n")
  }
}
cat("\n")

# 3. Verificar estrutura de diretórios
cat("3️⃣ VERIFICANDO ESTRUTURA:\n")
dirs_necessarios <- c("data", "data/ajustes", "data/ajustes/b3", "data/ajustes/anbima")
for (dir in dirs_necessarios) {
  if (dir.exists(dir)) {
    cat("   ✅", dir, "\n")
  } else {
    cat("   ❌", dir, "NÃO EXISTE\n")
    # Tentar criar
    tryCatch({
      dir.create(dir, recursive = TRUE, showWarnings = FALSE)
      cat("   ✅", dir, "CRIADO\n")
    }, error = function(e) {
      cat("   ❌ Erro ao criar", dir, ":", e$message, "\n")
    })
  }
}
cat("\n")

# 4. Testar escrita de arquivos
cat("4️⃣ TESTANDO ESCRITA DE ARQUIVOS:\n")
test_files <- c(
  "data/ajustes/teste1.csv",
  "data/ajustes/b3/teste2.csv", 
  "data/ajustes/anbima/teste3.csv"
)

for (test_file in test_files) {
  tryCatch({
    # Criar dados de teste
    dados_teste <- data.frame(
      data = Sys.Date(),
      valor = runif(5),
      texto = paste0("teste_", 1:5)
    )
    
    # Tentar escrever
    write.csv(dados_teste, test_file, row.names = FALSE)
    
    # Verificar se foi criado
    if (file.exists(test_file)) {
      file_size <- file.size(test_file)
      cat("   ✅", test_file, "(", file_size, "bytes)\n")
      
      # Remover arquivo de teste
      file.remove(test_file)
      cat("   🧹 Removido:", test_file, "\n")
    } else {
      cat("   ❌", test_file, "NÃO FOI CRIADO\n")
    }
  }, error = function(e) {
    cat("   ❌ Erro ao criar", test_file, ":", e$message, "\n")
  })
}
cat("\n")

# 5. Verificar permissões
cat("5️⃣ VERIFICANDO PERMISSÕES:\n")
for (dir in c("data/ajustes", "data/ajustes/b3", "data/ajustes/anbima")) {
  if (dir.exists(dir)) {
    test_file <- file.path(dir, "perm_test.csv")
    tryCatch({
      write.csv(data.frame(x = 1), test_file, row.names = FALSE)
      if (file.exists(test_file)) {
        cat("   ✅ Escrita permitida em", dir, "\n")
        file.remove(test_file)
      } else {
        cat("   ❌ Escrita NÃO permitida em", dir, "\n")
      }
    }, error = function(e) {
      cat("   ❌ Erro de permissão em", dir, ":", e$message, "\n")
    })
  }
}
cat("\n")

# 6. Simular download da B3
cat("6️⃣ SIMULANDO DOWNLOAD B3:\n")
tryCatch({
  # Simular dados da B3
  dados_b3 <- data.frame(
    Ativo = c("DI1F25", "DI1G25", "DI1H25"),
    Vct = c("2025-01-15", "2025-02-15", "2025-03-15"),
    AjusteD_1 = c(10.5, 10.6, 10.7),
    AjusteD0 = c(10.6, 10.7, 10.8),
    Variacao = c(0.1, 0.1, 0.1),
    AjPorContrato = c(1000, 1000, 1000)
  )
  
  data_str <- format(Sys.Date(), "%Y-%m-%d")
  caminho_saida <- file.path("data/ajustes/b3", paste0(data_str, "_DI1.csv"))
  
  write_csv(dados_b3, caminho_saida)
  if (file.exists(caminho_saida)) {
    cat("   ✅ Arquivo B3 simulado criado:", caminho_saida, "\n")
    cat("   📊 Tamanho:", file.size(caminho_saida), "bytes\n")
  } else {
    cat("   ❌ Falha ao criar arquivo B3 simulado\n")
  }
}, error = function(e) {
  cat("   ❌ Erro na simulação B3:", e$message, "\n")
})
cat("\n")

# 7. Verificar arquivos existentes
cat("7️⃣ ARQUIVOS EXISTENTES:\n")
for (dir in c("data/ajustes", "data/ajustes/b3", "data/ajustes/anbima")) {
  if (dir.exists(dir)) {
    files <- list.files(dir, full.names = TRUE)
    if (length(files) > 0) {
      cat("   📁", dir, ":\n")
      for (file in files) {
        file_size <- file.size(file)
        cat("      📄", basename(file), "(", file_size, "bytes)\n")
      }
    } else {
      cat("   📁", dir, ": (vazio)\n")
    }
  }
}
cat("\n")

# 8. Verificar configuração do Git
cat("8️⃣ VERIFICANDO GIT:\n")
tryCatch({
  git_status <- system("git status --porcelain", intern = TRUE)
  if (length(git_status) > 0) {
    cat("   📝 Arquivos modificados:\n")
    for (status in git_status) {
      cat("      ", status, "\n")
    }
  } else {
    cat("   ✅ Nenhum arquivo modificado\n")
  }
}, error = function(e) {
  cat("   ❌ Erro ao verificar git:", e$message, "\n")
})
cat("\n")

cat("🏁 DIAGNÓSTICO CONCLUÍDO!\n")
