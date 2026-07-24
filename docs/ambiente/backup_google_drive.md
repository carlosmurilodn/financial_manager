# Backup no Google Drive

## Contexto

A aplicacao permite gerar um backup manual do banco PostgreSQL configurado em
`BACKUP_DATABASE_URL` ou `DATABASE_URL_FINANCIAL_MANAGER` e enviar o arquivo
compactado para o Google Drive.

## Variaveis de ambiente

- `BACKUP_DATABASE_URL`: URL completa do banco PostgreSQL que sera exportado.
  Em desenvolvimento, prefira esta variavel para nao trocar o banco principal
  da aplicacao local.
- `DATABASE_URL_FINANCIAL_MANAGER`: URL completa do banco PostgreSQL usado em
  producao. O backup usa essa variavel quando `BACKUP_DATABASE_URL` nao existir.
- `GOOGLE_DRIVE_FOLDER_ID`: ID da pasta do Google Drive que recebera os backups.
- `GOOGLE_SERVICE_ACCOUNT_JSON`: JSON completo da service account com permissao
  de escrita na pasta.

## Configuracao do Google Drive

Crie uma service account no Google Cloud, habilite a Google Drive API e copie o
JSON da chave para `GOOGLE_SERVICE_ACCOUNT_JSON`.

Compartilhe a pasta de destino do Drive com o e-mail da service account. Sem esse
compartilhamento o upload falha por permissao.

O backup usa o escopo `https://www.googleapis.com/auth/drive` para que a service
account consiga validar e gravar na pasta compartilhada. O escopo
`drive.file` pode nao enxergar pastas que nao foram criadas pelo proprio app.

## Dependencias de runtime

O ambiente precisa ter `pg_dump` disponivel. A imagem Docker do projeto instala
`postgresql-client`, que fornece esse binario.
