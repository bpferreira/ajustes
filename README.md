# 📊 Ajustes Diários – ANBIMA & B3

Automação diária para download de dados públicos da ANBIMA e B3, com organização por produto e integração via GitHub Actions e Docker.

---


## 🚀 Funcionalidades

- Baixa automaticamente os ajustes da B3 via GitHub Actions.
- Baixa os arquivos da ANBIMA e separa cada aba em um CSV nomeado.
- Salva os arquivos organizados por data e produto.
- Scripts modulares, limpos e preparados para expansão.
- Dockerfile otimizado para execução local e CI/CD.


## 🔧 Estrutura de diretórios

.
├── R/
│   ├── baixar_anbima.R
│   └── baixar_b3.R
├── data/
│   └── ajustes/
│       ├── anbima/
│       │   ├── anbima_raw.xls
│       │   └── tesouro_prefixado.csv
│       └── b3/
│           ├── 2025-08-07_DI1.csv
│           └── 2025-08-07_DAP.csv
├── .github/
│   └── workflows/
│       └── ajustes.yml
├── Dockerfile
└── README.md


---

## 📥 Dados capturados

### 🔹 ANBIMA
- Download do arquivo `.xls` mais recente (último dia útil)
- Extração de **todas as abas** e conversão para `.csv`
- Armazenados em: `data/ajustes/anbima/<aba>.csv`

### 🔹 B3
- Download da **taxa DI1** e futuramente outros produtos
- Armazenado em: `data/ajustes/b3/DI1.csv`

---

## ⚙️ Execução local via Docker

### 1. Construir imagem
```bash
docker build -t ajustes .
