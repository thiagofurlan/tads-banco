create table venda (
	id serial not null,
	vendedor char(11) not null,
	cliente char(11),
	dia date not null,
	desconto float not null,
	primary key (id)
);

create table item (
	venda ? not null references venda(id),
	produto 
);

insert into venda (vendedor, cliente, dia, desconto) 
	values ('12345678901', null, '2018-11-06', 0);


select codprod, ValorTotal from (select codprod, estoque_atual*valorvenda as ValorTotal from tblProduto group by codprod, estoque_atual*valorvenda ) order by ValorTotal desc

