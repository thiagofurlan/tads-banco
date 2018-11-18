select vendedor.nome, count(*) as quantidade from 
	venda join vendedor on venda.vendedor = vendedor.cpf
	where venda.dia between '2000-01-01' and '2000-01-31'
	group by vendedor.cpf
	order by vendedor.nome asc;



select vendedor.nome from vendedor JOIN (select vendedor.cpf, count(*) as quantidade from 
	venda join vendedor on venda.vendedor = vendedor.cpf
	where venda.dia between '2000-01-01' and '2000-01-31'
	group by vendedor.cpf
	order by vendedor.nome asc) as tmp1 on vendedor.cpf = tmp1.cpf;
