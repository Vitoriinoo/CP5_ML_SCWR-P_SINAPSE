# =============================================================================
# Análise Exploratória do Dataset WINES — Teor Alcoólico e Ácido Málico
# Checkpoint 5 — Statistical Computing with R & Python — FIAP
# =============================================================================
# Integrantes (grupo sInApse):
#   Silvio Dela Libera Neto   | 572632
#   Thainá Almeida Santos     | 569110
#   Vitor Barbosa Vitorino    | 570475
# =============================================================================
# Contexto: 178 vinhos de 3 cultivares (tipos de uva) da mesma região da
# Itália. Na Parte 2 (K-means) os grupos serão comparados por teor alcoólico
# e acidez. Por isso analisamos aqui essas duas variáveis quantitativas
# contínuas:
#   * Alcohol    -> teor alcoólico (% vol.)
#   * Malic_Acid -> ácido málico (g/L), responsável pela acidez do vinho
# =============================================================================


# ── 1. BIBLIOTECAS E DADOS ────────────────────────────────────────────────────

library(DescTools)   # função Mode()

# O CSV deve estar no diretório de trabalho do R
# (RStudio: Session > Set Working Directory > To Source File Location)
vinhos <- read.csv("wine-clustering.csv")

# Resumo de todas as variáveis. Se houvesse dados faltantes, apareceria uma
# linha "NA's". Não aparece, então as 178 observações são usadas.
summary(vinhos)

alcool <- vinhos$Alcohol
acido  <- vinhos$Malic_Acid


# ── 2. FUNÇÕES AUXILIARES ─────────────────────────────────────────────────────
# As duas variáveis passam pelos mesmos procedimentos. As funções evitam
# repetir código.

# Tabela de distribuição de frequências para variável contínua
tabela_frequencias <- function(x, limites) {
  fi  <- table(cut(x, breaks = limites, right = FALSE))
  fia <- cumsum(fi)
  fr  <- round(100*prop.table(fi), digits = 2)
  fra <- round(cumsum(100*prop.table(fi)), digits = 2)

  # Linha de Total
  nfi  <- c(fi, sum(fi))
  nfia <- c(fia, "-")
  nfr  <- c(fr, sum(fr))
  nfra <- c(fra, "-")
  names(nfi)[length(nfi)]   <- "Total"
  names(nfia)[length(nfia)] <- "Total"
  names(nfr)[length(nfr)]   <- "Total"
  names(nfra)[length(nfra)] <- "Total"

  return(data.frame(Frequencia_Absoluta = nfi,
                    Frequencia_Absoluta_Acumulada = nfia,
                    Frequencia_Relativa = nfr,
                    Frequencia_Relativa_Acumulada = nfra))
}

# Coeficiente de Variação (%) e sua classificação
CV <- function(x) {
  return((sd(x)/mean(x))*100)
}
classificar_cv <- function(cv) {
  if (cv < 10) {
    return("Baixo")
  } else if (cv < 20) {
    return("Médio")
  } else if (cv < 30) {
    return("Alto")
  } else {
    return("Muito Alto")
  }
}

# Classificação do evento quanto ao resultado probabilístico
classificar_prob <- function(p) {
  if (p == 0) {
    return("evento impossível")
  } else if (p < 0.5) {
    return("evento pouco provável")
  } else if (p == 0.5) {
    return("evento provável")
  } else if (p < 1) {
    return("evento muito provável")
  } else {
    return("evento certo")
  }
}

# Medidas descritivas: tendência central, dispersão e separatrizes
medidas <- function(x) {
  return(c(mean(x), median(x),
           min(x), max(x), diff(range(x)), var(x), sd(x), CV(x),
           quantile(x, probs = c(0.25, 0.50, 0.75))))
}


# =============================================================================
# a) VISUALIZAÇÃO — TABELA DE FREQUÊNCIAS E GRÁFICO
# =============================================================================
# Construção das classes:
#   Alcohol:    R = 14,83 - 11,03 = 3,80 ; 8 classes -> Ai = 3,80/8 = 0,475 ≈ 0,5
#   Malic_Acid: R =  5,80 -  0,74 = 5,06 ; 6 classes -> Ai = 5,06/6 = 0,84  ≈ 1

