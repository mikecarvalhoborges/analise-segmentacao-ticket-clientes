---
Arquivo separado com as queries:
-- Projeto: Segmentação de clientes por ticket médio

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
