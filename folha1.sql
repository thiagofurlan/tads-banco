-- QUERY 1
-- Começando pela query mais interna, faço um SELECT com um filtro de intervalo usando o operador BETWEEN na cláusula WHERE na tabela venda para obter todas as vendas de Fevereiro/2000 e salvo na tabela temporária tmp0.
SELECT * FROM venda WHERE venda.dia BETWEEN '2000-02-01' AND '2000-02-29';



-- QUERY 2
-- Com o resultado da query 1, é feito um JOIN com outro SELECT na tabela vendedor, o resultado deste JOIN é o total de cada venda de cada vendedor, junto com a informacao de cada vendedor, a comissão e o salário bruto. Através da função de agregação SUM() agrupados pelo CPF do vendedor, temos o total de vendas por vendedor. Esse resultado é salvo na tabela temporária tmp1.
SELECT vendedor.nome, vendedor.cpf as cpf, vendedor.dependentes as dependentes, vendedor.salario as salario,
SUM((item.quantidade*produto.preco)*(produto.comissao/100.0)) as comissao,
(vendedor.salario + SUM((item.quantidade*produto.preco)*(produto.comissao/100.0))) as bruto
FROM vendedor
JOIN (SELECT * FROM venda WHERE venda.dia BETWEEN '2000-02-01' AND '2000-02-29') as tmp0 ON tmp0.vendedor = vendedor.cpf
JOIN item ON item.venda = tmp0.codigo
JOIN produto ON produto.codigo = item.produto
GROUP BY vendedor.cpf;



-- QUERY 3
-- Agora que temos o salario bruto, calculado na query 2, podemos calcular o INSS. Para isso usamos a declaração CASE, para decidir em qual faixa de salário bruto o contribuinte se encaixa, e então realizar a multiplicação pela porcentagem da faixa.
SELECT *,
	CASE
		WHEN bruto <= 1693.72 THEN bruto * 0.08
		WHEN bruto >= 1693.73 AND bruto <= 2822.90 THEN bruto * 0.09
		WHEN bruto >= 2822.91 AND bruto <= 5645.80 THEN bruto * 0.11
		ELSE 5645.80 * 0.11
	END inss
FROM
(SELECT vendedor.nome, vendedor.cpf as cpf, vendedor.dependentes as dependentes, vendedor.salario as salario,
	SUM((item.quantidade*produto.preco)*(produto.comissao/100.0)) as comissao,
	(vendedor.salario + SUM((item.quantidade*produto.preco)*(produto.comissao/100.0))) as bruto
	FROM vendedor
	JOIN (SELECT * FROM venda WHERE venda.dia BETWEEN '2000-02-01' AND '2000-02-29') as tmp0 ON tmp0.vendedor = vendedor.cpf
	JOIN item ON item.venda = tmp0.codigo
	JOIN produto ON produto.codigo = item.produto
	GROUP BY vendedor.cpf) as tmp1;




-- QUERY 4
-- Nesta etapa é obtido o valor salário para base de cálculo, passando toda a query 3 como subquery no FROM da query 4, o resultado é definido por um cálculo padrão e salvo com o ALIAS base.
SELECT *, (bruto - inss - (dependentes * 189.59)) as base FROM
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
	GROUP BY vendedor.cpf) as tmp1) as tmp2



-- QUERY 5
-- Aqui novamente usamos a declaração CASE para realizar o cálculo do IRRF com base nas faixas de salário base. Usamos toda a query 4 como fonte de dados no FROM.
SELECT *,
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
	GROUP BY vendedor.cpf) as tmp1) as tmp2) as tmp3



-- QUERY 6
-- No último passo desta solução, é calculado o salário líquido do funcionário e escolhido quais colunas aparecerão no resultado final. Novamente toda a query 5 é passada como fonte de dados no FROM e ordenado pela primeira coluna, que é o CPF do funcionário.
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


-- Custo desta solução foi: 282.17
-- A query 6 pode ser usada para averiguação dos resultados