-- QUERY 1
-- Nessa query é obtido o código do produto e seu subtotal por meio da função de agregação SUM(), utilizando um JOIN das tabelas item e produto usando o código do produto para fazer o relacionamento.
(select codigo, sum(quantidade * preco) as subtotal
        from item join produto 
        on item.produto = produto.codigo
        group by produto.codigo 
        order by subtotal desc) as tmp1

-- QUERY 2
-- Nesta query é feito um JOIN entre a query 1 sob dois alias, de forma que o acumulado é calculado através da soma dos subtotais que obedecem a condição dada pelo ON
select tmp1.codigo, tmp1.subtotal, sum(tmp2.subtotal) as acumulado
    from
        (select codigo, sum(quantidade * preco) as subtotal
        from item join produto 
        on item.produto = produto.codigo
        group by produto.codigo 
        order by subtotal desc) as tmp1
    join 
        (select codigo, sum(quantidade * preco) as subtotal
        from item join produto 
        on item.produto = produto.codigo
        group by produto.codigo 
        order by subtotal desc) as tmp2
    on tmp2.subtotal >= tmp1.subtotal
    group by tmp1.codigo, tmp1.subtotal
    order by tmp1.subtotal desc) as tmp4

-- QUERY 3
-- Nesta fase já possuímos o código do produto, o subtotal e o acumulado, com isso calculamos o acumulado percentual através da divisão do valor acumulado de cada linha pelo maior valor acumulado obtido na query 2, dado pela reutilização da query como subquery que resulta no valor máximo da coluna subtotal.
(select *, (acumulado*100/
        (select max(acumulado) from
            (select tmp1.codigo, tmp1.subtotal, sum(tmp2.subtotal) as acumulado
            from
                (select codigo, sum(quantidade * preco) as subtotal
                from item join produto 
                on item.produto = produto.codigo
                group by produto.codigo 
                order by subtotal desc) as tmp1
            join 
                (select codigo, sum(quantidade * preco) as subtotal
                from item join produto 
                on item.produto = produto.codigo
                group by produto.codigo 
                order by subtotal desc) as tmp2
            on tmp2.subtotal >= tmp1.subtotal
            group by tmp1.codigo, tmp1.subtotal
            order by tmp1.subtotal desc) as tmp3)
    ) as acumuladoPercentual
    from
    (select tmp1.codigo, tmp1.subtotal, sum(tmp2.subtotal) as acumulado
    from
        (select codigo, sum(quantidade * preco) as subtotal
        from item join produto 
        on item.produto = produto.codigo
        group by produto.codigo 
        order by subtotal desc) as tmp1
    join 
        (select codigo, sum(quantidade * preco) as subtotal
        from item join produto 
        on item.produto = produto.codigo
        group by produto.codigo 
        order by subtotal desc) as tmp2
    on tmp2.subtotal >= tmp1.subtotal
    group by tmp1.codigo, tmp1.subtotal
    order by tmp1.subtotal desc) as tmp4) as tmp5

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
        (select max(acumulado) from
            (select tmp1.codigo, tmp1.subtotal, sum(tmp2.subtotal) as acumulado
            from
                (select codigo, sum(quantidade * preco) as subtotal
                from item join produto 
                on item.produto = produto.codigo
                group by produto.codigo 
                order by subtotal desc) as tmp1
            join 
                (select codigo, sum(quantidade * preco) as subtotal
                from item join produto 
                on item.produto = produto.codigo
                group by produto.codigo 
                order by subtotal desc) as tmp2
            on tmp2.subtotal >= tmp1.subtotal
            group by tmp1.codigo, tmp1.subtotal
            order by tmp1.subtotal desc) as tmp3)
    ) as acumuladoPercentual
    from
    (select tmp1.codigo, tmp1.subtotal, sum(tmp2.subtotal) as acumulado
    from
        (select codigo, sum(quantidade * preco) as subtotal
        from item join produto 
        on item.produto = produto.codigo
        group by produto.codigo 
        order by subtotal desc) as tmp1
    join 
        (select codigo, sum(quantidade * preco) as subtotal
        from item join produto 
        on item.produto = produto.codigo
        group by produto.codigo 
        order by subtotal desc) as tmp2
    on tmp2.subtotal >= tmp1.subtotal
    group by tmp1.codigo, tmp1.subtotal
    order by tmp1.subtotal desc) as tmp4) as tmp5;

-- Custo dessa solução foi: 1359.19
-- A query 4 pode ser usada para averiguação dos resultados