# Análise de Segmentação de Clientes por Ticket Médio

## Objetivo

Identificar a distribuição de clientes com base no ticket médio e analisar a participação de cada grupo no faturamento total.

A análise permite entender o nível de concentração de receita e identificar oportunidades de crescimento em diferentes segmentos de clientes.

---

## Tecnologias utilizadas

- Google BigQuery (SQL)
- Window Functions (NTILE, SUM OVER)
- Google Sheets (visualização)
- GitHub (documentação do projeto)

---

## Metodologia

1. Cálculo do faturamento total por cliente
2. Cálculo do ticket médio por cliente
3. Segmentação automática dos clientes em três grupos utilizando `NTILE(3)`
4. Classificação em:
   - Alto Ticket
   - Médio Ticket
   - Baixo Ticket
5. Cálculo da participação de cada grupo no faturamento total

---

## Query principal

```sql
WITH base_cliente AS (
    SELECT 
        cliente,
        SUM(quantidade * preco_unit) AS faturamento_total,
        SUM(quantidade * preco_unit) / COUNT(DISTINCT pedido_id) AS ticket_medio
    FROM `prefab-fabric-462023-n0.estudos_sql.vendas`
    GROUP BY cliente
),

classificacao AS (
    SELECT
        *,
        NTILE(3) OVER (ORDER BY ticket_medio DESC) AS grupo
    FROM base_cliente
),

grupo_faturamento AS (
    SELECT
        CASE 
            WHEN grupo = 1 THEN 'Alto ticket'
            WHEN grupo = 2 THEN 'Médio ticket'
            ELSE 'Baixo ticket'
        END AS classificacao,
        SUM(faturamento_total) AS faturamento_grupo
    FROM classificacao
    GROUP BY classificacao
)

SELECT
    classificacao,
    faturamento_grupo,
    ROUND(
        100 * faturamento_grupo / SUM(faturamento_grupo) OVER (),
        2
    ) AS participacao_percentual
FROM grupo_faturamento
ORDER BY faturamento_grupo DESC;
