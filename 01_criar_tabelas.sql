-- Criação do schema e das tabelas do projeto de People Analytics (turnover)

CREATE SCHEMA IF NOT EXISTS rh;
SET search_path TO rh;

DROP TABLE IF EXISTS avaliacoes_desempenho CASCADE;
DROP TABLE IF EXISTS funcionarios CASCADE;
DROP TABLE IF EXISTS departamentos CASCADE;

CREATE TABLE departamentos (
    departamento_id     INTEGER PRIMARY KEY,
    nome_departamento   VARCHAR(50) NOT NULL,
    diretoria           VARCHAR(50) NOT NULL
);

CREATE TABLE funcionarios (
    funcionario_id       INTEGER PRIMARY KEY,
    nome_completo         VARCHAR(100) NOT NULL,
    genero                CHAR(1) NOT NULL,
    idade                 SMALLINT NOT NULL,
    cidade                VARCHAR(50) NOT NULL,
    uf                    CHAR(2) NOT NULL,
    departamento_id       INTEGER NOT NULL REFERENCES departamentos(departamento_id),
    cargo                 VARCHAR(80) NOT NULL,
    senioridade            VARCHAR(20) NOT NULL,
    modelo_trabalho        VARCHAR(20) NOT NULL,
    data_admissao          DATE NOT NULL,
    salario_atual           NUMERIC(10,2) NOT NULL,
    status                 VARCHAR(15) NOT NULL,
    data_desligamento       DATE,
    tipo_desligamento       VARCHAR(20),
    motivo_desligamento      VARCHAR(60)
);

CREATE TABLE avaliacoes_desempenho (
    avaliacao_id          INTEGER PRIMARY KEY,
    funcionario_id         INTEGER NOT NULL REFERENCES funcionarios(funcionario_id),
    ciclo                  VARCHAR(10) NOT NULL,
    data_avaliacao          DATE NOT NULL,
    nota_desempenho          NUMERIC(2,1) NOT NULL,
    engajamento_score        SMALLINT NOT NULL,
    recomendado_promocao      BOOLEAN NOT NULL
);

CREATE INDEX idx_funcionarios_departamento ON funcionarios(departamento_id);
CREATE INDEX idx_funcionarios_status ON funcionarios(status);
CREATE INDEX idx_avaliacoes_funcionario ON avaliacoes_desempenho(funcionario_id);
