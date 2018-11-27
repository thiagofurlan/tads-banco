drop table if exists caixa;
drop table if exists rodada;
drop table if exists cartela;
drop table if exists numerocartela;
drop table if exists numerorodada;

create table caixa (
    data date not null check (data >= now()),
    montanteinicial real not null,
    primary key (data)
);

create table rodada (
    codigo serial not null,
    data date not null,
    hora time not null,
    precocartela real not null,
    premio real not null,
    primary key (codigo)
);

create table cartela (
    codigo serial not null,
    rodada integer not null references rodada (codigo),
    primary key (codigo)
);

create table numerocartela (
    cartela integer not null references cartela (codigo),
    numero serial not null,
    linha int not null check (linha >= 1 and linha <= 5),
    coluna int not null check (coluna >= 1 and coluna <= 5),
    primary key (cartela, numero)
);

create table numerorodada (
    rodada integer not null references rodada (codigo),
    numero serial not null,
    primary key (rodada, numero)
);


insert into rodada (data, hora,  precocartela, premio) values (now()::date, current_time, 5.00, 590.00);
insert into rodada (data, hora,  precocartela, premio) values (now()::date, current_time, 5.00, 850.00);
select * from rodada order by codigo desc limit 1;


-- 2
insert into numerocartela (cartela, numero, linha, coluna) values ();