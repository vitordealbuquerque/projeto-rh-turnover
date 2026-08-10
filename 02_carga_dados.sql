-- Carga dos CSVs gerados em 00_gerar_base.py para dentro do schema rh
-- Delimitador ; (mesmo padrão usado nos outros projetos do portfólio)

SET search_path TO rh;

\copy departamentos FROM '03_dados/departamentos.csv' WITH (FORMAT csv, DELIMITER ';', HEADER true, ENCODING 'UTF8');
\copy funcionarios FROM '03_dados/funcionarios.csv' WITH (FORMAT csv, DELIMITER ';', HEADER true, ENCODING 'UTF8', NULL '');
\copy avaliacoes_desempenho FROM '03_dados/avaliacoes_desempenho.csv' WITH (FORMAT csv, DELIMITER ';', HEADER true, ENCODING 'UTF8');

-- Conferência rápida de volumetria
SELECT 'departamentos' AS tabela, COUNT(*) FROM departamentos
UNION ALL
SELECT 'funcionarios', COUNT(*) FROM funcionarios
UNION ALL
SELECT 'avaliacoes_desempenho', COUNT(*) FROM avaliacoes_desempenho;
