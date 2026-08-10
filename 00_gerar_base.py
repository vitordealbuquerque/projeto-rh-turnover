"""
Gera a base sintetica do projeto de People Analytics (turnover e desempenho).

Simula o quadro de funcionarios de uma empresa de tecnologia fictícia entre
2018 e 2024, com foco no ano de 2024 para as analises de turnover, e os
ciclos de avaliacao de desempenho de 2024 (S1 e S2).

Saida: 3 CSVs em 03_dados/ (departamentos, funcionarios, avaliacoes_desempenho)
"""

import numpy as np
import pandas as pd
from datetime import date, timedelta
import random

random.seed(42)
np.random.seed(42)

# ---------------------------------------------------------------------------
# 1. Departamentos
# ---------------------------------------------------------------------------

departamentos = [
    {"departamento_id": 1, "nome_departamento": "Engenharia de Software", "diretoria": "Produto & Tecnologia", "turnover_peso": 0.7},
    {"departamento_id": 2, "nome_departamento": "Dados & Analytics", "diretoria": "Produto & Tecnologia", "turnover_peso": 0.6},
    {"departamento_id": 3, "nome_departamento": "Produto", "diretoria": "Produto & Tecnologia", "turnover_peso": 0.7},
    {"departamento_id": 4, "nome_departamento": "Comercial", "diretoria": "Receita", "turnover_peso": 1.8},
    {"departamento_id": 5, "nome_departamento": "Marketing", "diretoria": "Receita", "turnover_peso": 1.1},
    {"departamento_id": 6, "nome_departamento": "Customer Success", "diretoria": "Receita", "turnover_peso": 1.5},
    {"departamento_id": 7, "nome_departamento": "Suporte Tecnico", "diretoria": "Operacoes", "turnover_peso": 1.6},
    {"departamento_id": 8, "nome_departamento": "Operacoes", "diretoria": "Operacoes", "turnover_peso": 1.0},
    {"departamento_id": 9, "nome_departamento": "Recursos Humanos", "diretoria": "Administrativo", "turnover_peso": 0.8},
    {"departamento_id": 10, "nome_departamento": "Financeiro", "diretoria": "Administrativo", "turnover_peso": 0.7},
    {"departamento_id": 11, "nome_departamento": "Juridico", "diretoria": "Administrativo", "turnover_peso": 0.5},
    {"departamento_id": 12, "nome_departamento": "Administrativo", "diretoria": "Administrativo", "turnover_peso": 0.9},
]
df_departamentos = pd.DataFrame(departamentos)

# ---------------------------------------------------------------------------
# 2. Funcionarios
# ---------------------------------------------------------------------------

N_FUNCIONARIOS = 2500

primeiros_nomes_m = ["Joao", "Pedro", "Lucas", "Gabriel", "Matheus", "Rafael", "Bruno", "Felipe",
                     "Guilherme", "Rodrigo", "Thiago", "Diego", "Marcelo", "Andre", "Eduardo",
                     "Vinicius", "Leonardo", "Gustavo", "Fernando", "Ricardo"]
primeiros_nomes_f = ["Maria", "Ana", "Juliana", "Camila", "Fernanda", "Larissa", "Amanda", "Beatriz",
                     "Patricia", "Carolina", "Aline", "Bruna", "Renata", "Vanessa", "Priscila",
                     "Debora", "Tatiane", "Natalia", "Luciana", "Daniela"]
sobrenomes = ["Silva", "Santos", "Oliveira", "Souza", "Rodrigues", "Ferreira", "Alves", "Pereira",
              "Lima", "Gomes", "Costa", "Ribeiro", "Martins", "Carvalho", "Almeida", "Lopes",
              "Soares", "Fernandes", "Vieira", "Barbosa", "Rocha", "Dias", "Nascimento", "Andrade"]

cidades_uf = [
    ("Sao Paulo", "SP"), ("Rio de Janeiro", "RJ"), ("Belo Horizonte", "MG"), ("Curitiba", "PR"),
    ("Porto Alegre", "RS"), ("Recife", "PE"), ("Salvador", "BA"), ("Fortaleza", "CE"),
    ("Florianopolis", "SC"), ("Brasilia", "DF"), ("Campinas", "SP"), ("Goiania", "GO"),
]

