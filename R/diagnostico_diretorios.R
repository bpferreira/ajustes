# Script de diagnóstico para verificar diretórios e permissões
cat("🔍 DIAGNÓSTICO DE DIRETÓRIOS E PERMISSÕES\n")
cat("==========================================\n\n")

# 1. Verificar diretório atual
cat("1️⃣ DIRETÓRIO ATUAL:\n")
cat("   PWD:", getwd(), "\n")
cat("   Existe:", dir.exists("."), "\n\n")

# 2. Verificar se pasta data existe
cat("2️⃣ PASTA DATA:\n")
cat("   Existe data/:", dir.exists("data"), "\n")
if (dir.exists("data")) {
  cat("   Conteúdo de data/:\n")
  print(list.files("data"))
} else {
  cat("   ❌ Pasta data/ não existe\n")
}
cat("\n")

# 3. Criar pasta data se não existir
cat("3️⃣ CRIANDO PASTA DATA:\n")
if (!dir.exists("data")) {
  result <- tryCatch({
    dir.create("data", recursive = TRUE)
    cat("   ✅ Pasta data/ criada\n")
  }, error = function(e) {
    cat("   ❌ Erro ao criar data/:", e$message, "\n")
  })
} else {
  cat("   ✅ Pasta data/ já existe\n")
}
cat("\n")

# 4. Criar pasta data/ajustes
cat("4️⃣ CRIANDO PASTA DATA/AJUSTES:\n")
if (!dir.exists("data/ajustes")) {
  result <- tryCatch({
    dir.create("data/ajustes", recursive = TRUE)
    cat("   ✅ Pasta data/ajustes/ criada\n")
  }, error = function(e) {
    cat("   ❌ Erro ao criar data/ajustes/:", e$message, "\n")
  })
} else {
  cat("   ✅ Pasta data/ajustes/ já existe\n")
}
cat("\n")

# 5. Criar pastas específicas
cat("5️⃣ CRIANDO PASTAS ESPECÍFICAS:\n")
pastas <- c("data/ajustes/b3", "data/ajustes/anbima")
for (pasta in pastas) {
  if (!dir.exists(pasta)) {
    result <- tryCatch({
      dir.create(pasta, recursive = TRUE)
      cat("   ✅ Pasta", pasta, "criada\n")
    }, error = function(e) {
      cat("   ❌ Erro ao criar", pasta, ":", e$message, "\n")
    })
  } else {
    cat("   ✅ Pasta", pasta, "já existe\n")
  }
}
cat("\n")

# 6. Testar escrita de arquivo
cat("6️⃣ TESTE DE ESCRITA:\n")
test_file <- "data/ajustes/teste_diagnostico.csv"
result <- tryCatch({
  write.csv(data.frame(x = 1, y = 2), test_file)
  cat("   ✅ Arquivo de teste criado:", test_file, "\n")
  
  # Verificar se arquivo foi criado
  if (file.exists(test_file)) {
    cat("   ✅ Arquivo existe após criação\n")
    file.remove(test_file)
    cat("   ✅ Arquivo de teste removido\n")
  } else {
    cat("   ❌ Arquivo não existe após criação\n")
  }
}, error = function(e) {
  cat("   ❌ Erro ao criar arquivo de teste:", e$message, "\n")
})
cat("\n")

# 7. Verificar permissões
cat("7️⃣ VERIFICAÇÃO DE PERMISSÕES:\n")
pastas_verificar <- c("data", "data/ajustes", "data/ajustes/b3", "data/ajustes/anbima")
for (pasta in pastas_verificar) {
  if (dir.exists(pasta)) {
    test_file <- file.path(pasta, "teste_perm.csv")
    result <- tryCatch({
      write.csv(data.frame(test = 1), test_file)
      cat("   ✅ Escrita OK em", pasta, "\n")
      file.remove(test_file)
    }, error = function(e) {
      cat("   ❌ Sem permissão de escrita em", pasta, ":", e$message, "\n")
    })
  }
}
cat("\n")

# 8. Listar estrutura final
cat("8️⃣ ESTRUTURA FINAL:\n")
if (dir.exists("data")) {
  cat("   data/:\n")
  print(list.files("data", recursive = TRUE))
} else {
  cat("   ❌ Pasta data/ não existe\n")
}
cat("\n")

cat("🏁 DIAGNÓSTICO CONCLUÍDO\n")
