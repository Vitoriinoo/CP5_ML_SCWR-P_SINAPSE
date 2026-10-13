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
│   └── wine-clustering.csv         # dataset (usado nas duas partes)
└── parte2_machine_learning/
    └── cp5_sinapse_kmeans.ipynb    # K-Means comentado e executado (Python)
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

Agrupamento dos 178 vinhos com **K-Means**, usando o mesmo CSV da Parte 1. O notebook
`parte2_machine_learning/cp5_sinapse_kmeans.ipynb` está com todas as células executadas, e cada etapa traz a
justificativa da escolha feita.

| Item | Conteúdo |
|---|---|
| **a) Introdução** | Problema não supervisionado (não há coluna-alvo), solução proposta e as 3 hipóteses herdadas da Parte 1 |
| **b) Pré-processamento** | Remoção de feature de classe (`Wine`, se existir), nulos e duplicados (nenhum), outliers pela regra do IQR (mantidos, como na Parte 1) e padronização com `StandardScaler` |
| **c) Ajuste do K-Means** | O algoritmo passo a passo em 2D (álcool × acidez), ajuste com as 13 variáveis (`k-means++`, `n_init=10`) e teste de robustez aos outliers |
| **d) Elbow e Silhueta** | Varredura de k = 2 a 10, gráfico de silhueta por grupo e modelo final em um `Pipeline` |
| **e) Análise dos grupos** | Perfil de cada grupo, teor alcoólico, acidez, cinzas, mapa de calor dos centróides e projeção PCA |
| **Validação** | Comparação com o cultivar real, que o modelo nunca viu (ARI), e o experimento da aula sobre padronização |

### Principais resultados

- **Sem padronizar, a prolina responde por 99,77% da distância.** Por isso as 13 variáveis foram padronizadas.
- **k = 3**: o cotovelo (queda de 23% na inércia até k = 3, depois ≤ 8%) e a silhueta (máxima de 0,285) concordam.
- **Os três grupos:**

| Grupo | Vinhos | Teor alcoólico | Ácido málico | Cinzas | Assinatura |
|---|---|---|---|---|---|
| **Encorpados** | 62 | o maior (13,68%) | baixo (2,00 g/L) | as maiores (2,47) | muita prolina e flavonoides |
| **Ácidos** | 51 | médio (13,13%) | **o maior** (3,31 g/L) | médias (2,42) | cor intensa, poucos flavonoides |
| **Leves** | 65 | o menor (12,25%) | o menor (1,90 g/L) | as menores (2,23) | cor clara, pouca prolina |

- **Ligação com a Parte 1:** a bimodalidade do teor alcoólico era a mistura de grupos (H1 confirmada). Existe um
  grupo mais ácido, com 68% dos vinhos acima de 3 g/L (H2 confirmada em parte). A acidez **não** é o que mais
  separa os grupos (H3 não confirmada): o CV dela é alto também dentro de cada grupo, e quem mais separa são os
  flavonoides, a prolina, os fenóis, a cor e o próprio teor alcoólico.
- **Validação:** cada grupo corresponde a um cultivar (ARI = 0,897). Só 6 dos 178 vinhos ficaram fora do grupo do
  seu cultivar.

### Como executar

1. Instale as bibliotecas: `pip install numpy pandas matplotlib scikit-learn jupyter`.
2. Abra `parte2_machine_learning/cp5_sinapse_kmeans.ipynb` e execute todas as células. O CSV é lido da pasta da
   Parte 1. Fora do repositório (ex.: Google Colab), o notebook baixa o arquivo direto deste GitHub.