senioridades = ["Estagiario", "Junior", "Pleno", "Senior", "Especialista", "Coordenador", "Gerente"]
peso_senioridade = [0.06, 0.28, 0.32, 0.19, 0.08, 0.05, 0.02]

faixa_salarial = {
    "Estagiario": (1800, 2500),
    "Junior": (3500, 5500),
    "Pleno": (6000, 9500),
    "Senior": (9500, 15000),
    "Especialista": (13000, 19000),
    "Coordenador": (12000, 18000),
    "Gerente": (18000, 28000),
}

modelos_trabalho = ["Hibrido", "Remoto", "Presencial"]
peso_modelo = [0.5, 0.35, 0.15]

data_inicio_admissoes = date(2018, 1, 1)
data_fim_admissoes = date(2024, 11, 30)
dias_totais_admissao = (data_fim_admissoes - data_inicio_admissoes).days

data_inicio_desligamento = date(2024, 1, 1)
data_fim_desligamento = date(2024, 12, 31)
dias_totais_deslig = (data_fim_desligamento - data_inicio_desligamento).days

motivos_voluntario = ["Nova oportunidade de mercado", "Insatisfacao salarial", "Mudanca de carreira",
                      "Motivos pessoais/familiares", "Continuidade dos estudos"]
motivos_involuntario = ["Baixo desempenho", "Reestruturacao da area", "Reducao de quadro"]

funcionarios = []
for i in range(1, N_FUNCIONARIOS + 1):
    genero = random.choice(["M", "F"])
    nome = random.choice(primeiros_nomes_m if genero == "M" else primeiros_nomes_f)
    sobrenome1 = random.choice(sobrenomes)
    sobrenome2 = random.choice(sobrenomes)
    nome_completo = f"{nome} {sobrenome1} {sobrenome2}"

    idade = int(np.clip(np.random.normal(32, 7), 19, 62))
    cidade, uf = random.choice(cidades_uf)

    dep = df_departamentos.sample(1, weights=None).iloc[0]
    departamento_id = int(dep["departamento_id"])
    turnover_peso = dep["turnover_peso"]

    senioridade = np.random.choice(senioridades, p=peso_senioridade)
    sal_min, sal_max = faixa_salarial[senioridade]
    salario_atual = round(np.random.uniform(sal_min, sal_max), 2)

    modelo_trabalho = np.random.choice(modelos_trabalho, p=peso_modelo)

    dias_offset = int(np.random.uniform(0, dias_totais_admissao))
    data_admissao = data_inicio_admissoes + timedelta(days=dias_offset)

    # probabilidade de desligamento em 2024, ponderada pelo peso do departamento
    prob_desligamento = 0.145 * turnover_peso
    desligado = np.random.random() < prob_desligamento and data_admissao < date(2024, 11, 1)

    if desligado:
        status = "Desligado"
        dias_offset_deslig = int(np.random.uniform(0, dias_totais_deslig))
        data_desligamento = data_inicio_desligamento + timedelta(days=dias_offset_deslig)
        if data_desligamento <= data_admissao:
            data_desligamento = data_admissao + timedelta(days=random.randint(60, 400))
        if data_desligamento > date(2024, 12, 31):
            data_desligamento = date(2024, 12, 31)

        tipo_roll = np.random.random()
        if tipo_roll < 0.70:
            tipo_desligamento = "Voluntario"
            motivo_desligamento = random.choice(motivos_voluntario)
        elif tipo_roll < 0.95:
            tipo_desligamento = "Involuntario"
            motivo_desligamento = random.choice(motivos_involuntario)
        else:
            tipo_desligamento = "Aposentadoria"
            motivo_desligamento = "Aposentadoria"
    else:
        status = "Ativo"
        data_desligamento = None
        tipo_desligamento = None
        motivo_desligamento = None

    cargo = f"{senioridade} de {dep['nome_departamento']}"

    funcionarios.append({
        "funcionario_id": i,
        "nome_completo": nome_completo,
        "genero": genero,
        "idade": idade,
        "cidade": cidade,
        "uf": uf,
        "departamento_id": departamento_id,
        "cargo": cargo,
        "senioridade": senioridade,
        "modelo_trabalho": modelo_trabalho,
        "data_admissao": data_admissao,
        "salario_atual": salario_atual,
        "status": status,
        "data_desligamento": data_desligamento,
        "tipo_desligamento": tipo_desligamento,
        "motivo_desligamento": motivo_desligamento,
    })

