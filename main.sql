-- Numero de empresas com mais de X dividendos
WITH DividendCounts AS (
    SELECT ticker_name, COUNT(*) AS dividend_count
    FROM prices
    WHERE Dividends != 0
    GROUP BY ticker_name
)
SELECT X, COUNT(*) AS companies_above_X
FROM (
    SELECT DISTINCT dividend_count AS X FROM DividendCounts
) AS Levels
JOIN DividendCounts DC ON DC.dividend_count >= Levels.X
GROUP BY X
ORDER BY X;

-- Contagem com diferente tempos de cotação para verificar a frequencia da quantidade de cotação
WITH cotacoes AS (
    SELECT
        ticker_name,
        COUNT(*) AS cotacao_count
    FROM prices
    GROUP BY ticker_name
),
grouped_counts AS (
    SELECT
        FLOOR(cotacao_count / 100) * 100 AS Quantidade,
        COUNT(*) AS Contagem
    FROM cotacoes
    GROUP BY Quantidade
    ORDER BY Quantidade
)
SELECT
    gc.Quantidade,
    gc.Contagem,
    (SELECT c.ticker_name
     FROM cotacoes c
     WHERE FLOOR(c.cotacao_count / 100) * 100 = gc.Quantidade
     LIMIT 1) AS Exemplo_Ticker
FROM grouped_counts gc;

-- Contagem dividendos por empresas
SELECT ticker_name, COUNT(*) AS dividend_count
FROM prices
WHERE Dividends != 0
GROUP BY ticker_name;


-- Definindo Amostras
WITH contagem_dividendos AS (
    SELECT ticker_name, COUNT(*) AS dividend_count
    FROM prices
    WHERE Dividends != 0
    GROUP BY ticker_name
),
contagem_cotacoes AS (
    SELECT ticker_name, COUNT(*) AS total_cotacoes
    FROM prices
    GROUP BY ticker_name
),
valores_corte AS (
    SELECT 5 AS corte UNION ALL
    SELECT 10 UNION ALL
    SELECT 15 UNION ALL
    SELECT 20 UNION ALL
    SELECT 25 UNION ALL
    SELECT 30 UNION ALL
    SELECT 35 UNION ALL
    SELECT 40 UNION ALL
    SELECT 45 UNION ALL
    SELECT 50 UNION ALL
    SELECT 55 UNION ALL
    SELECT 60 UNION ALL
    SELECT 65 UNION ALL
    SELECT 70 UNION ALL
    SELECT 75 UNION ALL
    SELECT 80 UNION ALL
    SELECT 85 UNION ALL
    SELECT 90 UNION ALL
    SELECT 95 UNION ALL
    SELECT 100
),
amostra AS (
    SELECT
        v.corte,
        COUNT(DISTINCT cd.ticker_name) AS qtd_empresas, -- Contagem de empresas únicas
        SUM(cd.dividend_count) AS soma_dividendos,
        SUM(cc.total_cotacoes) AS soma_cotacoes,
        SUM(cd.dividend_count) * 1.0 / SUM(cc.total_cotacoes) AS perc_dividendos
    FROM valores_corte v
    JOIN contagem_dividendos cd ON cd.dividend_count >= v.corte
    JOIN contagem_cotacoes cc ON cc.ticker_name = cd.ticker_name
    GROUP BY v.corte
)
SELECT * FROM amostra
ORDER BY corte;

-- Removendo todso que tem um dia com volume igual a 0
-- BEGIN TRANSACTION;
--
-- CREATE TEMP TABLE temp_tickers AS
-- SELECT DISTINCT ticker_name
-- FROM prices
-- WHERE Volume = 0;
--
-- INSERT INTO tickers_cortados (ticker, motivo)
-- SELECT ticker_name, 'Havia um dia com volume igual a 0'
-- FROM temp_tickers;
--
-- DELETE FROM prices
-- WHERE ticker_name IN (SELECT ticker_name FROM temp_tickers);
--
-- COMMIT;

-- Verificar motivos da saida:
SELECT Motivo, COUNT(*)
FROM tickers_cortados
GROUP BY Motivo;

-- Verificar quantos tickers estão cortados e nos ativos simultaneamente, esperado, 0:
SELECT distinct ticker_name
from prices p
inner join tickers_cortados tc
    ON p.ticker_name = tc.Ticker;

-- Conta quais origem dos dados
SELECT distinct origem, count(*)
from tickers_brutos
group by origem;

-- Verifica quais estão listados ou no prices ou  no tickers_cortados Esperado: Todos :Check
WITH tickers_usados AS (
    SELECT DISTINCT ticker_name FROM prices
), tickers_descartados AS (
    SELECT DISTINCT Ticker FROM tickers_cortados
)
SELECT *
FROM tickers_brutos tb
WHERE
    tb.ticker_name IN (SELECT ticker_name FROM tickers_usados)
    OR tb.ticker_name IN (SELECT Ticker FROM tickers_descartados);

-- Remover todos que estão com menos de 40 dividendos
-- BEGIN TRANSACTION;
--
-- CREATE TEMP TABLE tickers_menos_40 AS
-- SELECT ticker_name
-- FROM prices
-- where Dividends != 0
-- group by ticker_name
-- HAVING count(*) < 40;
--
-- SELECT * FROM tickers_menos_40;
--
-- DELETE FROM prices
-- WHERE ticker_name IN (select ticker_name from tickers_menos_40);
--
-- INSERT INTO
--     tickers_cortados (Ticker, Motivo)
-- select ticker_name, 'Menos de 40 distribuições de dividendos' from tickers_menos_40;
--
-- commit;

