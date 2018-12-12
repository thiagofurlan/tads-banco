-- 11230291
create table usuario (
    codigo serial not null primary key,
    nome varchar(100) not null,
    nascimento date not null,
    genero char(1) not null default 'M' check((genero = 'M') or (genero = 'F'))
);

create table jogo (
    codigo serial not null primary key,
    titulo varchar(100) not null,
    tipo char(1) not null default 'S' check((tipo = 'S') or (tipo = 'L') or (tipo = 'C')),
    console varchar(100) not null
);

create table locacao (
    jogo integer not null references jogo(codigo),
    usuario integer not null references usuario(codigo),
    retirada date not null default now(),
    devolucao date default null,
    primary key (jogo, retirada)
);

-- 1

select
    case
        when date_part('year', age(usuario.nascimento)) <= 19 then '19'
        when date_part('year', age(usuario.nascimento)) >= 20 and date_part('year', age(usuario.nascimento)) <= 29 then '20-29'
        when date_part('year', age(usuario.nascimento)) >= 30 and date_part('year', age(usuario.nascimento)) <= 39 then '30-39'
        when date_part('year', age(usuario.nascimento)) >= 40 then '40+'
    end faixa_etaria,
    jogo.titulo,
    usuario.genero
    from usuario
    join locacao on usuario.codigo = locacao.usuario
    join jogo on jogo.codigo = locacao.jogo
    group by faixa_etaria, jogo.titulo, usuario.genero;

-- 2 OK

select * from (select jogo.titulo from jogo
    join locacao on jogo.codigo = locacao.jogo
    join usuario on locacao.usuario = usuario.codigo
    where usuario.nascimento < (now()::date - '40 years'::interval) and locacao.retirada between '2018-09-01' and '2018-12-31') as tmp1 except (select jogo.titulo from jogo
    join locacao on jogo.codigo = locacao.jogo
    join usuario on locacao.usuario = usuario.codigo
    where usuario.nascimento >= (now()::date - '19 years'::interval) and locacao.retirada between '2018-09-01' and '2018-12-31');



--3 OK
select jogo.titulo from jogo
    join locacao on jogo.codigo = locacao.jogo
    join usuario on locacao.usuario = usuario.codigo where locacao.usuario = 1 group by jogo.titulo having count(*) > 1;


-- 4
select
    case
        when (jogo.tipo = 'S') then 7
        when (jogo.tipo = 'L') then 14
        when (jogo.tipo = 'C') then 21
    end prazo,
    locacao.jogo,
    usuario.codigo
    from jogo
    join locacao on jogo.codigo = locacao.jogo
    join usuario on locacao.usuario = usuario.codigo;



select usuario, count(*) from 
(select
    case
        when (jogo.tipo = 'S') then 7
        when (jogo.tipo = 'L') then 14
        when (jogo.tipo = 'C') then 21
    end prazo,
    usuario.codigo as usuario,
    jogo.codigo as jogo
    from jogo
    join locacao on jogo.codigo = locacao.jogo
    join usuario on locacao.usuario = usuario.codigo) as tmp
    group by tmp.usuario;e


-- 5


select sum(custo + (tmp1.retirada - (now()::date - '7 days'::interval)::date)*multa) from 
(select *,
    case
        when (jogo.tipo = 'S') then 40
        when (jogo.tipo = 'L') then 20
        when (jogo.tipo = 'C') then 10
    end custo,
    case
        when (jogo.tipo = 'S') then 10
        when (jogo.tipo = 'L') then 5
        when (jogo.tipo = 'C') then 2
    end multa
    from usuario
    join locacao on usuario.codigo = locacao.usuario
    join jogo on jogo.codigo = locacao.jogo
    where usuario.codigo = 1 and locacao.retirada > (now()::date - '7 days'::interval)::date) as tmp1;

insert into usuario (nome, nascimento, genero) values ('Fulano', '1991-03-30', 'M');
insert into usuario (nome, nascimento, genero) values ('Cicrano', '1995-06-15', 'M');
insert into usuario (nome, nascimento, genero) values ('Beotrana', '1992-09-03', 'F');
insert into usuario (nome, nascimento, genero) values ('coroa', '1950-10-10', 'M');
insert into usuario (nome, nascimento, genero) values ('junior', '2005-12-03', 'M');

insert into jogo (titulo, tipo, console) values ('jogo a', 'S', 'play 3');
insert into jogo (titulo, tipo, console) values ('jogo b', 'C', 'super nintendo');
insert into jogo (titulo, tipo, console) values ('jogo c', 'L', 'xbox');
insert into jogo (titulo, tipo, console) values ('jogo d', 'S', 'play 4');
insert into jogo (titulo, tipo, console) values ('jogo e', 'C', 'play 2');
insert into jogo (titulo, tipo, console) values ('jogo f', 'L', 'megadrive');
insert into jogo (titulo, tipo, console) values ('jogo g', 'C', 'atari');
insert into jogo (titulo, tipo, console) values ('jogo h', 'S', 'play 4');
insert into jogo (titulo, tipo, console) values ('jogo h', 'S', 'play 3');
insert into jogo (titulo, tipo, console) values ('jogo h', 'S', 'xbox');
insert into jogo (titulo, tipo, console) values ('jogo e', 'S', 'play 3');
insert into jogo (titulo, tipo, console) values ('jogo e', 'S', 'xbox');

insert into locacao (jogo, usuario, retirada) values (1, 1, '2018-12-10');
insert into locacao (jogo, usuario, retirada) values (4, 1, '2018-12-10');
insert into locacao (jogo, usuario, retirada) values (8, 1, '2018-12-10');
insert into locacao (jogo, usuario, retirada) values (7, 1, '2018-11-19');
insert into locacao (jogo, usuario, retirada) values (11, 1, '2018-11-17');
insert into locacao (jogo, usuario, retirada) values (12, 1, '2018-11-17');

insert into locacao (jogo, usuario, retirada) values (2, 2, '2018-12-01');
insert into locacao (jogo, usuario, retirada) values (4, 2, '2018-12-05');
insert into locacao (jogo, usuario, retirada) values (5, 2, '2018-12-10');

insert into locacao (jogo, usuario, retirada) values (3, 3, '2018-11-10');
insert into locacao (jogo, usuario, retirada) values (8, 3, '2018-11-10');
insert into locacao (jogo, usuario, retirada) values (7, 3, '2018-11-10');

insert into locacao (jogo, usuario, retirada) values (7, 4, '2018-12-16');
insert into locacao (jogo, usuario, retirada) values (6, 4, '2018-12-16');
insert into locacao (jogo, usuario, retirada) values (1, 4, '2018-10-16');
insert into locacao (jogo, usuario, retirada) values (4, 4, '2018-10-16');

insert into locacao (jogo, usuario, retirada) values (7, 5, '2018-12-10');
insert into locacao (jogo, usuario, retirada) values (1, 5, '2018-12-16');
insert into locacao (jogo, usuario, retirada) values (6, 5, '2018-06-16');