# Script de teste para verificar diretórios e permissões
cat("🔍 Testando criação de diretórios...\n")

# Teste 1: Criar diretórios
dirs <- c("data/ajustes/b3", "data/ajustes/anbima")
for (dir in dirs) {
  result <- tryCatch({
    dir.create(dir, recursive = TRUE, showWarnings = FALSE)
    cat("✅ Diretório criado/verificado:", dir, "\n")
  }, error = function(e) {
    cat("❌ Erro ao criar diretório", dir, ":", e$message, "\n")
  })
}

# Teste 2: Verificar se os diretórios existem
for (dir in dirs) {
  if (dir.exists(dir)) {
    cat("✅ Diretório existe:", dir, "\n")
  } else {
    cat("❌ Diretório não existe:", dir, "\n")
  }
}

# Teste 3: Testar escrita de arquivo
test_file <- "data/ajustes/teste.csv"
result <- tryCatch({
  write.csv(data.frame(x = 1, y = 2), test_file, row.names = FALSE)
  cat("✅ Arquivo de teste criado:", test_file, "\n")
  
  # Verificar se o arquivo foi criado
  if (file.exists(test_file)) {
    cat("✅ Arquivo existe após criação\n")
    file.remove(test_file)
    cat("✅ Arquivo de teste removido\n")
  } else {
    cat("❌ Arquivo não foi criado\n")
  }
}, error = function(e) {
  cat("❌ Erro ao criar arquivo de teste:", e$message, "\n")
})

# Teste 4: Listar conteúdo
cat("📁 Conteúdo atual:\n")
for (dir in dirs) {
  if (dir.exists(dir)) {
    files <- list.files(dir, full.names = TRUE)
    if (length(files) > 0) {
      cat("📁", dir, ":", paste(basename(files), collapse = ", "), "\n")
    } else {
      cat("📁", dir, ": (vazio)\n")
    }
  }
}

cat("🏁 Teste concluído!\n")