tabela_alcool <- tabela_frequencias(alcool, seq(11, 15, by = 0.5))
tabela_acido  <- tabela_frequencias(acido,  seq(0.5, 6.5, by = 1))
tabela_alcool
tabela_acido

hist(alcool, breaks = seq(11, 15, by = 0.5), right = FALSE,
     col = "steelblue", border = "white", main = "Teor Alcoólico dos Vinhos",
     xlab = "Teor alcoólico (% vol.)", ylab = "Frequência")

hist(acido, breaks = seq(0.5, 6.5, by = 1), right = FALSE,
     col = "darkorange", border = "white", main = "Ácido Málico dos Vinhos",
     xlab = "Ácido málico (g/L)", ylab = "Frequência")

# Interpretação — Teor alcoólico:
# - A distribuição é aproximadamente simétrica: as classes extremas têm
#   poucos vinhos (4 abaixo de 11,5% e 2 acima de 14,5%), e o volume se
#   concentra entre 12% e 14% (137 vinhos, 76,97%).
# - A classe modal é [12 ; 12,5) com 21,35%, mas as classes [13 ; 13,5) e
#   [13,5 ; 14) vêm logo atrás (19,66% cada). São dois "picos", um sinal de
#   que os três cultivares têm teores alcoólicos típicos diferentes.
# - Pela fra, 48,31% dos vinhos têm menos de 13% de álcool: metade de cada lado.

# Interpretação — Ácido málico:
# - A distribuição é assimétrica à direita: a classe [1,5 ; 2,5) concentra
#   47,19% dos vinhos, e depois as frequências caem numa cauda longa até
#   5,80 g/L.
# - 65,73% dos vinhos têm menos de 2,5 g/L (acidez baixa), mas 26,40% passam
#   de 3 g/L. Esse subgrupo mais ácido é candidato a formar um cluster
#   próprio na Parte 2.


# =============================================================================
# b) ANÁLISE DESCRITIVA — TENDÊNCIA CENTRAL, DISPERSÃO E SEPARATRIZES
# =============================================================================

descritiva <- data.frame(
  Medida = c("Média", "Mediana", "Mínimo", "Máximo", "Amplitude",
             "Variância", "Desvio Padrão", "Coef. de Variação (%)",
             "Q1 (25%)", "Q2 (50%)", "Q3 (75%)"),
  Alcohol    = round(medidas(alcool), 3),
  Malic_Acid = round(medidas(acido), 3)
)
descritiva

# Moda (DescTools)
Mode(alcool)   # 12,37 e 13,05 -> bimodal
Mode(acido)    # 1,73 -> unimodal

# Classificação da variabilidade pelo CV
classificar_cv(CV(alcool))   # "Baixo"
classificar_cv(CV(acido))    # "Muito Alto"

# Outliers: valores fora de [Q1 - 1,5.(Q3 - Q1) ; Q3 + 1,5.(Q3 - Q1)]
q_alcool <- quantile(alcool, probs = c(0.25, 0.75))
q_acido  <- quantile(acido,  probs = c(0.25, 0.75))
li_alcool <- q_alcool[1] - 1.5*(q_alcool[2] - q_alcool[1])   # 10,39
ls_alcool <- q_alcool[2] + 1.5*(q_alcool[2] - q_alcool[1])   # 15,65
li_acido  <- q_acido[1]  - 1.5*(q_acido[2]  - q_acido[1])    # -0,62
ls_acido  <- q_acido[2]  + 1.5*(q_acido[2]  - q_acido[1])    #  5,30
alcool[alcool < li_alcool | alcool > ls_alcool]   # nenhum outlier
acido[acido < li_acido | acido > ls_acido]        # 5,80  5,51  5,65

boxplot(alcool, main = "Boxplot do Teor Alcoólico", ylab = "% vol.",
        col = "steelblue")
boxplot(acido, main = "Boxplot do Ácido Málico", ylab = "g/L",
        col = "darkorange")

