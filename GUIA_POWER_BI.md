# Passo a passo — Power BI (Turnover e Desempenho)

Do zero até o dashboard: extração dos dados, modelo, todas as medidas DAX e qual gráfico usar em cada bloco do fundo (`04_prints/fundo_dashboard_powerbi.png`, prompt no item 15 de `PROMPTS_CLAUDE_DESIGN.md`).

---

## Parte 1 — Extração dos dados no Power BI

1. Extraia os 3 CSVs de `03_dados/` (`departamentos.csv`, `funcionarios.csv`, `avaliacoes_desempenho.csv`) numa pasta local, mantendo a estrutura `projeto-rh-turnover/03_dados/`.
2. Abra o Power BI Desktop → **Obter dados → Texto/CSV** → importe os 3 arquivos. Delimitador é `;` (ponto e vírgula) — confira se o Power BI detectou certo, senão ajuste manualmente na tela de pré-visualização.
3. No Power Query (**Transformar dados**), confirme os tipos de coluna: `data_admissao`/`data_desligamento`/`data_avaliacao` como Data, `salario_atual`/`nota_desempenho` como Decimal, `idade`/`engajamento_score` como Número Inteiro, `recomendado_promocao` como Verdadeiro/Falso.
4. **Início → Fechar e Aplicar**.
5. Confirme no painel "Dados" que veio: `funcionarios` (2.500 linhas), `departamentos` (12), `avaliacoes_desempenho` (4.333). Se algum número vier diferente, confira o CSV de origem.

## Parte 2 — Conferir o modelo

1. Vá na view **Modelo** (ícone de diagrama, barra lateral esquerda).
2. Confirme as duas relações: `departamentos[departamento_id]` → `funcionarios[departamento_id]` e `funcionarios[funcionario_id]` → `avaliacoes_desempenho[funcionario_id]`, ambas 1 para muitos, direção única.
3. Crie a coluna calculada `tempo_casa_anos` em `funcionarios` (mesma lógica do `03_limpeza.sql`), se ela não vier pronta da extração:

```dax
tempo_casa_anos = ROUND(DIVIDE(DATEDIFF(funcionarios[data_admissao], COALESCE(funcionarios[data_desligamento], DATE(2024,12,31)), DAY), 365.25), 1)
```

## Parte 3 — Medidas DAX

Crie cada uma como **Nova medida** (não confundir com coluna calculada — nome duplicado entre os dois trava o Power BI com erro de nome já em uso).

| Medida | Fórmula DAX | Formato | Valor real (referência) |
|---|---|---|---|
| Headcount Total | `COUNTROWS(funcionarios)` | inteiro | 2.500 |
| Ativos | `CALCULATE(COUNTROWS(funcionarios), funcionarios[status]="Ativo")` | inteiro | 2.164 |
| Desligados | `CALCULATE(COUNTROWS(funcionarios), funcionarios[status]="Desligado")` | inteiro | 336 |
| Turnover % | `DIVIDE([Desligados], [Headcount Total])` | percentual | 13,4% |
| Desligados Involuntarios | `CALCULATE(COUNTROWS(funcionarios), funcionarios[tipo_desligamento]="Involuntario")` | inteiro | 82 |
| % Desligamento Involuntario | `DIVIDE([Desligados Involuntarios], [Desligados])` | percentual | 24,4% |
| Tempo Medio de Casa | `AVERAGE(funcionarios[tempo_casa_anos])` | decimal (anos) | 3,4 |
| Salario Medio | `AVERAGE(funcionarios[salario_atual])` | moeda | R$ 8.535,32 |
| Nota Media | `AVERAGE(avaliacoes_desempenho[nota_desempenho])` | decimal | 3,69 (ativos) |
| Engajamento Medio | `AVERAGE(avaliacoes_desempenho[engajamento_score])` | decimal | 71,2 (ativos) |

## Parte 4 — Gráficos: o que colocar em cada bloco do fundo

Abra `fundo_dashboard_powerbi.png` (gerado a partir do prompt do item 15 em `PROMPTS_CLAUDE_DESIGN.md`) como imagem de fundo da página (**Formatar página → Imagem de fundo**, transparência 0%) e encaixe os visuais exatamente nas molduras:

### Cards de KPI (topo)

| Bloco no fundo | Visual | Campo |
|---|---|---|
| HEADCOUNT TOTAL | Cartão | `Headcount Total` |
| TURNOVER GERAL | Cartão | `Turnover %` |
| % DESLIGAMENTO INVOLUNTÁRIO | Cartão | `% Desligamento Involuntario` |
| TEMPO MÉDIO DE CASA | Cartão | `Tempo Medio de Casa` |
| SALÁRIO MÉDIO | Cartão | `Salario Medio` |

### TURNOVER POR DEPARTAMENTO

Visual (ícone no painel Visualizações): **Gráfico de Barras Agrupadas** (barra horizontal — facilita ler o nome dos 12 departamentos). Ordenar decrescente por turnover.
* Eixo Y: `departamentos[nome_departamento]`
* Valores: `Turnover %`

### DESEMPENHO x MOTIVO DE SAÍDA

Visual (ícone no painel Visualizações): **Gráfico de Colunas Clusterizadas** (duas colunas lado a lado por grupo, escalas parecidas o suficiente pra não precisar de eixo duplo).
* Eixo X: coluna calculada de grupo (Ativo / Desligado voluntário / Desligado involuntário / Aposentadoria — replica o `CASE` do `04_analises.sql`)
* Valores: `Nota Media` e `Engajamento Medio`

### SALÁRIO POR SENIORIDADE

Visual (ícone no painel Visualizações): **Gráfico de Colunas Clusterizadas**, ordenado do maior salário mediano pro menor.
* Eixo X: `funcionarios[senioridade]`
* Valores: crie 3 medidas com `PERCENTILEX.INC` — `Salario P25 = PERCENTILEX.INC(funcionarios, funcionarios[salario_atual], 0.25)`, o mesmo pra mediana (0,5) e P75 (0,75) — as três lado a lado no mesmo gráfico.

### TURNOVER POR TEMPO DE CASA

Visual (ícone no painel Visualizações): **Gráfico de Colunas Agrupadas**.
* Eixo X: coluna calculada de faixa (`0 a 1 ano`, `1 a 2 anos`, `2 a 4 anos`, `Acima de 4 anos` — replica o `CASE` da Análise 4 do SQL), ordenada manualmente nessa sequência (**Classificar por coluna** → criar uma coluna auxiliar numérica pra forçar a ordem).
* Valores: `Turnover %`

### ENGAJAMENTO POR MODELO DE TRABALHO

Visual (ícone no painel Visualizações): **Gráfico de Colunas Agrupadas**, filtrado pro ciclo `2024-S2` (**Filtros → avaliacoes_desempenho[ciclo] = "2024-S2"**).
* Eixo X: `funcionarios[modelo_trabalho]`
* Valores: `Engajamento Medio`

## Depois de montar

Tira os prints direto do Power BI Desktop com os dados reais carregados — são esses que entram no README e no post do LinkedIn (nunca usar mockup fabricado no lugar do print real).
