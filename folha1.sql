SELECT cpf, dependentes, salario, comissao, bruto, inss, irrf, (bruto - inss - irrf) as liquido FROM
(SELECT *,
	CASE
		WHEN base <= 1903.98 THEN 0
		WHEN base >= 1903.99 AND base <= 2826.65 THEN (base*0.075 - 142.80)
		WHEN base >= 2826.66 AND base <= 3751.05 THEN (base*0.15 - 354.80)
		WHEN base >= 3751.06 AND base <= 4664.68 THEN (base*0.225 - 636.13)
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
(SELECT 
	vendedor.nome,
	vendedor.cpf as cpf,
	vendedor.dependentes as dependentes,
	vendedor.salario as salario,
	SUM((item.quantidade*produto.preco)*(produto.comissao/100.0)) as comissao,
	(vendedor.salario + SUM((item.quantidade*produto.preco)*(produto.comissao/100.0))) as bruto									 
	FROM vendedor
	JOIN (SELECT * FROM venda WHERE venda.dia BETWEEN '2000-02-01' AND '2000-02-29') as tmp0 ON tmp0.vendedor = vendedor.cpf
	JOIN item ON item.venda = tmp0.codigo
	JOIN produto ON produto.codigo = item.produto
	GROUP BY vendedor.cpf) as tmp1) as tmp2) as tmp3) as tmp4 ORDER BY 1;


-- Começando pela query mais interna, obtenho todas as vendas de Fevereiro/2000 e salvo na tabela temporária tmp0, uso o resultado desta query para fazer um JOIN com a consulta que irá trazer os dados do vendedor, junto com a comissão e o salário bruto através da função de agregação SUM() agrupados pelo CPF do vendedor e salvo o resultado na tabela temporária tmp1.

-- Agora que já temos as informações do vendedor, o valor das vendas de cada vendedor, podemos prosseguir com os cálculos. Através da expressão CASE é calculado o valor de contribuição para o INSS com base nas faixas de salário bruto, o resultado é salvo na tabela temporária tmp2. Com os resultados que estão em tmp2, agora é possível calcular o salário base que será salvo em tmp3.

-- O penúltimo passo é calcular o valor do IRRF que é em cima do salário base, q
