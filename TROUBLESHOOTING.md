# 🔧 Guia de Troubleshooting - Ajustes Diários

## 🚨 Problema: Arquivos não estão sendo salvos

### Possíveis Causas e Soluções

#### 1. **Problema com .gitignore** ✅ CORRIGIDO
**Causa**: O `.gitignore` estava ignorando todos os arquivos em `data/ajustes/**`

**Solução**: Atualizei o `.gitignore` para:
```gitignore
# Ignora apenas arquivos temporários
data/ajustes/*.xls
data/ajustes/*.xlsx
data/ajustes/anbima/anbima_raw.xls

# Permite arquivos CSV
!data/ajustes/*.csv
!data/ajustes/anbima/*.csv
!data/ajustes/b3/*.csv
```

#### 2. **Problema de Permissões**
**Verificar**: Se os diretórios têm permissão de escrita
```bash
# No GitHub Actions, execute:
Rscript R/teste_diretorios.R
```

#### 3. **Problema de Dependências**
**Verificar**: Se todos os pacotes R estão instalados
```r
# Teste no R:
library(httr)
library(readxl)
library(readr)
library(lubridate)
library(rvest)
library(xml2)
library(dplyr)
library(zoo)
library(purrr)
```

#### 4. **Problema de Rede**
**Verificar**: Se as URLs estão acessíveis
```bash
# Teste manual:
curl -I "https://www2.bmf.com.br/pages/portal/bmfbovespa/lumis/lum-ajustes-do-pregao-ptBR.asp"
```

## 🔍 Como Diagnosticar

### 1. **Verificar Logs do GitHub Actions**
- Acesse: `Actions` → `Ajustes Diário` → Última execução
- Procure por mensagens de erro nos logs

### 2. **Executar Teste Local**
```bash
# Construir e executar Docker
docker build -t ajustes .
docker run --rm ajustes Rscript R/teste_diretorios.R
```

### 3. **Verificar Estrutura de Arquivos**
```bash
# No GitHub Actions, verifique:
ls -la data/ajustes/
find data/ajustes -type f -name "*.csv"
```

## 🛠️ Comandos Úteis

### Testar Scripts Individualmente
```bash
# Testar B3
Rscript R/baixar_b3.R

# Testar ANBIMA
Rscript R/baixar_anbima.R
```

### Verificar Status do Git
```bash
git status
git add data/
git status
```

### Forçar Commit
```bash
git add -A
git commit -m "Forçar atualização"
git push
```

## 📊 Logs Esperados

### Sucesso
```
📥 Acessando: https://www2.bmf.com.br/...
✅ DI1 salvo em: data/ajustes/b3/2025-01-XX_DI1.csv
✅ DAP salvo em: data/ajustes/b3/2025-01-XX_DAP.csv
```

### Erro Comum
```
❌ Erro ao baixar DI1: Produto não encontrado: DI1
```

## 🔄 Próximos Passos

1. **Execute o workflow manualmente** no GitHub
2. **Verifique os logs** de cada etapa
3. **Teste localmente** se necessário
4. **Monitore** as próximas execuções automáticas

## 📞 Suporte

Se o problema persistir, verifique:
- [ ] Logs completos do GitHub Actions
- [ ] Status dos sites da B3 e ANBIMA
- [ ] Execução do script de teste
- [ ] Permissões do repositório
