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




