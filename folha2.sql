SELECT cpf, dependentes, salario, comissao, bruto, inss, irrf, (bruto - inss - irrf) as liquido FROM
(SELECT *,
	CASE
		WHEN base <= 1903.98 THEN 0
		WHEN base >= 1903.99 AND base <= 2826.65 THEN (base * 0.075 - 142.80)
		WHEN base >= 2826.66 AND base <= 3751.05 THEN (base * 0.15 - 354.80)
		WHEN base >= 3751.06 AND base <= 4664.68 THEN (base * 0.225 - 636.13)
		WHEN base > 4664.68 THEN (base * 0.275 - 869.36)
	END irrf
FROM
(SELECT *, (bruto - inss - (dependentes * 189.59)) as base FROM
(SELECT *,
	CASE
 		WHEN bruto <= 1693.72 THEN bruto * 0.08
 		WHEN bruto >= 1693.73 AND bruto <= 2822.90 THEN bruto * 0.09
 		WHEN bruto >= 2822.91 AND bruto <= 5645.80 THEN bruto * 0.11
 		ELSE 5645.80 * 0.11
 	END inss
FROM
(SELECT *, (salario + comissao) AS bruto FROM
(SELECT * FROM vendedor JOIN 
(SELECT venda.vendedor as vendedor, SUM((item.quantidade * produto.preco) * (produto.comissao / 100.0)) as comissao
FROM venda
JOIN item ON venda.codigo = item.venda
JOIN produto ON item.produto = produto.codigo
WHERE date_part('month', venda.dia) = 2
GROUP BY venda.vendedor) AS tmp1 ON vendedor.cpf = tmp1.vendedor) AS tmp2) AS tmp3) AS tmp4) AS tmp5) AS tmp6
ORDER BY 1;