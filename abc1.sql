-- QUERY 1
-- Nessa query é obtido o código do produto e seu subtotal por meio da função de agregação SUM(), utilizando um JOIN das tabelas item e produto usando o código do produto para fazer o relacionamento.
select produto.codigo, sum(quantidade * preco) as subtotal
    from 
        item join produto on item.produto = produto.codigo 
    group by
        produto.codigo order by subtotal desc

-- QUERY 2
-- Nessa query utiliza-se como base a query 1 para obter o valor acumulado através da função OVER, que organiza os resultados da subquery antes de aplicar a função de agregação SUM().
select *, sum(subtotal) over (order by subtotal desc) as acumulado
            from
            (select produto.codigo, 
                sum(quantidade * preco) as subtotal
                from item join produto 
                on item.produto = produto.codigo 
                group by produto.codigo 
                order by subtotal desc) as tmp1
            group by codigo, subtotal
            order by subtotal desc

-- QUERY 3
-- Nesta fase já possuímos o código do produto, o subtotal e o acumulado, com isso calculamos o acumulado percentual através da divisão do valor acumulado de cada linha pelo maior valor acumulado obtido na query 2, dado pela reutilização da query como subquery ordenada de forma decrescente e limitada em 1.
select *, (acumulado*100/
            (select acumulado from (select *, sum(subtotal) over (order by subtotal desc) as acumulado
                from
                (select produto.codigo, 
                    sum(quantidade * preco) as subtotal
                    from item join produto 
                    on item.produto = produto.codigo 
                    group by produto.codigo 
                    order by subtotal desc) as tmp1
                group by codigo, subtotal
                order by subtotal desc) 
            as tmp2 order by acumulado desc limit 1)) as acumuladoPercentual
        from
        (select *, sum(subtotal) over (order by subtotal desc) as acumulado
            from
            (select produto.codigo, 
                sum(quantidade * preco) as subtotal
                from item join produto 
                on item.produto = produto.codigo 
                group by produto.codigo 
                order by subtotal desc) as tmp1
            group by codigo, subtotal
            order by subtotal desc) as tmp2

-- QUERY 4
-- Agora que temos todas as informações necessárias para a classificação, basta darmos rótulos as faixas de valores, então utilizamos a declaração CASE com base no acumulado percentual calculado na query 3.
select *, 
case
    when acumuladoPercentual >= 0 and acumuladoPercentual <=65 then 'A'
    when acumuladoPercentual > 65 and acumuladoPercentual <=90 then 'B'
    when acumuladoPercentual > 90 and acumuladoPercentual <=100 then 'C'
end categoria
from
    (select *, (acumulado*100/
            (select acumulado from (select *, sum(subtotal) over (order by subtotal desc) as acumulado
                from
                (select produto.codigo, 
                    sum(quantidade * preco) as subtotal
                    from item join produto 
                    on item.produto = produto.codigo 
                    group by produto.codigo 
                    order by subtotal desc) as tmp1
                group by codigo, subtotal
                order by subtotal desc) 
            as tmp2 order by acumulado desc limit 1)) as acumuladoPercentual
        from
        (select *, sum(subtotal) over (order by subtotal desc) as acumulado
            from
            (select produto.codigo, 
                sum(quantidade * preco) as subtotal
                from item join produto 
                on item.produto = produto.codigo 
                group by produto.codigo 
                order by subtotal desc) as tmp1
            group by codigo, subtotal
            order by subtotal desc) as tmp2) as tmp3;


-- Custo dessa solução foi: 378.55
-- A query 4 pode ser usada para averiguação dos resultados