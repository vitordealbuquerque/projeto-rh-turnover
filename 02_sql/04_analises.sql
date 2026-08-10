-- Análises principais — People Analytics / Turnover
-- CTE, window functions (RANK, LAG) e PERCENTILE_CONT, no mesmo espírito
-- técnico dos outros projetos do portfólio, aplicados a segmentos de RH.

SET search_path TO rh;

-- ===========================================================================
-- KPI 1 — Visão geral (números que vão pro card do dashboard e pro README)
-- ===========================================================================

SELECT
    COUNT(*) AS headcount_total_2024,
    COUNT(*) FILTER (WHERE status = 'Ativo') AS ativos,
    COUNT(*) FILTER (WHERE status = 'Desligado') AS desligados,
    ROUND(COUNT(*) FILTER (WHERE status = 'Desligado')::NUMERIC / COUNT(*) * 100, 1) AS turnover_geral_pct,
    ROUND(AVG(tempo_casa_anos), 1) AS tempo_medio_casa_anos,
    ROUND(AVG(salario_atual), 2) AS salario_medio
FROM funcionarios;

SELECT
    tipo_desligamento,
    COUNT(*) AS total,
    ROUND(COUNT(*)::NUMERIC / SUM(COUNT(*)) OVER () * 100, 1) AS pct_dos_desligamentos
FROM funcionarios
WHERE status = 'Desligado'
GROUP BY tipo_desligamento
ORDER BY total DESC;

-- ===========================================================================
-- ANÁLISE 1 — Ranking de turnover por departamento (RANK)
-- ===========================================================================

WITH turnover_dept AS (
    SELECT
        d.nome_departamento,
        d.diretoria,
        COUNT(*) AS total_funcionarios,
        COUNT(*) FILTER (WHERE f.status = 'Desligado') AS total_desligados,
        ROUND(COUNT(*) FILTER (WHERE f.status = 'Desligado')::NUMERIC / COUNT(*) * 100, 1) AS turnover_pct
    FROM funcionarios f
    JOIN departamentos d ON d.departamento_id = f.departamento_id
    GROUP BY d.nome_departamento, d.diretoria
)
SELECT
    nome_departamento,
    diretoria,
    total_funcionarios,
    total_desligados,
    turnover_pct,
    RANK() OVER (ORDER BY turnover_pct DESC) AS ranking_turnover
FROM turnover_dept
ORDER BY ranking_turnover;

-- ===========================================================================
-- ANÁLISE 2 — Desempenho e engajamento por motivo de saída
-- Cruza todas as avaliações de 2024 com o desfecho do funcionário pra ver
-- se quem foi desligado involuntariamente já vinha com nota/engajamento
-- mais baixo, e se desligamento voluntário tem alguma relação com nota
-- (spoiler: não — quem pede pra sair performa igual a quem ficou).
-- ===========================================================================

SELECT
    CASE
        WHEN f.status = 'Desligado' AND f.tipo_desligamento = 'Involuntario' THEN 'Desligado (involuntário)'
        WHEN f.status = 'Desligado' AND f.tipo_desligamento = 'Voluntario' THEN 'Desligado (voluntário)'
        WHEN f.status = 'Desligado' AND f.tipo_desligamento = 'Aposentadoria' THEN 'Desligado (aposentadoria)'
        ELSE 'Ativo'
    END AS grupo,
    COUNT(*) AS total_avaliacoes,
    ROUND(AVG(a.nota_desempenho), 2) AS nota_media,
    ROUND(AVG(a.engajamento_score), 1) AS engajamento_medio,
    ROUND(100.0 * SUM(CASE WHEN a.recomendado_promocao THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_recomendado_promocao
FROM avaliacoes_desempenho a
JOIN funcionarios f ON f.funcionario_id = a.funcionario_id
GROUP BY 1
ORDER BY nota_media;

-- ANÁLISE 2b (extra, mesma ideia com LAG) — compara a nota do ciclo 2024-S2
-- com a nota do ciclo anterior, funcionário a funcionário. Amostra pequena
-- pra quem desligou (poucos têm as duas avaliações no ano), mas confirma
-- a mesma direção do resultado acima.
WITH evolucao AS (
    SELECT
        a.funcionario_id,
        f.status,
        f.tipo_desligamento,
        a.ciclo,
        a.nota_desempenho,
        LAG(a.nota_desempenho) OVER (PARTITION BY a.funcionario_id ORDER BY a.ciclo) AS nota_ciclo_anterior
    FROM avaliacoes_desempenho a
    JOIN funcionarios f ON f.funcionario_id = a.funcionario_id
)
SELECT
    CASE
        WHEN status = 'Desligado' AND tipo_desligamento = 'Involuntario' THEN 'Desligado (involuntário)'
        WHEN status = 'Desligado' AND tipo_desligamento = 'Voluntario' THEN 'Desligado (voluntário)'
        ELSE 'Ativo'
    END AS grupo,
    COUNT(*) AS pares_de_avaliacao,
    ROUND(AVG(nota_ciclo_anterior), 2) AS nota_media_s1,
    ROUND(AVG(nota_desempenho), 2) AS nota_media_s2,
    ROUND(AVG(nota_desempenho - nota_ciclo_anterior), 2) AS variacao_media
FROM evolucao
WHERE nota_ciclo_anterior IS NOT NULL
GROUP BY 1
ORDER BY variacao_media;

-- ===========================================================================
-- ANÁLISE 3 — Distribuição salarial por senioridade (PERCENTILE_CONT)
-- ===========================================================================

SELECT
    senioridade,
    COUNT(*) AS total_funcionarios,
    ROUND(PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY salario_atual)::NUMERIC, 2) AS salario_p25,
    ROUND(PERCENTILE_CONT(0.5)  WITHIN GROUP (ORDER BY salario_atual)::NUMERIC, 2) AS salario_mediana,
    ROUND(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY salario_atual)::NUMERIC, 2) AS salario_p75
FROM funcionarios
GROUP BY senioridade
ORDER BY salario_mediana DESC;

-- ===========================================================================
-- ANÁLISE 4 — Turnover por faixa de tempo de casa (curva de risco)
-- ===========================================================================

SELECT
    CASE
        WHEN tempo_casa_anos < 1 THEN '0 a 1 ano'
        WHEN tempo_casa_anos < 2 THEN '1 a 2 anos'
        WHEN tempo_casa_anos < 4 THEN '2 a 4 anos'
        ELSE 'Acima de 4 anos'
    END AS faixa_tempo_casa,
    COUNT(*) AS total_funcionarios,
    COUNT(*) FILTER (WHERE status = 'Desligado') AS desligados,
    ROUND(COUNT(*) FILTER (WHERE status = 'Desligado')::NUMERIC / COUNT(*) * 100, 1) AS turnover_pct
FROM funcionarios
GROUP BY 1
ORDER BY MIN(tempo_casa_anos);

-- ===========================================================================
-- ANÁLISE 5 — Engajamento médio por modelo de trabalho (2024-S2)
-- ===========================================================================

SELECT
    f.modelo_trabalho,
    COUNT(*) AS avaliacoes,
    ROUND(AVG(a.engajamento_score), 1) AS engajamento_medio,
    ROUND(AVG(a.nota_desempenho), 2) AS nota_media
FROM avaliacoes_desempenho a
JOIN funcionarios f ON f.funcionario_id = a.funcionario_id
WHERE a.ciclo = '2024-S2'
GROUP BY f.modelo_trabalho
ORDER BY engajamento_medio DESC;