df_funcionarios = pd.DataFrame(funcionarios)

# ---------------------------------------------------------------------------
# 3. Avaliacoes de desempenho (ciclos semestrais 2024)
# ---------------------------------------------------------------------------

ciclos = ["2024-S1", "2024-S2"]
ciclo_data_ref = {"2024-S1": date(2024, 6, 15), "2024-S2": date(2024, 12, 10)}

avaliacoes = []
avaliacao_id = 1
for _, f in df_funcionarios.iterrows():
    for ciclo in ciclos:
        data_ref = ciclo_data_ref[ciclo]

        # so avalia quem estava ativo na data do ciclo
        admitido_antes = f["data_admissao"] <= data_ref - timedelta(days=45)
        ainda_na_empresa = f["status"] == "Ativo" or (f["data_desligamento"] is not None and f["data_desligamento"] >= data_ref)
        if not (admitido_antes and ainda_na_empresa):
            continue

        # nota base depende de estar em processo de desligamento involuntario
        vai_ser_desligado_involuntario = (
            f["status"] == "Desligado"
            and f["tipo_desligamento"] == "Involuntario"
            and f["data_desligamento"] is not None
            and f["data_desligamento"] >= data_ref
        )

        media_nota = 2.6 if vai_ser_desligado_involuntario else 3.7
        nota_desempenho = round(float(np.clip(np.random.normal(media_nota, 0.55), 1.0, 5.0)), 1)

        media_engaj = 45 if vai_ser_desligado_involuntario else 72
        engajamento_score = int(np.clip(np.random.normal(media_engaj, 14), 5, 100))

        recomendado_promocao = bool(nota_desempenho >= 4.5 and engajamento_score >= 80 and np.random.random() < 0.6)

        avaliacoes.append({
            "avaliacao_id": avaliacao_id,
            "funcionario_id": int(f["funcionario_id"]),
            "ciclo": ciclo,
            "data_avaliacao": data_ref,
            "nota_desempenho": nota_desempenho,
            "engajamento_score": engajamento_score,
            "recomendado_promocao": recomendado_promocao,
        })
        avaliacao_id += 1

df_avaliacoes = pd.DataFrame(avaliacoes)

# ---------------------------------------------------------------------------
# 4. Ajustes de tipo pra exportacao segura (ver "armadilhas mapeadas")
# ---------------------------------------------------------------------------

df_funcionarios["idade"] = df_funcionarios["idade"].astype("Int64")
df_funcionarios["departamento_id"] = df_funcionarios["departamento_id"].astype("Int64")

df_avaliacoes["engajamento_score"] = df_avaliacoes["engajamento_score"].astype("Int64")
df_avaliacoes["recomendado_promocao"] = df_avaliacoes["recomendado_promocao"].map({True: "t", False: "f"})

# ---------------------------------------------------------------------------
# 5. Exportacao
# ---------------------------------------------------------------------------

df_departamentos.drop(columns=["turnover_peso"]).to_csv(
    "03_dados/departamentos.csv", sep=";", index=False, encoding="utf-8"
)
df_funcionarios.to_csv("03_dados/funcionarios.csv", sep=";", index=False, encoding="utf-8")
df_avaliacoes.to_csv("03_dados/avaliacoes_desempenho.csv", sep=";", index=False, encoding="utf-8")

print("Departamentos:", len(df_departamentos))
print("Funcionarios:", len(df_funcionarios))
print("  Ativos:", (df_funcionarios["status"] == "Ativo").sum())
print("  Desligados:", (df_funcionarios["status"] == "Desligado").sum())
print("Avaliacoes de desempenho:", len(df_avaliacoes))