# Interpretação — Teor alcoólico:
# - Tendência central: média 13,00, mediana 13,05 e modas 12,37 e 13,05
#   (bimodal). As três medidas são muito próximas, então o conjunto é
#   homogêneo e simétrico. O vinho típico tem cerca de 13% de álcool.
# - Dispersão: desvio padrão de 0,81 ponto e CV de 6,24%, variabilidade
#   BAIXA (CV < 10%). Todos os vinhos têm teor alcoólico parecido.
# - Quartis: Q1 = 12,36; Q2 = 13,05; Q3 = 13,68. Os 50% centrais estão numa
#   faixa de só 1,32 ponto (Q3 - Q1), e Q2 - Q1 (0,69) ≈ Q3 - Q2 (0,63)
#   confirma a simetria. No boxplot a mediana fica no meio da caixa, os
#   bigodes são parecidos e não há outliers.

# Interpretação — Ácido málico:
# - Tendência central: Moda (1,73) < Mediana (1,87) < Média (2,34). As
#   medidas são afastadas, então o conjunto é heterogêneo e assimétrico à
#   direita. A média é "puxada" pelos vinhos muito ácidos, e a mediana
#   representa melhor o vinho típico.
# - Dispersão: CV de 47,82%, variabilidade MUITO ALTA (CV ≥ 30%). O vinho
#   mais ácido (5,80) tem quase 8 vezes o ácido do menos ácido (0,74).
# - Quartis: Q1 = 1,60; Q2 = 1,87; Q3 = 3,08. A metade de cima está quase 5
#   vezes mais espalhada que a de baixo (Q3 - Q2 = 1,22 contra Q2 - Q1 =
#   0,26). No boxplot a mediana fica encostada na parte de baixo da caixa, o
#   bigode superior é bem mais longo e aparecem 3 outliers (5,51; 5,65; 5,80).
#   Eles foram mantidos por serem medições plausíveis, não erros.
# - Conclusão: o álcool varia pouco entre os vinhos, e a acidez varia muito.
#   A acidez deve ser a variável que mais diferencia os grupos no K-means.


# =============================================================================
# c) ANÁLISE PROBABILÍSTICA
# =============================================================================

# ── c.1 Teor alcoólico: Distribuição Normal X ~ N(μ = 13,00 ; σ = 0,81) ───────
# Justificativa: dados simétricos, média ≈ mediana e sem outliers.
mu <- mean(alcool)
dp <- sd(alcool)

# Validação pela regra empírica 68 - 95 - 99,7% da Normal:
# % real de vinhos a até 1, 2 e 3 desvios padrão da média
round(100*mean(abs(alcool - mu) < 1*dp), 2)   # 64,04%  (Normal: 68,27%)
round(100*mean(abs(alcool - mu) < 2*dp), 2)   # 98,31%  (Normal: 95,45%)
round(100*mean(abs(alcool - mu) < 3*dp), 2)   # 100%    (Normal: 99,73%)
# Os percentuais reais são próximos dos teóricos, então a Normal é uma boa
# aproximação. Há um pouco menos de vinhos no centro e nenhum nos extremos,
# o que combina com a distribuição um pouco achatada vista no histograma.

# Cálculo 1: P(X ≥ 14) — vinho com teor alcoólico alto
p1 <- pnorm(14, mu, dp, lower.tail = FALSE)
cat("P(X >= 14) =", round(p1, 4), "->", classificar_prob(p1),
    "| vinhos esperados:", round(178*p1), "| reais:", sum(alcool >= 14), "\n")
# P(X ≥ 14) ≈ 0,1092 (10,92%), evento pouco provável. Dos 178 vinhos,
# esperamos cerca de 19 com 14% ou mais. Na amostra são 22, e o modelo está
# próximo da realidade. Vinhos "encorpados" são minoria.

# Cálculo 2: P(12 ≤ X ≤ 14) — faixa central de teor alcoólico
a <- pnorm(12, mu, dp, lower.tail = TRUE)
b <- pnorm(14, mu, dp, lower.tail = TRUE)
p2 <- b - a
cat("P(12 <= X <= 14) =", round(p2, 4), "->", classificar_prob(p2),
    "| vinhos esperados:", round(178*p2),
    "| reais:", sum(alcool >= 12 & alcool <= 14), "\n")
# P(12 ≤ X ≤ 14) ≈ 0,7820 (78,20%), evento muito provável. Esperamos cerca
# de 139 vinhos nessa faixa e observamos 137. Quase 4 em cada 5 vinhos têm
# entre 12% e 14% de álcool.

