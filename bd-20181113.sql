create table vendedor (
	cpf char(11) not null,
	nome varchar(100) not null,
	salario real not null check (salario > 0),
	primary key (cpf)
);

create table cliente (
	cpf char(11) not null,
	nome varchar(100) not null,
	nascimento date not null check (nascimento <= now()),
	primary key (cpf)
);

create table produto (
	codigo integer not null,
	descricao varchar(100) not null,
	preco real not null check (preco > 0),
	comissao real not null check ((comissao >= 0) and (comissao <= 50)),
	primary key (codigo)
);

create table venda (
	codigo serial not null,
	vendedor char(11) not null references vendedor(cpf),
	cliente char(11) not null references cliente(cpf),
	dia date not null default now() check (dia <= now()),
	desconto real not null check ((desconto >= 0) and (desconto <= 20)),
	primary key (codigo)
);

create table item (
	venda integer not null references venda(codigo),
	produto integer not null references produto(codigo),
	quantidade integer not null check (quantidade > 0) default 1,
	preco real not null check (preco > 0),
	primary key (venda, produto)
);

-- 1) Cadastrar a venda de 2 Desodorante feminino roll-on, 1 Protetor solar FPS 30 para a cliente Maria Almeida Pinto pelo vendedor Marcela Costa Terra com 0% de desconto hoje.
INSERT INTO venda (codigo, vendedor, cliente, dia, desconto) 
	VALUES (1, '23179779186', '57517786082', NOW()::date, 0);
INSERT INTO item (venda, produto, quantidade, preco) VALUES (1, 25, 2, 3.9);
INSERT INTO item (venda, produto, quantidade, preco) VALUES (1, 46, 1, 19.6);


-- 2) Adicionar 1 Shampoo para cabelos oleosos na venda de ontem do vendedor Bianca Lopes Nunes para a cliente Paula Correia Martins.
INSERT INTO venda (codigo, vendedor, cliente, dia, desconto)
	VALUES (2, '98045757757', '06504283432', (NOW() - interval '1 day')::date, 0);
INSERT INTO item (venda, produto, quantidade, preco) VALUES (2, 60, 1, 5);


-- 3) Remover 1 Esmalte para as unhas vermelho da venda do vendedor Marcela Costa Terra em 03/01/2000 para a cliente Tais Gomes Prado.
-- INSERT INTO venda (codigo, vendedor, cliente, dia, desconto) VALUES (4, '23179779186', '20122770425', NOW()::date, 0);
-- INSERT INTO item (venda, produto, quantidade, preco) VALUES (4, 35, 3, 2.1);
UPDATE item SET quantidade = quantidade-1 WHERE venda = 4;


-- 4) Aumentar o preço de todos os cremes faciais noturnos em 7.5%.
UPDATE produto SET preco = preco + (preco * 0.075) WHERE descricao ILIKE '%creme facial noturno%';


-- 5) Reassociar a venda do vendedor Maria Nunes Martins em 04/02/2000 para a cliente Cristiane Nunes Quaresma contendo os produtos Creme facial noturno 40 a 50 anos, Creme para os pes e Sabonete em barra feminino para o vendedor Gabriele Mendes Jardim.
-- INSERT INTO venda (codigo, vendedor, cliente, dia, desconto) VALUES (3, '86635044872', '34425891878', '2000-02-04', 0);
-- INSERT INTO item (venda, produto, quantidade, preco) values (3, 18, 1, 19.6);
-- INSERT INTO item (venda, produto, quantidade, preco) values (3, 23, 1, 15.4);
-- INSERT INTO item (venda, produto, quantidade, preco) values (3, 50, 1, 2.8);
UPDATE venda SET vendedor = '02166705218' WHERE vendedor = '86635044872' AND dia = '2000-02-04' AND codigo = 3; 


-- 6) Reajustar em 3% o salário fixo de todos os vendedores que vendenderam mais de $1000 em produtos em cada um dos últimos 3 meses.


-- 7) Na venda da questão 1, atualizar o desconto para que seja proporcional a quantidade de compras do cliente nos últimos 4 meses: 0 a 2 compras = 0%, 3 a 5 compras = 5%, 6 a 10 compras = 10%, mais de 10 compras = 15%.

update venda set desconto = (select
	case
		when compras >= 0 and compras <= 2 then 0
		when compras >= 3 and compras <= 5 then 5
		when compras >= 6 and compras <= 10 then 10
		when compras > 10 then 15
	end desconto
	from
	(select count(*) as compras from (select *, vendedor as cpf from venda
		join item on venda.codigo = item.venda
		join produto on item.produto = produto.codigo
		where venda.cliente = '06504283432' and venda.dia between (now() - interval '4 months') and now()) as tmp1 group by tmp1.cliente) as tmp2) where codigo = 1;



-- 8) Excluir a compra do cliente Gabriele Menezes Jardim em 02/02/2000 com o vendedor Maria Nunes Martins contendo os produtos Creme facial diurno para pele com acne e Esmalte para as unhas incolor.
-- INSERT INTO venda (codigo, vendedor, cliente, dia, desconto) VALUES (5, '86635044872', '03723616180', '2000-02-02', 0);
-- INSERT INTO item (venda, produto, quantidade, preco) values (5, 15, 1, 25.6);
-- INSERT INTO item (venda, produto, quantidade, preco) values (5, 31, 1, 1.5);
BEGIN;
	DELETE FROM item WHERE venda = 5;
	DELETE FROM venda WHERE codigo = 5;
COMMIT;


-- 9) Explique porque não é possível excluir um vendedor demitido.
-- É altamente NÃO recomendado excluir registros de um banco de dados, para isso usa-se uma marcação para esse vendedor, como por exemplo: desligado = 1. Em uma modelagem bem feita usando relacionamentos onde a chave primária desse vendedor está vinculado como chave estrageira em uma venda, o próprio banco se encarrega de fazer essa proteção, exibindo um erro e não efetuando a exclusão. Mas se o responsável pela modelagem do banco não relacionou vendedor com nenhuma outra tabela pk -> fk (modelagem mal feita) então será possível a exclusão.


-- 10) Explique porque é necessário ter um campo preço na tabela produto e outro na tabela item da venda em uma modelagem bem feita.
-- Por que o preço do produto pode variar durante sua existência na loja, e o preço da tabela ítem é o preço do produto no momento da venda. Se não tivesse o preço na tabela ítem, isso afetaria toda a contabilidade da empresa, pois quando a administração fizer uma atualização no preço do produto, o preço refletiria nas vendas já concretizadas.