select produto.codigo, sum(quantidade * preco) as subtotal, sum() from item join produto on item.produto = produto.codigo group by produto.codigo order by subtotal desc;
