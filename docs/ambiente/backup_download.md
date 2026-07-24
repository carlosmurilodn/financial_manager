# Backup por download

## Contexto

A aplicacao permite gerar um backup manual do banco PostgreSQL configurado em
`BACKUP_DATABASE_URL` ou `DATABASE_URL_FINANCIAL_MANAGER` e baixar o arquivo SQL
compactado diretamente no navegador.

## Variaveis de ambiente

- `BACKUP_DATABASE_URL`: URL completa do banco PostgreSQL que sera exportado.
  Em desenvolvimento, prefira esta variavel para nao trocar o banco principal
  da aplicacao local.
- `DATABASE_URL_FINANCIAL_MANAGER`: URL completa do banco PostgreSQL usado em
  producao. O backup usa essa variavel quando `BACKUP_DATABASE_URL` nao existir.

## Dependencias de runtime

O ambiente precisa ter `pg_dump` disponivel. A imagem Docker do projeto instala
`postgresql-client`, que fornece esse binario.