-- Obter a diferença para cenarios com e sem dividendos
with cotacoes AS (
    SELECT ticker_name,
         Date,
         Open,
         Close,
         Dividends,
         LAG(Close, 1) OVER (PARTITION BY ticker_name ORDER BY Date) AS fechamento_ontem
    FROM prices
)
SELECT *, (c.Open / c.fechamento_ontem) - 1  as Diff
FROM cotacoes as c
where
    fechamento_ontem IS NOT NULL
    AND Dividends == 0;

-- Criação de view tickers_ativos
-- CREATE VIEW tickers_ativos AS
-- SELECT DISTINCT ticker_name
-- FROM prices;

-- Criação de view sector_key_ativos
-- CREATE VIEW sector_key_ativos AS
-- SELECT DISTINCT sector_key
-- FROM tickers t
-- inner join tickers_ativos ta
--     ON ta.ticker_name = t.ticker_name
-- WHERE sector_key != ""

SELECT DISTINCT ticker_name
from pre_test_dividends;

-- Cruzar dados com o Beta dividendo
SELECT
    bdb.*,
    t.beta as 'Beta CAPM',
    t.market_cap,
    t.dividend_rate,
    t.dividend_yield,
    t.payout_ratio,
    t.price_to_book,
    t.price_to_earnings,
    t.free_cashflow,
    avg(p.Volume) as 'Volume Medio',
    stdev(p.Volume) as 'Desvio Volume'
FROM tickers t
INNER JOIN beta_dividendo_bruto bdb
    ON bdb.ticker_name = t.ticker_name
INNER JOIN prices p on bdb.ticker_name = p.ticker_name
group by t.ticker_name;

-- Dividendo Yield
with cotacoes AS (
    SELECT ticker_name,
         Date,
         Open,
         Close,
         Dividends,
         LAG(Close, 1) OVER (PARTITION BY ticker_name ORDER BY Date) AS fechamento_ontem
    FROM prices
)
SELECT ticker_name, avg(Dividends / fechamento_ontem) AS dividend_yield
FROM cotacoes as c
where
    fechamento_ontem IS NOT NULL
    AND Dividends != 0
group by ticker_name;

-- Obtendo cotação, view:
-- create view cotacoes_ativos as
-- with cotacoes AS (
--     SELECT ticker_name,
--          Date,
--          Open,
--          Close,
--          Dividends,
--          LAG(Close, 1) OVER (PARTITION BY ticker_name ORDER BY Date) AS fechamento_ontem
--     FROM prices
-- )
-- SELECT *, (c.Open / c.fechamento_ontem) - 1  as Diff
-- FROM cotacoes as c
-- where
--     fechamento_ontem IS NOT NULL
--     AND Dividends == 0;

-- Contagem dividendo/dia
SELECT Date, count(*)
FROM prices
WHERE Dividends != 0
group by Date


-- beta_div_bruto
SELECT distinct tickers.full_exchange_name
from tickers;

with cotacoes AS (
    SELECT
         ticker_name,
         Date,
         Open,
         Close,
         Dividends,
         LAG(Close, 1) OVER (PARTITION BY ticker_name ORDER BY Date) AS fechamento_ontem
    FROM prices
)
SELECT c.*
FROM cotacoes as c
inner join tickers t
    ON c.ticker_name = t.ticker_name
where
    fechamento_ontem IS NOT NULL AND
    Dividends != 0 and
    t.full_exchange_name IN ('NYSE', 'NYSE AMERICAN');

-- Regressão final:
WITH dividendos_filtrados AS (
    SELECT
        ca.ticker_name,
        t.sector_key,
        t.full_exchange_name,
        ca.Date,
        ca.Dividends,
        ca.fechamento_ontem
    FROM cotacoes_ativos ca
    LEFT JOIN tickers t ON t.ticker_name = ca.ticker_name
    WHERE ca.Dividends != 0
),
dias_entre_dividendos AS (
    SELECT
        ticker_name,
        Date,
        Dividends,
        julianday(Date) - julianday(
            LAG(Date) OVER (PARTITION BY ticker_name ORDER BY Date)
        ) AS dias_entre
    FROM dividendos_filtrados
),
periodo_medio AS (
    SELECT
        ticker_name,
        AVG(dias_entre) AS avg_dias_entre_div
    FROM dias_entre_dividendos
    WHERE dias_entre IS NOT NULL
    GROUP BY ticker_name
),
crescimento_div AS (
    SELECT
        df.*,
        LAG(Dividends) OVER (PARTITION BY ticker_name ORDER BY Date) AS prev_div
    FROM dividendos_filtrados df
),
crescimento_agrupado AS (
    SELECT
        ticker_name,
        sector_key,
        full_exchange_name,
        AVG(Dividends / fechamento_ontem) AS proxy_div_yield,
        AVG(
            CASE
                WHEN prev_div IS NOT NULL AND prev_div > 0
                THEN (Dividends - prev_div) / prev_div
                ELSE NULL
            END
        ) AS avg_div_growth
    FROM crescimento_div
    GROUP BY ticker_name, sector_key, full_exchange_name
)
SELECT
    bdb.beta_dividendo,
    c.*,
    p.avg_dias_entre_div / 30.44 AS 'avg_tempo_entre_divs_meses'
FROM crescimento_agrupado c
LEFT JOIN periodo_medio p USING (ticker_name)
LEFT JOIN beta_dividendo_bruto bdb
    on bdb.ticker_name = c.ticker_name;

