-- QUERY 1
-- Nesta query iremos fazer JOIN entre venda, item e produto usando as respectivas chaves estrangeiras para o relacionamento, com o resultado desses JOIN é usado como fonte de dados do SELECT que irá retornar o cpf e a comissão de cada vendedor no mês 2 com a função date_parte na cláusula WHERE, agrupados pelo CPF e salvo em tmp1.
SELECT venda.vendedor as vendedor, SUM((item.quantidade * produto.preco) * (produto.comissao / 100.0)) as comissao
FROM venda
JOIN item ON venda.codigo = item.venda
JOIN produto ON item.produto = produto.codigo
WHERE date_part('month', venda.dia) = 2
GROUP BY venda.vendedor


-- QUERY 2
-- Aqui nós obtemos todos os dados do vendedor e realizamos um JOIN com os resultados da query 1, usando o cpf do vendedor para fazer o relacionamento, salvamos na tabela temporária tmp2.
SELECT * FROM vendedor JOIN 
(SELECT venda.vendedor as vendedor, SUM((item.quantidade * produto.preco) * (produto.comissao / 100.0)) as comissao
FROM venda
JOIN item ON venda.codigo = item.venda
JOIN produto ON item.produto = produto.codigo
WHERE date_part('month', venda.dia) = 2
GROUP BY venda.vendedor) AS tmp1 ON vendedor.cpf = tmp1.vendedor

-- QUERY 3
-- Nesta consulta é calculado o valor do salário bruto, usando os resultados da query como fonte dos dados.
SELECT *, (salario + comissao) AS bruto FROM
(SELECT * FROM vendedor JOIN 
(SELECT venda.vendedor as vendedor, SUM((item.quantidade * produto.preco) * (produto.comissao / 100.0)) as comissao
FROM venda
JOIN item ON venda.codigo = item.venda
JOIN produto ON item.produto = produto.codigo
WHERE date_part('month', venda.dia) = 2
GROUP BY venda.vendedor) AS tmp1 ON vendedor.cpf = tmp1.vendedor

-- QUERY 4
-- Agora que temos o salario bruto, calculado na query 3, podemos calcular o INSS. Para isso usamos a declaração CASE, para decidir em qual faixa de salário bruto o contribuinte se encaixa, e então realizar a multiplicação pela porcentagem da faixa.
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
GROUP BY venda.vendedor) AS tmp1 ON vendedor.cpf = tmp1.vendedor) AS tmp2) AS tmp3)

-- QUERY 5
-- Nesta etapa é obtido o valor salário para base de cálculo, passando toda a query 4 como subquery no FROM da query 5, o resultado é definido por um cálculo padrão e salvo com o ALIAS base.
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
GROUP BY venda.vendedor) AS tmp1 ON vendedor.cpf = tmp1.vendedor) AS tmp2) AS tmp3) AS tmp4)


-- QUERY 6
-- Aqui novamente usamos a declaração CASE para realizar o cálculo do IRRF com base nas faixas de salário base. Usamos toda a query 5 como fonte de dados no FROM.
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
GROUP BY venda.vendedor) AS tmp1 ON vendedor.cpf = tmp1.vendedor) AS tmp2) AS tmp3) AS tmp4) AS tmp5)

-- QUERY 7
-- No último passo desta solução, é calculado o salário líquido do funcionário e escolhido quais colunas aparecerão no resultado final. Novamente toda a query 5 é passada como fonte de dados no FROM e ordenado pela primeira coluna, que é o CPF do funcionário.
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

-- Custo dessa solução foi: 26.03
-- A query 7 pode ser usada para averiguação dos resultados