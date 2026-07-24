# Backup manual para Google Drive

## Fluxo

Na pagina de relatorios, o card "Backup do Banco" envia uma requisicao `POST`
para `/reports/backup`.

O controller delega a execucao para `Backups::SupabaseToGoogleDrive`. O servico:

- cria um diretorio temporario;
- executa `pg_dump` no schema `public`;
- compacta o SQL em `.sql.gz`;
- envia o arquivo para a pasta configurada no Google Drive;
- remove os arquivos temporarios ao encerrar.

## Resultado na interface

Quando o backup termina, o usuario volta para a pagina de relatorios com flash
de sucesso. Em caso de erro de configuracao, conexao, dump ou upload, o usuario
recebe uma mensagem de falha.

## Limites

O backup roda de forma sincrona durante o clique. Se o banco crescer e o tempo de
execucao ficar alto, mover esse fluxo para um job assincromo e exibir status na
interface.
