-- Checagens de qualidade e pequenos ajustes antes de analisar

SET search_path TO rh;

-- 1) Ninguém desligado sem data de desligamento, e ninguém ativo com data preenchida
SELECT COUNT(*) AS inconsistencia_status_data
FROM funcionarios
WHERE (status = 'Desligado' AND data_desligamento IS NULL)
   OR (status = 'Ativo' AND data_desligamento IS NOT NULL);

-- 2) Data de desligamento sempre depois da admissão
SELECT COUNT(*) AS inconsistencia_datas
FROM funcionarios
WHERE data_desligamento IS NOT NULL AND data_desligamento <= data_admissao;

-- 3) Toda avaliação pertence a um ciclo válido
SELECT ciclo, COUNT(*) FROM avaliacoes_desempenho GROUP BY ciclo ORDER BY ciclo;

-- 4) Nota de desempenho dentro da escala 1.0–5.0 e engajamento 0–100
SELECT COUNT(*) AS fora_da_escala
FROM avaliacoes_desempenho
WHERE nota_desempenho < 1.0 OR nota_desempenho > 5.0
   OR engajamento_score < 0 OR engajamento_score > 100;

-- 5) Coluna auxiliar de tempo de casa em anos (usada nas análises)
--    idade em anos completos até o desligamento (ou até 31/12/2024 se ainda ativo)
ALTER TABLE funcionarios DROP COLUMN IF EXISTS tempo_casa_anos;
ALTER TABLE funcionarios ADD COLUMN tempo_casa_anos NUMERIC(4,1);

UPDATE funcionarios
SET tempo_casa_anos = ROUND(
    (COALESCE(data_desligamento, DATE '2024-12-31') - data_admissao) / 365.25,
    1
);
