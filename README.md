# CP5 — Wines | Grupo sInApse

Checkpoint 5 do 2º semestre do curso **Tecnólogo em Inteligência Artificial — FIAP**, integrando as disciplinas
**Statistical Computing with R & Python** e **Machine Learning & Modelling**.

O trabalho usa o dataset **WINES**: 178 vinhos de três cultivares da mesma região da Itália, descritos por
13 medidas químicas ([Kaggle](https://www.kaggle.com/datasets/harrywang/wine-dataset-for-clustering)).

## Integrantes

| Nome | RM |
|---|---|
| Silvio Dela Libera Neto | 572632 |
| Thainá Almeida Santos | 569110 |
| Vitor Barbosa Vitorino | 570475 |

## Estrutura

```
├── parte1_statistical_computing/
│   ├── cp5_sinapse_estatistica.R   # análise estatística comentada (R)
│   └── wine-clustering.csv         # dataset
└── parte2_machine_learning/        # K-means (em desenvolvimento)
```

## Parte 1 — Statistical Computing (R)

Análise exploratória de duas variáveis quantitativas contínuas, escolhidas porque a Parte 2 compara os grupos de
vinhos justamente por teor alcoólico e acidez:

- **Alcohol**: teor alcoólico (% vol.)
- **Malic_Acid**: ácido málico (g/L)

| Item | Conteúdo |
|---|---|
| **a) Visualização** | Tabela de distribuição de frequências (fi, fia, fr, fra) e histograma de cada variável |
| **b) Análise descritiva** | Média, mediana e moda; amplitude, variância, desvio padrão e coeficiente de variação; quartis, boxplot e outliers |
| **c) Análise probabilística** | Álcool: Distribuição Normal, validada pela regra 68–95–99,7%, com 3 cálculos (`pnorm`/`qnorm`). Ácido málico: distribuição amostral da média (Teorema Central do Limite), com 2 cálculos e verificação por simulação (`set.seed`/`sample`) |

As interpretações de cada resultado estão nos comentários do próprio código.

### Principais resultados

- **Teor alcoólico:** distribuição simétrica, com variabilidade baixa (CV = 6,24%) e bem descrita por uma
  Normal N(13,00 ; 0,81). P(12% ≤ X ≤ 14%) ≈ 78,2%, um evento muito provável.
- **Ácido málico:** distribuição assimétrica à direita, com variabilidade muito alta (CV = 47,82%) e 3 outliers.
  Não segue uma Normal, mas a média de lotes de 30 vinhos segue (TCL):
  P(média > 2,6 g/L) ≈ 9,8%, um evento pouco provável.
- A acidez varia muito mais entre os vinhos do que o álcool. Por isso deve ser a característica que mais
  diferencia os grupos no K-means.

### Como executar

1. Abra `parte1_statistical_computing/cp5_sinapse_estatistica.R` no RStudio.
2. Defina o diretório de trabalho: **Session > Set Working Directory > To Source File Location**.
3. Instale o pacote usado, se necessário: `install.packages("DescTools")`.
4. Execute o script. Os gráficos usam apenas o R base.

## Parte 2 — Machine Learning & Modelling

Em desenvolvimento: agrupamento dos vinhos com K-means, com escolha do número de grupos pelos métodos Elbow e
Silhueta.