# Cálculo 3: teor mínimo para estar entre os 10% mais alcoólicos
qnorm(0.90, mu, dp, lower.tail = TRUE)
# ≈ 14,04%. O percentil 90 real é 14,10%, então o modelo acerta bem também
# na cauda.
quantile(alcool, probs = 0.90)


# ── c.2 Ácido málico: Distribuição Amostral da Média (TCL) ────────────────────
# A variável em si NÃO é Normal. Se usássemos Y ~ N(2,34 ; 1,12), o modelo
# daria chance de acidez NEGATIVA, o que é impossível:
pnorm(0, mean(acido), sd(acido), lower.tail = TRUE)   # ≈ 0,0182 (1,82%)
#
# Porém, pelo Teorema Central do Limite, a MÉDIA de amostras com n > 30
# segue uma Normal, qualquer que seja a forma da população:
#   Ȳ ~ N(μ ; σ/√n)
# Cenário: um distribuidor compra lotes de 30 vinhos sorteados ao acaso.
# Qual a acidez média esperada do lote?
n        <- 30
mu_ac    <- mean(acido)          # 2,34 g/L
erro_pad <- sd(acido)/sqrt(n)    # erro padrão = 1,12/√30 ≈ 0,20 g/L

# Cálculo 1: P(Ȳ > 2,6) — lote com acidez média alta
p3 <- pnorm(2.6, mu_ac, erro_pad, lower.tail = FALSE)
cat("P(média > 2,6) =", round(p3, 4), "->", classificar_prob(p3), "\n")
# P(Ȳ > 2,6) ≈ 0,0981 (9,81%), evento pouco provável. Embora 26% dos vinhos
# individuais passem de 3 g/L, ao juntar 30 vinhos os extremos se compensam
# e um lote muito ácido fica raro.

# Cálculo 2: P(2,0 ≤ Ȳ ≤ 2,6) — lote com acidez média dentro do padrão
a <- pnorm(2.0, mu_ac, erro_pad, lower.tail = TRUE)
b <- pnorm(2.6, mu_ac, erro_pad, lower.tail = TRUE)
p4 <- b - a
cat("P(2,0 <= média <= 2,6) =", round(p4, 4), "->", classificar_prob(p4), "\n")
# P(2,0 ≤ Ȳ ≤ 2,6) ≈ 0,8524 (85,24%), evento muito provável. A acidez de um
# vinho isolado é imprevisível (CV muito alto), mas a média de um lote é
# bastante estável.

# Verificação por simulação: sorteamos 10.000 lotes de 30 vinhos da base e
# guardamos a acidez média de cada lote
set.seed(123)
medias_lotes <- c()
for (i in 1:10000) {
  medias_lotes[i] <- mean(sample(acido, size = n, replace = T))
}
mean(medias_lotes > 2.6)                          # ≈ 0,1019
mean(medias_lotes >= 2 & medias_lotes <= 2.6)     # ≈ 0,8541

hist(medias_lotes, breaks = 40, col = "moccasin", border = "white",
     main = "Acidez média de 10.000 lotes de 30 vinhos",
     xlab = "Acidez média do lote (g/L)", ylab = "Frequência")
# Simulação: 0,1019 e 0,8541, praticamente iguais aos valores do TCL
# (0,0981 e 0,8524). O histograma das médias tem formato de sino e é
# simétrico, embora o histograma do ácido málico seja assimétrico. É o TCL
# acontecendo na prática.


# =============================================================================
# CONCLUSÃO
# =============================================================================
# - Teor alcoólico: simétrico, variabilidade baixa e bem modelado por uma
#   Normal N(13,00 ; 0,81). Cerca de 78% dos vinhos ficam entre 12% e 14%, e
#   só ~11% chegam a 14%.
# - Ácido málico: assimétrico, variabilidade muito alta e com outliers. Não é
#   Normal, mas a média de lotes de 30 vinhos é (TCL), o que permite prever a
#   acidez de lotes com segurança.
# - Para a Parte 2: a acidez diferencia muito mais os vinhos do que o álcool,
#   e o subgrupo acima de 3 g/L deve aparecer como um cluster próprio.
