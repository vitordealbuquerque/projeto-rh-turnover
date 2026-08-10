Faaaala, Data Hunters! Mais um projeto tocado nos meus estudos por conta própria, e dessa vez desenvolvi o senso analítico em cima de people analytics — turnover e desempenho de RH.

Modelei do zero o quadro de uma empresa fictícia: 2.500 funcionários passando pela base entre 2018 e 2024, 12 departamentos, avaliações de desempenho semestrais. Base sintética com apoio de IA, toda a modelagem e análise em PostgreSQL, dashboard fechado no Power BI.

Pra desenvolver o senso analítico usei CTE, window function (RANK pra ranquear departamento por turnover), FILTER pra contagem condicional e PERCENTILE_CONT pra olhar a distribuição salarial por senioridade.

Os números: turnover geral de 13,4%, com Comercial (21,6%) e Customer Success (20,8%) na ponta mais alta e Jurídico (7,6%) na mais baixa. O achado que mais chamou atenção: quem foi desligado involuntariamente tinha nota de desempenho bem mais baixa (2,70 contra 3,69 da empresa) — mas quem pediu pra sair por conta própria tinha nota e engajamento praticamente idênticos a quem ficou. Turnover voluntário, pelo menos nessa base, não é sobre desempenho.

Sou eng civil migrando pra dados, treinando isso nos meus estudos. Se você tá na mesma pegada, chega junto. Recrutador de olho em vaga jr, chama no DM.

Link do repo no primeiro comentário.

#analisededados #sql #powerbi #rh

---

Primeiro comentário (colar após publicar):

Repositório completo aqui: https://github.com/vitordealbuquerque/projeto-rh-turnover
