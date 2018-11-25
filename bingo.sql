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
    rodada serial not null references rodada (codigo),
    primary key (codigo, rodada)
);

create table numerocartela (
    cartela serial not null references cartela (codigo),
    numero serial not null,
    linha int not null check (linha >= 1 and linha <= 5),
    coluna int not null check (coluna >= 1 and coluna <= 5),
    primary key (cartela, numero)
);

create table numerorodada (
    rodada serial not null references rodada (codigo),
    numero serial not null,
    primary key (rodada, codigo)
);