# Turnover e Desempenho — Panorama de RH 2024

Projeto de portfólio para transição de carreira para Análise de Dados. Setor: **people analytics / RH corporativo**. Ciclo completo: modelagem SQL, limpeza, análise e dashboard executivo em Power BI.

Passo a passo de como o dashboard foi montado (modelo, medidas DAX, gráficos): [`documentos/GUIA_POWER_BI.md`](documentos/GUIA_POWER_BI.md). Documentação completa do projeto: [`documentos/DOCUMENTACAO_PROJETO.md`](documentos/DOCUMENTACAO_PROJETO.md).

---

## A base

Base sintética (mas calibrada com padrões reais de mercado de RH) de uma empresa fictícia de tecnologia em 2024: 2.500 funcionários que passaram pelo quadro entre 2018 e 2024, distribuídos em 12 departamentos e 4 diretorias, com histórico de admissão, salário, senioridade, modelo de trabalho e, quando aplicável, desligamento. Cada funcionário ativo também tem até duas avaliações de desempenho no ano (ciclos 2024-S1 e 2024-S2), com nota, engajamento e recomendação de promoção.

Os números a seguir vieram de execução real de SQL contra essa base, não são estimativa: 2.500 funcionários, 2.164 ativos e 336 desligados — turnover geral de 13,4%, tempo médio de casa de 3,4 anos e salário médio de R$ 8.535,32. Dos desligamentos, 70,8% foram voluntários, 24,4% involuntários e 4,8% aposentadoria.

---

## Como o projeto foi montado

A base foi gerada em Python, com distribuições calibradas para reproduzir padrões reais de turnover: risco maior de saída em áreas comerciais e de atendimento (Comercial, Customer Success, Suporte Técnico), risco menor em áreas técnicas (Dados & Analytics, Jurídico), maior rotatividade no primeiro ano de casa, e queda de nota/engajamento associada a desligamento involuntário.

A modelagem, limpeza e análise rodaram em PostgreSQL, num schema próprio (`rh`). O pipeline usa CTE, window function (`RANK` para ranquear departamentos por turnover), `FILTER (WHERE ...)` para as contagens condicionais e `PERCENTILE_CONT` para medir a distribuição salarial por senioridade. Os blocos de análise estão em `02_sql/04_analises.sql`.

O dashboard final foi montado no Power BI, com modelo semântico próprio, medidas DAX e visuais nativos (cartão, barras e colunas). O passo a passo completo, incluindo o prompt da imagem de fundo usada como base do layout, está em `documentos/GUIA_POWER_BI.md`.

---

## Estrutura do repositório

```
projeto-rh-turnover/
├── README.md
├── 00_gerar_base.py                        # geração da base sintética em Python
├── 02_sql/
│   ├── 01_criar_tabelas.sql                # DDL + índices + constraints
│   ├── 02_carga_dados.sql                  # COPY dos CSV
│   ├── 03_limpeza.sql                      # checagens + coluna derivada tempo_casa_anos
│   └── 04_analises.sql                     # análises com CTE/RANK/FILTER/PERCENTILE_CONT
├── 03_dados/
│   ├── departamentos.csv                   # 12 departamentos
│   ├── funcionarios.csv                    # 2.500 funcionários
│   └── avaliacoes_desempenho.csv           # 4.333 avaliações (ciclos 2024-S1 e 2024-S2)
├── 04_prints/                              # imagens reais do projeto
│   ├── fluxograma_ferramentas.png          # pipeline de ferramentas
│   ├── capa_linkedin.png                   # capa com os KPIs principais
│   ├── print_dashboard_final.png           # dashboard Power BI completo
│   ├── print_sql_turnover_departamento.png       # print real do SQL — ranking de turnover por departamento (RANK)
│   ├── print_sql_desempenho_motivo_saida.png     # print real do SQL — desempenho x motivo de saída
│   └── print_sql_salario_senioridade.png         # print real do SQL — distribuição salarial (PERCENTILE_CONT)
└── documentos/
    ├── DOCUMENTACAO_PROJETO.md             # documentação completa do projeto (conceitos, dataset, checklist)
    ├── GUIA_POWER_BI.md                    # passo a passo do dashboard: modelo, medidas DAX, gráficos
    └── 05_post_linkedin.md                 # texto pronto pra postar
```

---

## O que o dashboard mostra

O bloco de topo traz os cinco números que resumem o quadro: headcount total, turnover geral, percentual de desligamento involuntário, tempo médio de casa e salário médio. O ranking de turnover por departamento mostra Comercial (21,6%) e Customer Success (20,8%) na ponta mais alta, contra Jurídico (7,6%) e Dados & Analytics (7,7%) na ponta mais baixa — quase 3x de diferença entre o topo e a base do ranking. O cruzamento de desempenho com motivo de saída é o achado mais direto: quem foi desligado involuntariamente tinha nota média de 2,70 e engajamento de 43,0, bem abaixo do resto da empresa — mas quem pediu pra sair por conta própria tinha nota (3,69) e engajamento (71,4) praticamente idênticos aos de quem ficou (3,69 e 71,2), ou seja, desligamento voluntário não é sobre desempenho. A distribuição salarial por senioridade mostra a mediana subindo de R$ 2.185,82 (Estagiário) até R$ 22.603,46 (Gerente), e o turnover por tempo de casa confirma o padrão clássico de risco: 22,5% no primeiro ano, caindo pra 11,0% em quem já tem mais de 4 anos de casa.

---

## Rodando localmente

Instale PostgreSQL 14+ e um cliente (pgAdmin ou psql). Crie um banco `rh_turnover_db`, rode `02_sql/01_criar_tabelas.sql`, carregue os CSV de `03_dados/` com `02_sql/02_carga_dados.sql` e rode `02_sql/03_limpeza.sql` seguido de `02_sql/04_analises.sql`. Para o dashboard, siga `documentos/GUIA_POWER_BI.md` para remontar em Power BI Desktop.

---

## Autor

**Vitor França** — engcivil.vitorfranca@gmail.com
Em transição para Análise de Dados.
