# Backup manual por download

## Fluxo

Na pagina de relatorios, o card "Backup do Banco" envia uma requisicao `POST`
para `/reports/backup`.

O controller delega a execucao para `Backups::DatabaseDump`. O servico:

- cria um diretorio temporario;
- executa `pg_dump` no schema `public`;
- compacta o SQL em `.sql.gz`;
- le o arquivo compactado;
- retorna os bytes para o controller;
- remove os arquivos temporarios ao encerrar.

## Resultado na interface

Quando o backup termina, o navegador baixa um arquivo `.sql.gz`. Em caso de erro
de configuracao, conexao, dump ou compactacao, o usuario volta para relatorios
com mensagem de falha.

## Limites

O backup roda de forma sincrona durante o clique. Como o arquivo e enviado pelo
controller, bancos muito grandes podem consumir memoria durante a resposta.
