# Backup no Google Drive

## Contexto

A aplicacao permite gerar um backup manual do banco PostgreSQL configurado em
`DATABASE_URL_FINANCIAL_MANAGER` e enviar o arquivo compactado para o Google
Drive.

## Variaveis de ambiente

- `DATABASE_URL_FINANCIAL_MANAGER`: URL completa do banco PostgreSQL usado em
  producao.
- `GOOGLE_DRIVE_FOLDER_ID`: ID da pasta do Google Drive que recebera os backups.
- `GOOGLE_SERVICE_ACCOUNT_JSON`: JSON completo da service account com permissao
  de escrita na pasta.

## Configuracao do Google Drive

Crie uma service account no Google Cloud, habilite a Google Drive API e copie o
JSON da chave para `GOOGLE_SERVICE_ACCOUNT_JSON`.

Compartilhe a pasta de destino do Drive com o e-mail da service account. Sem esse
compartilhamento o upload falha por permissao.

## Dependencias de runtime

O ambiente precisa ter `pg_dump` disponivel. A imagem Docker do projeto instala
`postgresql-client`, que fornece esse binario.
