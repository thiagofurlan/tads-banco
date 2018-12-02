drop table if exists caixa;
drop table if exists rodada;
drop table if exists cartela;
drop table if exists numerocartela;
drop table if exists numerorodada;

create table caixa (
    data date not null check (data >= now()) default now()::date,
    montanteinicial real not null check (montanteinicial >= 0.0),
    primary key (data)
);

create table rodada (
    codigo serial not null,
    data date not null default now()::date,
    hora time not null default now()::time,
    precocartela real not null check (precocartela >= 0.0),
    premio real not null check (premio >= 0),
    primary key (codigo)
);

create table cartela (
    codigo serial not null,
    rodada integer not null references rodada (codigo),
    primary key (codigo)
);

create table numerocartela (
    cartela integer not null references cartela (codigo),
    numero integer not null,
    linha int not null check (linha >= 1 and linha <= 5),
    coluna int not null check (coluna >= 1 and coluna <= 5),
    primary key (cartela, numero)
);

create table numerorodada (
    rodada integer not null references rodada (codigo),
    numero integer not null,
    primary key (rodada, numero)
);

-- SETUP
create or replace function get_random_number(inicio integer, fim integer) returns integer as $$
    begin
        return trunc(random() * (fim-inicio) + inicio);
    end;
$$ language 'plpgsql' STRICT;

create or replace function geraCartela (c integer) returns void as $$
    declare
        i integer;
        j integer;
        cont integer;
    begin
        cont := 0;
        for i in 1..5 loop
           for j in 1..5 loop
                insert into numerocartela (cartela, numero, linha, coluna) values (c, get_random_number(cont, cont+4), i, j);
                -- encontrar uma maneira de randomizar de 4 em 4 já que temos 99 numeros e precisamos de 25
                --if (j = 4 and i = 5) then
                  --  cont := cont + 3;
                --else
                    cont := cont + 4;
                --end if;
           end loop;
        end loop;
    end;
$$ language 'plpgsql';

-- 1 OK
insert into rodada (precocartela, premio) values (5.00, 590.00);


-- 2

insert into cartela (rodada) values ((select codigo from rodada order by codigo desc limit 1)) returning codigo; -- OK





-- with recursive tmp as ((select 0 as num) union (select num + 1 from tmp where num + 1 < 100)) select * from tmp order by random() offset 1 limit 1;


-- 3

